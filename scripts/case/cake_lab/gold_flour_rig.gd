class_name GoldFlourRig
extends CakeLabRig

## The gold flour (laboratorio.md, "La harina de oro"): the chef smuggles gold dust mixed in his flour. The sack with
## the gold is the main evidence (10 kg), standing among the real ones in the storeroom in a place drawn with the seed,
## identical to them and with no value shown until a cop picks it up; the golden sieve and the jeweler's invoice are
## hidden. The story's own clue: the sack leaks a little gold flour by the aisle, and a cop who steps in it leaves
## golden footprints. Bursting a real sack still leaves its blinding cloud. Every number here is (propuesta).

const SACK_SCENE := preload("res://scenes/props/gold_flour_sack.tscn")
## The leak, on the aisle side of the gold sack.
const LEAK_OFFSET := Vector3(1.3, 0, 0)

var sack: Evidence
## Which of the lab's ten sacks it took the place of.
var replaced := 0
var _label: Label3D


func setup(place: CakeLab) -> void:
	super.setup(place)
	replaced = place.case_seed % place.sacks.size()
	var real := place.sacks[replaced]
	sack = SACK_SCENE.instantiate()
	sack.position = real.position
	place.sacks.remove_at(replaced)
	real.queue_free()
	place.add_child(sack)
	place.main = sack
	_label = sack.get_node("ValueLabel")
	_label.visible = false
	var floor_at := Vector3(sack.position.x, CakeLab.FLOOR_TOP, sack.position.z) + LEAK_OFFSET
	place.flour.spill(floor_at, true, INF)
	place.flour.gilded.connect(func(cop: Cop) -> void:
		cop.show_hint("HINT_GOLD_FLOUR")
		place.raid.add_clue(tr("CLUE_GOLD_PRINTS")))


func _physics_process(_delta: float) -> void:
	if not _label.visible and is_instance_valid(sack) and sack.is_held():
		_label.visible = true
