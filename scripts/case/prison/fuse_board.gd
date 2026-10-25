class_name FuseBoard
extends StaticBody3D

## The prison's fuse board at the end of the cell block's corridor (carcel-corte-de-luz.md, step 5): a grey box on the
## wall with SLOTS burnt-out fuses. E with a new fuse (Fuse) in hand puts it in and its slot lights up green; with all
## of them in, the light comes back (BlackoutPlan.lights_back). El Chispa can pull the last one back out (pull).
## Its origin is on the wall, at the box's middle, with its front to local +Z. Every number here is (propuesta).

signal changed(filled: int)
signal complete

const SLOTS := 3
const SIZE := Vector3(0.6, 0.8, 0.15)
const BOX := Color(0.5, 0.52, 0.55)
const BURNT := Color(0.15, 0.12, 0.1)
const LIT := Color(0.3, 0.95, 0.4)

var filled := 0
var _slots: Array[MeshInstance3D] = []


func _ready() -> void:
	add_to_group("fuse_boards")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.z = SIZE.z / 2
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(SIZE), BOX, Vector3(0, 0, SIZE.z / 2)))
	for i in SLOTS:
		var slot := CopTool.piece(CopTool.box(Vector3(0.12, 0.16, 0.04)), BURNT,
			Vector3((i - (SLOTS - 1) / 2.0) * 0.17, 0.05, SIZE.z + 0.02))
		add_child(slot)
		_slots.append(slot)
	var sign_label := Label3D.new()
	sign_label.text = "FUSE_BOARD_SIGN"
	sign_label.font_size = 32
	sign_label.pixel_size = 0.005
	sign_label.position = Vector3(0, SIZE.y / 2 - 0.1, SIZE.z + 0.01)
	add_child(sign_label)
	_paint()


func is_complete() -> bool:
	return filled >= SLOTS


func prompt_key(cop: Cop) -> String:
	if is_complete():
		return ""
	return "PROMPT_FUSE_IN" if _held_fuse(cop) else "PROMPT_FUSE_BOARD"


## E: puts the fuse in hand in the next empty slot; without one, says what's missing.
func use(cop: Cop) -> void:
	var fuse := _held_fuse(cop)
	if not fuse:
		if not is_complete():
			cop.show_hint("HINT_FUSE_BOARD")
		return
	cop.get_node("Grabber").release()
	fuse.queue_free()
	put_in()


## One more fuse in (with all of them, the light comes back).
func put_in() -> void:
	if is_complete():
		return
	set_filled(filled + 1)
	if is_complete():
		complete.emit()


## El Chispa pulls the last fuse back out. Returns whether there was one.
func pull() -> bool:
	if filled <= 0 or is_complete():
		return false
	set_filled(filled - 1)
	return true


func set_filled(count: int) -> void:
	filled = clampi(count, 0, SLOTS)
	_paint()
	changed.emit(filled)


func _paint() -> void:
	for i in _slots.size():
		(_slots[i].mesh.material as StandardMaterial3D).albedo_color = LIT if i < filled else BURNT


func _held_fuse(cop: Cop) -> Fuse:
	var held: Node = cop.get_node("Grabber").held
	return held as Fuse
