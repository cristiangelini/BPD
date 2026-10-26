class_name SleepyCakesRig
extends CakeLabRig

## The cakes that make you sleep (laboratorio.md, "Los pasteles que dan sueño"): the chef puts sleeping powder in his
## cakes and his partners empty the pockets of the customers who doze off. The jar of powder is the main evidence
## (1 kg), hidden with the list of customers put to sleep and the giant measuring spoon. The story's own clue: Pocha's
## samples make you yawn. And the plate of free slices on the showcase is the real thing: a cop who eats one (E) drops
## what they hold and sleeps SLEEP_TIME seconds on their feet, unable to move. Every number here is (propuesta).

signal dozed(cop: Cop)

const PLATE_MODEL := preload("res://assets/models/cake_slices.glb")
## The plate at the free end of the showcase.
const PLATE_AT := Vector3(1.75, CakeLab.SHOWCASE_AT.y + CakeLab.SHOWCASE_SIZE.y, CakeLab.SHOWCASE_AT.z)
const PLATE_RADIUS := 0.2
const SLEEP_TIME := 4.0

var plate: SlicePlate
var dozes := 0
var _yawned := false


func setup(place: CakeLab) -> void:
	super.setup(place)
	place.pocha.sample_hint = "HINT_SAMPLE_YAWN"
	place.pocha.tasted.connect(func(_cop: Cop) -> void:
		if not _yawned:
			_yawned = true
			place.raid.add_clue(tr("CLUE_YAWN")))
	plate = SlicePlate.new()
	plate.position = PLATE_AT
	place.add_child(plate)
	plate.eaten.connect(doze)


## The cop ate a slice: down it goes for SLEEP_TIME seconds, with its Zzz.
func doze(cop: Cop) -> void:
	dozes += 1
	cop.eat(SLEEP_TIME)
	cop.stagger(SLEEP_TIME)
	cop.show_hint("HINT_SLEEPY_CAKE")
	var zzz := Label3D.new()
	zzz.text = "Zzz"
	zzz.position = Vector3(0, 2.1, 0)
	zzz.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	zzz.font_size = 64
	zzz.outline_size = 10
	zzz.modulate = Color(0.75, 0.6, 1.0)
	cop.add_child(zzz)
	get_tree().create_timer(SLEEP_TIME).timeout.connect(zzz.queue_free)
	dozed.emit(cop)


## The plate of free slices: E eats one.
class SlicePlate:
	extends StaticBody3D

	signal eaten(cop: Cop)

	func _ready() -> void:
		collision_layer = 8
		var shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = PLATE_RADIUS
		cylinder.height = 0.1
		shape.shape = cylinder
		shape.position.y = 0.05
		add_child(shape)
		add_child(PLATE_MODEL.instantiate())

	func prompt_key(_cop: Cop) -> String:
		return "PROMPT_EAT_SLICE"

	func use(cop: Cop) -> void:
		eaten.emit(cop)
