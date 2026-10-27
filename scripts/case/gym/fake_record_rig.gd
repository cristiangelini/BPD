class_name FakeRecordRig
extends GymRaidRig

## The fake record (allanamiento-gimnasio.md, "El récord falso"): el profe's "300 kg" record bar on the record wall is
## polystyrene, and the record brings members who pay double to train with the champion. The bar itself is the main
## evidence (2 kg, it bounces): it hangs on its hooks until a cop grabs it, and that first lift is the story's own clue
## (it goes up with one hand). A real 40 kg bar lies by the benches to compare it with. The doctored photo and the
## contest certificate are hidden. Every number here is (propuesta).

const BAR_SCENE := preload("res://scenes/props/fake_record_bar.tscn")
const REAL_BAR_KG := 40.0
const REAL_BAR_SIZE := Vector3(1.8, 0.44, 0.44)
## The real bar on the floor by the benches, along x.
const REAL_BAR_AT := Vector3(-3.2, GymHall.FLOOR_TOP + 0.23, 1.0)

var bar: Evidence
var real_bar: Grabbable
var lifted := false


func setup(place: GymRaid) -> void:
	super.setup(place)
	place.record_bar_look.hide()
	bar = BAR_SCENE.instantiate()
	bar.name = "RecordBar"
	bar.position = GymRaid.RECORD_BAR_AT
	bar.rotation.y = PI / 2
	bar.freeze = true
	place.add_child(bar)
	place.main = bar
	real_bar = ClubEvidence.make_item("RealBar", GymRaid.RECORD_BAR_MODEL, REAL_BAR_SIZE, REAL_BAR_KG)
	real_bar.position = REAL_BAR_AT
	place.add_child(real_bar)


## The first cop to grab the bar takes it off its hooks, and it goes up with one hand.
func _physics_process(_delta: float) -> void:
	if lifted or not bar.is_held():
		return
	lifted = true
	# Online only the host simulates it; a guest's copy stays frozen and follows (PropSync).
	bar.freeze = not multiplayer.is_server()
	gym.raid.add_clue(tr("CLUE_RECORD_ONE_HAND"))
	gym.raid.float_label(tr("GYM_RECORD_LIGHT"), bar.global_position + Vector3.UP * 0.6, Color(1, 1, 1))
