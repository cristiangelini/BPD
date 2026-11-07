class_name StackedPlate
extends Ornament

## A plate in one of the pizzeria counter's stacks (docs/diseno/allanamiento-pizzeria.md, "Lo frágil"). Thin plates
## stacked on each other jitter until they break, so the stack waits frozen until something reaches it or a cop grabs
## one of its plates; then the whole stack wakes up, and falls with a look.

## A cop grabbed it: its stack wakes up.
signal grabbed


func hold(holder_id: int, point: Vector3) -> void:
	grabbed.emit()
	super.hold(holder_id, point)
