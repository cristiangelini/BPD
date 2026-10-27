class_name Concierge
extends FloorBoss

## Don Evaristo, the Las Palomas building's manager (docs/diseno/edificio.md, "El encargado y la vecina"): he sweeps the
## lobby back and forth, mate in hand. Like Mirta and chef Bruno he fills the complaint meter and calls his lawyer at
## 100 ("¡Esto es un edificio de familia!"), and lets 2 things slip when asked. On top of what he sees, he hears
## anything that falls from the scaffold. When a cop rings the intercom (IntercomPanel) he takes the elevator to the
## leak on the 12th and is gone AWAY_TIME s: out of sight, seeing and hearing nothing. Every number here is (propuesta).

const AWAY_TIME := 20.0
## A cop in the elevator over 400 kg, in his sight.
const SAW_OVERLOAD := 10.0
## Something crashing down from the scaffold: he hears it anywhere but on the 12th.
const HEARD_FALL := 10.0

@onready var _shape: CollisionShape3D = $Shape


func _ready() -> void:
	fix_time = AWAY_TIME
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var away := is_fixing()
	visible = not away
	_shape.disabled = away
	$Bump.monitoring = not away


## Something happened where he can't see it but hears it: the complaint goes up `points`, unless he's away.
func heard(points: float, line: String) -> bool:
	if is_away():
		return false
	_raise(points)
	_say(line)
	return true


## Up on the 12th fixing the leak.
func is_away() -> bool:
	return is_fixing()
