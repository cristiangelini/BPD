class_name LotEasel
extends StaticBody3D

## The easel of the lots beside Don Martillo's podium (infiltracion-subasta.md, step 3, decision 177): the lot up for
## sale stands on its ledge (show_lot), one of KINDS: an ugly portrait, a vase, a marble bust or a chair "de época";
## nothing between lots. Every number here is (propuesta).

const MODEL := preload("res://assets/models/auction_easel.glb")
const KINDS: Array[String] = ["painting", "vase", "statue", "chair"]
const LOTS := {
	"painting": preload("res://assets/models/lot_painting.glb"),
	"vase": preload("res://assets/models/lot_vase.glb"),
	"statue": preload("res://assets/models/lot_statue.glb"),
	"chair": preload("res://assets/models/lot_chair.glb"),
}
## Where a lot stands, on the ledge.
const LEDGE := Vector3(0, 0.905, 0.1)

var lot := ""
var _shown: Node3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.9, 1.8, 0.5)
	shape.shape = box
	shape.position.y = 0.9
	add_child(shape)
	add_child(MODEL.instantiate())


## The lot `kind` on the ledge ("" takes it off).
func show_lot(kind: String) -> void:
	lot = kind
	if _shown:
		remove_child(_shown)
		_shown.queue_free()
		_shown = null
	if LOTS.has(kind):
		_shown = (LOTS[kind] as PackedScene).instantiate()
		_shown.name = "Lot"
		_shown.position = LEDGE
		add_child(_shown)
