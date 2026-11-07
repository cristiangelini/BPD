class_name FarmOwner
extends FloorBoss

## Don Florencio, the farmer (docs/diseno/allanamiento-granja.md, "Don Florencio y los animales"): the floor boss's round,
## complaint and slips, with the tool shed's key in his apron. While he feeds the animals (the bell, FeedBell) his back is
## to the farm, and a cop who sneaks up behind him takes the key with E. Every number here is (propuesta).

## A broken egg from his stall, seen or not: he counts them.
const EGG_BROKEN := 2.0

## The shed's key is still in his apron.
var has_key := true


func prompt_key(cop: Cop) -> String:
	if has_key and is_fixing():
		return "PROMPT_APRON_KEY"
	return super.prompt_key(cop)


func use(cop: Cop) -> void:
	if has_key and is_fixing():
		has_key = false
		cop.has_key = true
		cop.show_hint("HINT_APRON_KEY")
		return
	super.use(cop)


## One of his eggs broke: the complaint goes up, wherever he is.
func egg_broken() -> void:
	_raise(EGG_BROKEN)
	_say(_key("EGG"))
