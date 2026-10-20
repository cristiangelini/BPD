class_name BallerinaCopy
extends Ornament

## A souvenir copy of the museum ballerina (historias.md, "La figurita del museo"): it looks just like the original,
## but turned over it has no seal. It's one of the grandpa's ornaments, so breaking it is a fine.


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	var grabber := instance_from_id(holder_id) as Node
	if first and grabber and grabber.get_parent() is Cop:
		(grabber.get_parent() as Cop).show_hint("HINT_BALLERINA_COPY")
