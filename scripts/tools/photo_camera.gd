class_name PhotoCamera
extends CopTool

## The photo camera (herramientas.md): left click takes a photo with a flash. A photo of a clue trail notes it on
## the checklist from afar; the flash in the face of the place's owner makes them complain.

## Photos per shift and seconds between photos (propuesta).
const FILM := 24
const COOLDOWN := 1.0
## A trail counts if one of its marks is this close and this many degrees off the center of the photo (propuesta).
const RANGE := 12.0
const FRAME_ANGLE := 12.0

var film := FILM
var _wait := 0.0
var _flash: OmniLight3D


func _init() -> void:
	name_key = "TOOL_CAMERA"


func _ready() -> void:
	super()
	_flash = OmniLight3D.new()
	_flash.omni_range = 10.0
	_flash.light_energy = 0.0
	add_child(_flash)


func prompt_key() -> String:
	return "PROMPT_CAMERA" if film > 0 else "PROMPT_CAMERA_EMPTY"


func press() -> void:
	shoot()


func _physics_process(delta: float) -> void:
	_wait = maxf(_wait - delta, 0.0)


## Takes a photo. Returns the checklist lines of the trails it caught, or nothing if it couldn't shoot.
func shoot() -> Array[String]:
	var caught: Array[String] = []
	if _wait > 0.0:
		return caught
	if film <= 0:
		cop.show_hint("HINT_NO_FILM")
		return caught
	film -= 1
	_wait = COOLDOWN
	cop.stats["photos"] = cop.stats.get("photos", 0) + 1
	_flash_light()
	var hit := cop.aim_hit(RANGE)
	if not hit.is_empty() and hit.collider.has_method("photographed"):
		hit.collider.photographed(cop)
	for place in get_tree().get_nodes_in_group("photo_clues"):
		var trails: Dictionary = place.photo_clues()
		for line: String in trails:
			if _in_frame(trails[line]):
				place.add_clue(line)
				caught.append(line)
	cop.show_hint("HINT_PHOTO_CLUE" if not caught.is_empty() else "HINT_PHOTO")
	return caught


func _in_frame(marks: Array) -> bool:
	var eye := global_transform
	for mark: Node3D in marks:
		var to := mark.global_position - eye.origin
		if to.length() <= RANGE and rad_to_deg((-eye.basis.z).angle_to(to)) <= FRAME_ANGLE:
			return true
	return false


func _flash_light() -> void:
	_flash.light_energy = 8.0
	var tween := create_tween()
	tween.tween_property(_flash, "light_energy", 0.0, 0.15)


func build_model() -> Node3D:
	var root := Node3D.new()
	root.add_child(piece(box(Vector3(0.15, 0.09, 0.06)), Color(0.2, 0.2, 0.24)))
	root.add_child(piece(cylinder(0.03, 0.05), Color(0.08, 0.08, 0.1), Vector3(0, 0, -0.05), Vector3(PI / 2, 0, 0)))
	root.add_child(piece(box(Vector3(0.04, 0.02, 0.03)), Color(0.95, 0.95, 0.9), Vector3(-0.04, 0.05, 0)))
	return root
