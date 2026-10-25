class_name CleaningTool
extends HookStick

## Something from the cleaning closet of the cleaning crew's jailbreak (docs/diseno/fuga-limpieza.md, step 3): the mop
## or the feather duster. In hand it points where the cop looks, like the jailbreak's broom (HookStick), so the mop's
## head goes to the floor by looking down. A cop in the cleaning disguise with one in hand passes for the cleaning
## crew in front of the early comisario (EarlyComisario). Every number here is (propuesta).

## "mop" or "duster".
@export var kind := "mop"


static func held_by(cop: Cop) -> CleaningTool:
	return cop.get_node("Grabber").held as CleaningTool


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_MOP" if kind == "mop" else "PROMPT_HOLDING_DUSTER"
