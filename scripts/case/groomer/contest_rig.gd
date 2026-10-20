class_name ContestRig
extends GroomerRig

## The rigged contest (peluqueria.md, "El concurso arreglado"): Bizcocho, one of the loose dogs, won the neighborhood
## dog show with bought judges. The cup is the main evidence (hidden like the extras). The salon's photos of "happy
## customers" all show Bizcocho winning (the story's own clue), and Bizcocho never strays from his cup: he barks loud
## at any cop who gets close to it, and every bark reaches Ramiro. A cop who holds Bizcocho keeps him quiet.
## Every number here is (propuesta).

const PHOTO_SCENE := preload("res://scenes/props/contest_photo.tscn")
## Which loose dog is the champion (the photos show his coat).
const CHAMPION := 1
## He barks at cops closer than this to the cup, while he's this close to it himself, once every LOUD_EVERY seconds.
const NEAR := 2.5
const HEARS := 8.0
const LOUD_EVERY := 3.0
## He wanders this close around the cup (a square of twice this side).
const GUARD := 1.5
## The photos stand on the counter, on the second grooming table and on top of the cages.
const PHOTOS: Array[Vector3] = [
	Vector3(-3.0, Groomer.FLOOR_TOP + 1.0 + 0.075, 4.2), Vector3(5.0, Groomer.FLOOR_TOP + 0.86 + 0.075, 4.5),
	Vector3(-7.4, Groomer.FLOOR_TOP + Groomer.CAGE_STEP + 0.8 + 0.075, Groomer.CAGE_Z),
]

var champion: Dog
var photos: Array[ClueNote] = []
var loud_barks := 0
var _since_loud := LOUD_EVERY
var _woof: Label3D


func setup(place: Groomer) -> void:
	super.setup(place)
	champion = place.dogs[CHAMPION]
	_dress_champion()
	for at in PHOTOS:
		var photo: ClueNote = PHOTO_SCENE.instantiate()
		photo.text = tr("CLUE_CONTEST_PHOTOS")
		photo.position = at
		photo.read.connect(place.raid.add_clue)
		place.add_child(photo)
		photos.append(photo)


func _physics_process(delta: float) -> void:
	_since_loud += delta
	var cup := groomer.main
	if not is_instance_valid(cup) or groomer.car.is_delivered(cup) or champion.is_held():
		return
	if not cup.is_held():
		var at := cup.global_position
		champion.areas = [Rect2(at.x - GUARD, at.z - GUARD, GUARD * 2, GUARD * 2)]
	if _since_loud < LOUD_EVERY or _flat(champion.global_position, cup.global_position) > HEARS:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).vehicle == null and _flat((cop as Node3D).global_position, cup.global_position) < NEAR:
			bark_loud()
			return


## WOOF WOOF: Bizcocho guards his cup.
func bark_loud() -> void:
	_since_loud = 0.0
	champion._since_bark = Dog.BARK_COOLDOWN
	if champion.bark():
		loud_barks += 1
		_woof.show()
		get_tree().create_timer(1.5).timeout.connect(_woof.hide)


## A blue rosette on his chest, and the bubble for his barks.
func _dress_champion() -> void:
	var rosette := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.06
	disc.bottom_radius = 0.06
	disc.height = 0.01
	var blue := StandardMaterial3D.new()
	blue.albedo_color = Color(0.16, 0.35, 0.8)
	disc.material = blue
	rosette.mesh = disc
	rosette.position = Vector3(0, 0.32, 0.27)
	rosette.rotation.x = PI / 2
	champion._model.add_child(rosette)
	_woof = Label3D.new()
	_woof.text = "DOG_LOUD_BARK"
	_woof.position = Vector3(0, 0.9, 0)
	_woof.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_woof.no_depth_test = true
	_woof.pixel_size = 0.005
	_woof.outline_size = 10
	_woof.font_size = 48
	_woof.modulate = Color(1, 0.85, 0.3)
	_woof.hide()
	champion.add_child(_woof)


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
