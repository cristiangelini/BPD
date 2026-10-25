class_name KeyBoard
extends Node3D

## The key board on the wall behind the night guard in the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 3):
## HOOKS keys, one on each hook (KeyHook, aimed at one by one), and only the seed's `good` one opens the cells. E on
## it takes the cells' key (a CellKey in hand); any other is the bathroom's, the storeroom's... and goes back on its
## hook. A catch hangs the cells' key back. Every number here is (propuesta).

signal key_taken(cop: Cop)

const MODEL := preload("res://assets/models/key_board.glb")
const KEY_SCENE := preload("res://scenes/props/cell_key.tscn")
const HOOKS := 6
const HOOK_EVERY := 0.14
const WRONG_LINES := 5

## Which hook has the cells' key, and whether it's still there.
var good := 0
var has_key := true
var _model: Node3D


func _ready() -> void:
	add_to_group("key_boards")
	_model = MODEL.instantiate()
	add_child(_model)
	for i in HOOKS:
		var hook := KeyHook.new()
		hook.name = "Hook%d" % i
		hook.board = self
		hook.index = i
		hook.position = Vector3((i - (HOOKS - 1) / 2.0) * HOOK_EVERY, 0.0, 0.05)
		add_child(hook)
	_refresh()


## This seed's good hook.
func setup(case_seed: int) -> void:
	good = hash(["key board", case_seed]) % HOOKS


## Whether hook `index` has a key on it right now (every one but the cells' key once it's taken).
func hook_has_key(index: int) -> bool:
	return index != good or has_key


func prompt_key(index: int, cop: Cop) -> String:
	if not hook_has_key(index) or cop.get_node("Grabber").held:
		return ""
	return "PROMPT_KEY_BOARD"


## Takes the key off hook `index`: the cells' key into the cop's hand, or a wrong one that goes back up.
func take(index: int, cop: Cop) -> void:
	if prompt_key(index, cop) == "":
		return
	if index != good:
		cop.show_hint("HINT_VENT_WRONG_KEY_%d" % ((index if index < good else index - 1) % WRONG_LINES), true)
		return
	if not multiplayer.is_server():
		return
	has_key = false
	_refresh()
	var key: CellKey = KEY_SCENE.instantiate()
	get_parent().add_child(key)
	key.global_position = cop.camera.global_position
	cop.handed(key)
	key_taken.emit(cop)


## The guard caught them: the cells' key back on its hook.
func hang_back() -> void:
	has_key = true
	_refresh()


func _refresh() -> void:
	var key := _model.find_child("key_%d" % good, true, false) as Node3D
	if key:
		key.visible = has_key


## Online: whether the cells' key is on the board (NpcSync).
func net_state() -> Variant:
	return has_key


func apply_net_state(state: Variant) -> void:
	has_key = state
	_refresh()
