class_name NumberList
extends Evidence

## The lottery story's list of numbers (panaderia.md, "La lotería del pan"): one number is circled. The first time a
## cop grabs it they read which sweet bread hides the ticket.

## The circled number, set by the story's rig.
var winning := 0


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	if not first:
		return
	var grabber := instance_from_id(holder_id) as Node
	if grabber and grabber.get_parent() is Cop:
		(grabber.get_parent() as Cop).show_hint(tr("HINT_NUMBER_LIST") % winning)
