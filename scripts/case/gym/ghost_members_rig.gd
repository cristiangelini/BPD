class_name GhostMembersRig
extends GymRaidRig

## The ghost members (allanamiento-gimnasio.md, "Los socios fantasma"): the gym bills the city for 300 members who don't
## exist, and to make the hall look full el profe set shop dummies to "train". Three of the six members (drawn with the
## seed) are mannequins: they don't answer, they don't bounce in the class, and a cop who bumps into one fast knocks it
## over stiff as a board, the story's own clue (on the checklist the first time). The binder with the 300 invented
## members, the box of dummies and the fake stamp are hidden. Every number here is (propuesta).

signal toppled(mannequin: ClubMember)

const LOOK := "gym_mannequin"
const MANNEQUINS := 3
const BUMP_SPEED := 2.0
const FALL_TIME := 0.35

var mannequins: Array[ClubMember] = []
var fallen := {}


func setup(place: GymRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["ghost members", place.case_seed])
	var picks: Array = range(place.members.size())
	for i in MANNEQUINS:
		var index: int = picks.pop_at(rng.randi_range(0, picks.size() - 1))
		var member := place.members[index]
		var mannequin := ClubMember.new()
		mannequin.name = member.name
		mannequin.look = LOOK
		mannequin.transform = member.transform
		place.remove_child(member)
		member.queue_free()
		place.add_child(mannequin)
		place.members[index] = mannequin
		_watch_bumps(mannequin)
		mannequins.append(mannequin)


## Knocks `mannequin` over backwards, stiff, once; the first one is the clue.
func topple(mannequin: ClubMember) -> void:
	if fallen.has(mannequin):
		return
	fallen[mannequin] = true
	var tween := mannequin.create_tween()
	tween.tween_property(mannequin, "rotation:x", -PI / 2, FALL_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	gym.raid.float_label(tr("GYM_MANNEQUIN_FELL"), mannequin.global_position + Vector3.UP * 1.6, Color(1, 1, 1))
	if fallen.size() == 1:
		gym.raid.add_clue(tr("CLUE_MANNEQUIN_STIFF"))
	toppled.emit(mannequin)


func _watch_bumps(mannequin: ClubMember) -> void:
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 6
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.55
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	area.add_child(shape)
	mannequin.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		var speed := 0.0
		if body is Cop:
			speed = (body as Cop).velocity.length()
		elif body is RigidBody3D:
			speed = (body as RigidBody3D).linear_velocity.length()
		if speed > BUMP_SPEED:
			topple(mannequin))
