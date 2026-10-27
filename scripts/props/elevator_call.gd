class_name ElevatorCall
extends StaticBody3D

## The call button by the elevator on a landing of the Las Palomas building (docs/diseno/edificio.md, step 2): E brings
## the car to this floor.

var elevator: TowerElevator
var stop := 0


func prompt_key(_cop: Cop) -> String:
	return "" if elevator.at_stop == stop and not elevator.moving else "PROMPT_CALL_ELEVATOR"


func use(_cop: Cop) -> void:
	elevator.call_to(stop)
