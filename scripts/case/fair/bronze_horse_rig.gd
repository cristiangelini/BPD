class_name BronzeHorseRig
extends FairRig

## The bronze horse (allanamiento-parque.md, "El caballo de bronce"): Don Tómbola stole the bronze horse from the square
## and painted it like one of the carousel's horses. It stands among the outer ones (drawn with the seed) and is the
## main evidence (20 kg, two of you): it doesn't go up and down, and the first time a cop takes hold of it it goes
## "¡CLANG!", the story's own clue (on the checklist). While it's on the carousel, the carousel turns at half speed and
## squeaks. The paint and the newspaper clipping are hidden. Every number here is (propuesta).

const HORSE_SCENE := preload("res://scenes/props/fair_bronze_horse.tscn")
## The carousel horse's hooves are this high over its deck; the evidence's middle is this high over them.
const MIDDLE := 1.115
const SLOW := 0.5
const SQUEAK_EVERY := 3.0

## Which of the carousel's horses it is, and the statue standing there.
var index := -1
var statue: Evidence
var clanged := false
var _since_squeak := 0.0


func setup(place: Fair) -> void:
	super.setup(place)
	index = hash(["bronze horse", place.case_seed]) % int(Fair.HORSE_RINGS[0].y)
	var horse := place.horses[index]
	statue = HORSE_SCENE.instantiate()
	statue.name = "BronzeHorse"
	statue.position = horse.position + Vector3.UP * MIDDLE
	statue.rotation = horse.rotation
	statue.freeze = true
	place.carousel.add_child(statue)
	horse.queue_free()
	place.horses[index] = statue
	place.rides.still_horses.append(statue)
	place.rides.spin_rpm = FairRides.SPIN_RPM * SLOW
	place.main = statue


func _physics_process(delta: float) -> void:
	if not clanged and statue.is_held():
		_take_off()
	if clanged or not fair.rides.spinning:
		return
	_since_squeak += delta
	if _since_squeak >= SQUEAK_EVERY:
		_since_squeak = 0.0
		fair.raid.float_label(tr("FAIR_CAROUSEL_SQUEAK"), fair.to_global(Fair.CAROUSEL_AT + Vector3.UP * 4.6),
			Color(0.95, 0.9, 0.8))


## The first hand on it: "¡CLANG!", it comes off the carousel and the carousel turns at its speed again.
func _take_off() -> void:
	clanged = true
	var at := statue.global_transform
	statue.get_parent().remove_child(statue)
	fair.add_child(statue)
	statue.global_transform = at
	# Online only the host simulates it; a guest's copy stays frozen and follows (PropSync).
	statue.freeze = not multiplayer.is_server()
	fair.rides.spin_rpm = FairRides.SPIN_RPM
	fair.raid.add_clue(tr("CLUE_BRONZE_CLANG"))
	fair.raid.float_label(tr("FAIR_CLANG"), at.origin + Vector3.UP * 0.8, Color(0.85, 0.6, 0.3))
