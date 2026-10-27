class_name OfficeIntern
extends OfficePerson

## Benja, the intern, the office case's witness (escena-oficina.md, "Las pistas"): last night he saw the thief's face
## reflected in a screen, but he never sees past his pile of papers. The pile waits at his feet and he asks for it to
## be carried to the giant copier; once it's there, E on him and he tells whether the thief wore glasses. Cuffed, or
## with his pile dropped or thrown before it got there, he's offended and says nothing more for the whole case. Every
## number here is (propuesta).

const PILE_KG := 6.0
const PILE_SIZE := Vector3(0.36, 0.5, 0.28)
const PILE_AT := Vector3(0.6, 0, 0.3)
## The pile hits something this fast, not in anyone's hands: it scatters.
const DROP_SPEED := 3.5
## How close to the copier's middle (ignoring height) the pile has to get.
const COPIER_REACH := 1.6
const PAPER := Color(0.98, 0.98, 0.95)

var office: FormsOffice
var case: CrimeSceneCase
## He saw the thief: the witness is one of the case's clues.
var knows := false
var offended := false
var delivered := false
var pile: Grabbable


func _ready() -> void:
	who = "intern"
	super()
	part("papers").hide()
	pile = Grabbable.new()
	pile.name = "BenjaPapers"
	pile.mass = PILE_KG
	pile.collision_layer = 4
	pile.collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = PILE_SIZE
	shape.shape = box
	shape.position.y = PILE_SIZE.y / 2
	pile.add_child(shape)
	var builder := PlaceBuilder.new(pile)
	for i in 5:
		builder.mesh_box(Vector3((i % 2) * 0.02 - 0.01, 0.05 + i * 0.1, 0), Vector3(0.34, 0.09, 0.26), PAPER)
	pile.position = position + PILE_AT.rotated(Vector3.UP, rotation.y)
	get_parent().add_child.call_deferred(pile)


## E on him: he asks for his pile at the copier, then says what he saw (if he saw it), or that he's offended. Without
## a case, his lines.
func use(cop: Cop) -> void:
	if not case:
		super(cop)
	elif offended:
		say("OFFICE_INTERN_OFFENDED")
	elif not delivered:
		say("OFFICE_INTERN_ASK", 5.0)
	elif knows:
		case.found("witness")
		say("OFFICE_INTERN_SAW_GLASSES" if case.culprit().glasses else "OFFICE_INTERN_SAW_NO_GLASSES", 6.0)
	else:
		say("OFFICE_INTERN_NOTHING")


func cuffed(_seconds: float) -> void:
	offend()


func offend() -> void:
	if offended:
		return
	offended = true
	say("OFFICE_INTERN_OFFENDED")
	if knows:
		case.ruin("witness")


func _physics_process(delta: float) -> void:
	super(delta)
	# Online the host's Benja decides when his pile got there.
	if not office or not is_instance_valid(pile) or not pile.is_inside_tree() or delivered or offended \
			or (case and case.follower):
		return
	var at := office.to_local(pile.global_position)
	var off := at - FormsOffice.COPIER_AT
	if office.floor_of(pile.global_position + Vector3.UP * 0.1) == 0 and Vector2(off.x, off.z).length() <= COPIER_REACH:
		delivered = true
		say("OFFICE_INTERN_THANKS")
	elif not pile.is_held() and pile.linear_velocity.length() > DROP_SPEED:
		offend()
