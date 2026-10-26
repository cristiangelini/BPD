class_name BridgeDip
extends Node

## The deputy falls into the canal (politico-puente.md, step 3, decision 178, question 1 as recommended): the first
## time he climbs out wet and furious after DIP_TIME seconds, back onto the deck at the nearer end, and goes on (the
## shift pays 200 less, step 5); the second time he goes home (`went_home`) and the case is lost. While he's in the
## water the ceremony waits. Every number here is (propuesta).

signal dipped(count: int)
signal went_home

const DIP_TIME := 8.0
const DIPS_MAX := 2

var park: BridgePark
var ceremony: BridgeCeremony
var dips := 0
## Seconds before he's out of the water, while in it.
var out_left := 0.0
var home := false


func setup(the_park: BridgePark, the_ceremony: BridgeCeremony) -> void:
	park = the_park
	ceremony = the_ceremony


func wet() -> bool:
	return out_left > 0.0


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or home:
		return
	if out_left > 0.0:
		out_left -= delta
		ceremony.hold(delta * 2.0)
		if out_left <= 0.0:
			_climb_out()
		return
	if ceremony.state == BridgeCeremony.State.WAITING or ceremony.state == BridgeCeremony.State.OVER:
		return
	if park.in_water(ceremony.politician.global_position):
		dips += 1
		dipped.emit(dips)
		if dips >= DIPS_MAX:
			home = true
			ceremony.abort()
			ceremony.politician.say("BRIDGE_LUSTRE_HOME")
			went_home.emit()
			return
		out_left = DIP_TIME
		ceremony.hold(DIP_TIME)
		ceremony.politician.say("BRIDGE_LUSTRE_DIP")


## Back up on the deck at the end of the bridge nearer to where he fell.
func _climb_out() -> void:
	var x := park.to_local(ceremony.politician.global_position).x
	var top := BridgePark.RAMP_TOP_WEST
	if x > 0.0:
		top.x = -top.x
	ceremony.back_on(park.to_global(top + Vector3.UP * 0.05))
	ceremony.politician.say("BRIDGE_LUSTRE_WET")
