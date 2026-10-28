class_name WeddingGrandma
extends WeddingPerson

## Grandma Chola, the wedding's witness (escena-boda.md, "La abuela sorda"): half deaf, at her table with her ear
## trumpet on the tablecloth. E on her gets "¿Eh? ¿Qué?" until she can hear: a cop shouts with his voice near her, or
## hands her the ear trumpet (EarTrumpet). Then, if the witness is one of the case's clues, she smelled the culprit's
## cologne. Shouting doesn't offend her (she's grateful); only the cuffs do, and then she says nothing more. Every number
## here is (propuesta).

const MODEL := preload("res://assets/models/npc_abuela_chola.glb")
const SHOUT_REACH := 5.0
const DEAF_LINES := 4

var case: CrimeSceneCase
## She smelled the culprit's cologne (the witness is one of the case's clues).
var knows := false
var hearing := false
var offended := false


func _ready() -> void:
	model = MODEL
	prompt = "PROMPT_WEDDING_GRANDMA"
	line_key = "WEDDING_GRANDMA_LINE_"
	lines = DEAF_LINES
	super._ready()
	add_to_group("wedding_grandma")


func use(_cop: Cop) -> void:
	if offended:
		say("GRANDMA_OFFENDED")
	elif not hearing:
		talk()
	else:
		tell()


## What she smelled, if she can hear and isn't offended.
func tell() -> void:
	if knows and case:
		case.found("witness")
		say(tr("GRANDMA_SMELLED") % tr("COLOGNE_" + str(case.culprit().cologne)), 6.0)
	else:
		say("GRANDMA_NOTHING")


## Now she can hear (the ear trumpet, or a shout): she's glad, and tells what she knows.
func hear() -> void:
	if offended:
		return
	hearing = true
	say("GRANDMA_HEARS")
	tell()


## A cop shouted: if he was close, now she hears him.
func shouted_by(cop: Cop) -> void:
	if cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		hear()


func cuffed(_seconds: float) -> void:
	offend()


func offend() -> void:
	if offended:
		return
	offended = true
	say("GRANDMA_OFFENDED")
	if knows and case:
		case.ruin("witness")
