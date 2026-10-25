class_name FakeCaptainRig
extends FactoryRig

## The knockoff Captain Galaxy (fabrica.md, "El Capitán Galaxia trucho"): Fermín stole the competitor's mold of its
## best-selling doll and makes copies. The mold is the main evidence (15 kg, it jams the belt if put on it), hidden with
## the fake labels and the prototype photos. Every second doll the belt gets comes out with an astronaut helmet, and the
## reject dumpster holds REJECTS of them with their faces painted crooked: looking at one is the story's own clue.
## Every number here is (propuesta).

const REJECT_SCENE := preload("res://scenes/props/reject_captain.tscn")
const REJECTS := 3

var rejects: Array[ClueNote] = []
var _fed := 0


func setup(place: DollFactory) -> void:
	super.setup(place)
	place.fed_doll.connect(_on_fed)
	for i in REJECTS:
		var reject: ClueNote = REJECT_SCENE.instantiate()
		reject.text = tr("CLUE_REJECT_CAPTAINS")
		reject.position = DollFactory.DUMPSTER_AT + Vector3(-0.5 + i * 0.5, 0.2, 0.1 * (i - 1))
		reject.rotation = Vector3(PI / 2, i * 1.3, 0)
		place.add_child(reject)
		reject.read.connect(place.raid.add_clue)
		rejects.append(reject)


## Every second doll dropped onto the belt is a Captain Galaxy: it gets the helmet.
func _on_fed(doll: Node3D) -> void:
	_fed += 1
	if _fed % 2 == 0:
		(doll as FactoryDoll).wear("captain")
