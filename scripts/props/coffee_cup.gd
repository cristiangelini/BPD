class_name CoffeeCup
extends Grabbable

## A paper cup of coffee from the observation room's machine (interrogatorio.md, "Las acciones"): set down near the
## suspect in an interrogation, he takes it, and that's the good cop's coffee.

## How close to his chest it has to end up, in meters (propuesta).
const REACH := 0.9
## A cop who let go of it this recently gets the credit.
const SERVED_SECONDS := 3.0
const SETTLED_SPEED := 0.3


func _ready() -> void:
	# The crime scene's recipe gets wet if a cup ends up on it (CrimeClueItem).
	add_to_group("coffee_cups")


func _physics_process(_delta: float) -> void:
	if not was_held or not holders.is_empty() or linear_velocity.length() > SETTLED_SPEED:
		return
	var case := InterrogationCase.active(get_tree(), self)
	if case and case.coffee_served(self):
		queue_free()


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_COFFEE_CUP"
