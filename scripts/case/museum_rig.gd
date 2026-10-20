class_name MuseumRig
extends StoryRig

## The museum figurine (historias.md): the porcelain ballerina stolen from the museum stands on one of the grandpa's
## shelves, among souvenir copies that look just like it. Only the original has the museum's seal under the base:
## grabbing one tells which it is. The clipping waits in a hiding spot. Every number here is (propuesta).

## Evidence order in museum_story.tres: the ballerina, the clipping.
const BALLERINA := 0
const CLIPPING := 1
const COPIES := 8
const COPY_SCENE := preload("res://scenes/props/ornament_ballerina.tscn")
const FIGURINE_SCENE := "res://scenes/props/ornament_figurine.tscn"
const FIGURINE_HALF := 0.085
const BALLERINA_HALF := 0.105

var copies: Array[BallerinaCopy] = []


## The original and the copies take the places of figurines drawn with the seed, standing where they stood.
func setup(house: GrandpaHouse) -> void:
	var ornaments := house.get_node("Ornaments")
	var figurines: Array = ornaments.get_children().filter(
		func(node: Node) -> bool: return node.scene_file_path == FIGURINE_SCENE)
	var rng := RandomNumberGenerator.new()
	rng.seed = house.case_seed * 23 + 11
	var picked: Array[Node3D] = []
	for i in COPIES + 1:
		picked.append(figurines.pop_at(rng.randi_range(0, figurines.size() - 1)))
	var lift := Vector3.UP * (BALLERINA_HALF - FIGURINE_HALF)
	var original: Node3D = house.evidence[BALLERINA]
	original.global_transform = picked[0].global_transform.translated(lift)
	for i in range(1, picked.size()):
		var copy: BallerinaCopy = COPY_SCENE.instantiate()
		copy.transform = picked[i].transform.translated(lift)
		copy.broken.connect(house._on_ornament_broken)
		ornaments.add_child(copy)
		copies.append(copy)
	for figurine in picked:
		ornaments.remove_child(figurine)
		figurine.queue_free()
	house.ornaments_total -= 1


func loose_item() -> int:
	return BALLERINA


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	return [{"text": "OBJ_EXTRA_CLIPPING", "done": house.car.is_delivered(house.evidence[CLIPPING] as Evidence)}]
