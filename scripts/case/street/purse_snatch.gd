class_name PurseSnatch
extends CityEvent

## The purse snatching (ciudad-viva.md, step 7): a thief grabs a walker's purse and runs to a dead-end alley. The
## walker stops and shouts. Cuffing the thief gives her the purse back and pays MONEY; if he gets away, nothing.
## Every number here is (propuesta).

const MONEY := 60

var victim: CityWalker
var thief: CityRunaway


## Starts it on `walker`, with the thief running to `alley` (CityLife.ALLEYS).
func begin(walker: CityWalker, alley: Array) -> void:
	victim = walker
	victim.stop_for(30.0)
	victim.say("EVENT_PURSE_HELP", 6.0)
	thief = CityRunaway.new()
	thief.name = "Thief"
	# The route is in the city's space; this event sits at the city's origin, so its transform takes it to the world.
	thief.route = CityRunaway.in_world(CityRunaway.route_to(to_local(walker.global_position), alley), global_transform)
	add_child(thief)
	thief.global_position = walker.global_position + walker.global_basis.z * 1.2
	thief.caught.connect(_on_caught)
	thief.got_away.connect(finish.bind(0))


func _on_caught() -> void:
	if is_instance_valid(victim):
		victim.say("EVENT_PURSE_THANKS", 5.0)
	finish(MONEY)
