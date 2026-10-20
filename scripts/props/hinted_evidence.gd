class_name HintedEvidence
extends Evidence

## Evidence that tells the cop something the first time they grab it (the museum ballerina's seal, the clipping).

@export var hint_key := ""
## Hides the value over it until someone grabs it, when the number would give it away among look-alikes.
@export var value_hidden := false


func _ready() -> void:
	super._ready()
	if value_hidden and _label:
		_label.hide()


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	if _label:
		_label.show()
	var grabber := instance_from_id(holder_id) as Node
	if first and hint_key != "" and grabber and grabber.get_parent() is Cop:
		(grabber.get_parent() as Cop).show_hint(hint_key)
