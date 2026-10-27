class_name MysteryMember
extends MansionPerson

## One of the six members of the Mystery Club (escena-mansion.md, "Los socios iguales y sus fichas"), dressed as
## Detective Pipa like the other five: the checked cape, the deerstalker, the magnifying glass and the bubble pipe.
## Under the cap, their own hair (tinted); their glasses, if they wear them; their shoes (stretched to their size).
## E on them: where they were at midnight (their alibi), a different opening each time. Their file comes in step 4.
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_socio_club.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 6

## MemberTraits.draw: name, hair, glasses, shoe, teeth, room.
var traits := {}
## Their place in the case's order of traits.
var index := 0
var told_alibi := false


func _init() -> void:
	model = MODEL
	prompt = "PROMPT_MANSION_MEMBER"


func _ready() -> void:
	super()
	add_to_group("mansion_members")
	var material := StandardMaterial3D.new()
	material.albedo_color = MemberTraits.HAIRS[traits.hair]
	for mesh in part("hair").find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(MemberTraits.SHOE_MIN, MemberTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)


func use(_cop: Cop) -> void:
	alibi()


## Where they were at midnight, opened a different way each time.
func alibi() -> void:
	say(tr("MEMBER_LINE_%d" % ((index + _lines_said) % LINES)) + " " + tr("MEMBER_ALIBI_" + str(traits.room)), 5.0)
	_lines_said += 1
	told_alibi = true
