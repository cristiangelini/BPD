class_name BridgeCoat
extends Node

## Holding the deputy back by the coat (politico-puente.md, step 4, decision 178): on the bridge, E on him stops him
## HOLD seconds where he is (the ceremony's clock waits), so the cops can fit the planks in front of him. He complains.
## Every number here is (propuesta).

signal grabbed(cop: Cop)

const HOLD := 3.0
const LINES := 3

var ceremony: BridgeCeremony
var _line := 0


func prompt_key(_cop: Cop) -> String:
	if ceremony and (ceremony.state == BridgeCeremony.State.WALKING or ceremony.state == BridgeCeremony.State.POSING):
		return "PROMPT_GRAB_COAT"
	return "PROMPT_TALK_POLITICIAN"


## True when it held him back (otherwise he just shakes hands).
func use(cop: Cop) -> bool:
	if prompt_key(cop) != "PROMPT_GRAB_COAT":
		return false
	ceremony.hold(HOLD)
	ceremony.politician.say("BRIDGE_LUSTRE_COAT_%d" % (_line % LINES + 1), HOLD)
	_line += 1
	grabbed.emit(cop)
	return true
