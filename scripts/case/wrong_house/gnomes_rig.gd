class_name WhGnomesRig
extends WrongHouseRig

## The neighborhood's gnomes (casa-equivocada.md, "Los gnomos del barrio"): Don Ramón, the gardener, took every garden
## gnome on the block. GNOMES of them stand in two rows in his back yard, all alike, and one, drawn with the seed, is
## of gold: the main evidence, three times as heavy (it says so when grabbed). The others break like ornaments. The
## list of robbed gardens and the wheelbarrow are the extras. The story's own clue: gnome-shaped holes in doña Chola's
## garden. Every number here is (propuesta).

const GNOME_SCENE := preload("res://scenes/props/garden_gnome.tscn")
const GOLD_SCENE := preload("res://scenes/props/gold_gnome.tscn")
const GNOMES := 20
## The two rows across his back yard (house space), clear of his way from the back door to the side passage.
const ROWS: Array[float] = [-7.0, -8.6]
const ROW_START := -6.3
const ROW_STEP := 1.4
## The holes in doña Chola's front garden (house space).
const HOLES: Array[Vector3] = [Vector3(-0.5, 0, 8.2), Vector3(3.0, 0, 9.3), Vector3(5.2, 0, 8.0)]

var gold: Evidence
var gnomes: Array[Ornament] = []


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	var gold_at := gold_spot(place.case_seed)
	for i in GNOMES:
		var gnome: RigidBody3D = GOLD_SCENE.instantiate() if i == gold_at else GNOME_SCENE.instantiate()
		gnome.position = WrongHouse.at(place.guilty, gnome_at(i))
		# They face the house.
		gnome.rotation.y = 0.0
		place.add_child(gnome)
		if gnome is Ornament:
			(gnome as Ornament).broken.connect(place._on_ornament_broken.bind(place.guilty))
			gnomes.append(gnome)
		else:
			gold = gnome
	place.main = gold
	var holes: Array[Node3D] = []
	for at in HOLES:
		var hole := Node3D.new()
		hole.position = WrongHouse.at(place.chola_house(), at + Vector3(0, WrongHouse.GRASS_TOP, 0))
		place.add_child(hole)
		patch(hole, Vector3(0, 0.005, 0), Vector3(0.3, 0.01, 0.3), Color(0.35, 0.24, 0.14))
		holes.append(hole)
	clue_spot(holes[0].position + Vector3(0, 0.05, 0), Vector3(0.36, 0.1, 0.36), "PROMPT_LOOK_HOLE", "CLUE_WH_GNOME_HOLES")


## Where gnome i stands, in house space: ten to a row.
static func gnome_at(i: int) -> Vector3:
	return Vector3(ROW_START + (i % 10) * ROW_STEP, WrongHouse.GRASS_TOP + 0.01, ROWS[i / 10])


## Which of the gnomes is the gold one, from the seed.
static func gold_spot(case_seed: int) -> int:
	return hash(["wrong house gold gnome", case_seed]) % GNOMES
