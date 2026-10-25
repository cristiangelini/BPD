class_name CrashDriver
extends CityWalker

## A driver out of their car after a crash (ciudad-viva.md, "El choque"): they argue with the other driver until a
## cop talks to them (E), then they calm down. Every number here is (propuesta).

signal calmed(driver: CrashDriver)

const ARGUE_LINES := 6
const ARGUE_EVERY := 3.5

var calm := false
var _argue_left := 0.0
var _line := 0


func _ready() -> void:
	super()
	contraband = -1
	_line = randi() % ARGUE_LINES


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CRASH_CALM"


func use(_cop: Cop) -> void:
	if calm:
		return
	calm = true
	say("CRASH_CALM_%d" % (randi() % 3), 5.0)
	calmed.emit(self)


func _process(delta: float) -> void:
	super(delta)
	if calm:
		return
	_argue_left -= delta
	if _argue_left <= 0.0:
		_argue_left = ARGUE_EVERY
		say("CRASH_ARGUE_%d" % _line, ARGUE_EVERY - 0.5)
		_line = (_line + 1) % ARGUE_LINES
