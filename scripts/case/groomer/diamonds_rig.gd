class_name DiamondsRig
extends GroomerRig

## The diamond necklace (peluqueria.md, "El collar de diamantes"): a lady's diamond necklace was stolen and Ramiro
## put it on one of the loose dogs to get it out of the neighborhood. The dog wearing it (drawn with the seed) runs
## from cops and moves to another part of the salon every MOVE_EVERY seconds: it has to be caught. Under a dryer's
## light the necklace shines (the story's own clue). Grabbing the necklace takes it off the dog; the case is hidden
## like any extra. Every number here is (propuesta).

const NECKLACE_SCENE := preload("res://scenes/props/diamond_necklace.tscn")
## The loose dogs that can wear it (not the ones the dog tests use, nor the show's champion).
const WEARERS := [2, 4, 5]
const FLEE := 3.0
const MOVE_EVERY := 30.0
## Where it goes, in turns: under both dryers, the reception, the cages and the yard.
const STOPS: Array[Vector3] = [
	Vector3(2.9, Groomer.FLOOR_TOP, Groomer.DRYER_Z), Vector3(-5.0, Groomer.FLOOR_TOP, 5.0),
	Vector3(5.4, Groomer.FLOOR_TOP, Groomer.DRYER_Z),
	Vector3(-2.5, Groomer.FLOOR_TOP, 0.5), Vector3(-1.0, Groomer.GRASS_TOP, -4.5),
]
## It shines this close to a dryer; a cop this close to it then sees it.
const DRYER_LIGHT := 1.0
const SEES := 5.0
## Around the neck, from the dog's feet (in its model's space).
const NECK := Vector3(0, 0.36, 0.2)
const STOP_SIZE := 1.0
## On the dog the necklace looks this much bigger, so it shows around the fur.
const WORN_SCALE := 1.9

var wearer: Dog
var necklace: Evidence
var worn := true
var shining := false
var stop := 0
var _move_left := MOVE_EVERY
var _shine: OmniLight3D


func setup(place: Groomer) -> void:
	super.setup(place)
	wearer = place.dogs[WEARERS[place.case_seed % WEARERS.size()]]
	wearer.flee = FLEE
	necklace = NECKLACE_SCENE.instantiate()
	place.add_child(necklace)
	necklace.freeze = true
	necklace.get_node("Model").scale = Vector3.ONE * WORN_SCALE
	wearer.add_collision_exception_with(necklace)
	_shine = OmniLight3D.new()
	_shine.light_color = Color(0.8, 0.95, 1.0)
	_shine.light_energy = 2.5
	_shine.omni_range = 0.8
	_shine.visible = false
	necklace.add_child(_shine)
	place.main = necklace
	stop = place.case_seed % STOPS.size()
	go_to(stop)
	_wear()


## Sends the wearer to stop `index` and keeps it wandering there.
func go_to(index: int) -> void:
	stop = index % STOPS.size()
	var at := STOPS[stop]
	wearer.areas = [Rect2(at.x - STOP_SIZE / 2, at.z - STOP_SIZE / 2, STOP_SIZE, STOP_SIZE)]
	wearer._wander = 0.0
	_move_left = MOVE_EVERY


func _physics_process(delta: float) -> void:
	if not worn or not is_instance_valid(necklace):
		return
	if necklace.is_held():
		take_off()
		return
	_wear()
	_move_left -= delta
	if _move_left <= 0.0:
		go_to(stop + 1)
	shining = _under_dryer()
	_shine.visible = shining
	if shining:
		for cop in get_tree().get_nodes_in_group("cops"):
			if (cop as Node3D).global_position.distance_to(necklace.global_position) < SEES:
				groomer.raid.add_clue(tr("CLUE_DIAMONDS_SHINE"))
				break


## A cop took it off the dog: it's a loose piece of evidence now, and the dog is a dog again.
func take_off() -> void:
	worn = false
	shining = false
	_shine.visible = false
	necklace.freeze = false
	necklace.get_node("Model").scale = Vector3.ONE
	wearer.remove_collision_exception_with(necklace)
	wearer.flee = 0.0
	wearer.areas = Groomer.DOG_AREAS


func _wear() -> void:
	necklace.global_transform = wearer._model.global_transform.translated_local(NECK)


func _under_dryer() -> bool:
	for table in Groomer.TABLES:
		var dryer := Vector2(table.x, Groomer.DRYER_Z)
		if dryer.distance_to(Vector2(wearer.global_position.x, wearer.global_position.z)) < DRYER_LIGHT:
			return true
	return false
