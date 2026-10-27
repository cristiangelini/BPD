class_name FixedFightsRig
extends GymRaidRig

## The ring of fixed fights (allanamiento-gimnasio.md, "El ring de las peleas arregladas"): el profe fixes the
## Saturday fights in his ring and takes the bets. The hall's punching bags can be punched (E): they swing and shove
## whoever is right behind them, and one of them (drawn with the seed) clangs like metal, the story's own clue (on the
## checklist the first time). The betting book, the gloves with a horseshoe inside and the cardboard champion belt are
## hidden. Every number here is (propuesta).

var bags: Array[GymPunchBag] = []
var metal := -1


func setup(place: GymRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["fixed fights", place.case_seed])
	metal = rng.randi_range(0, GymHall.BAGS.size() - 1)
	var built: Node3D = place.get_node("Built")
	for i in GymHall.BAGS.size():
		var at := GymHall.BAGS[i] + Vector3(0, GymHall.FLOOR_TOP, 0)
		var bag := GymPunchBag.new()
		bag.name = "PunchBag%d" % i
		bag.position = at
		bag.metal = i == metal
		for child in built.get_children():
			if child is Node3D and not child is MeshInstance3D and (child as Node3D).position.is_equal_approx(at):
				bag.look = child
		place.add_child(bag)
		bag.punched.connect(func(_cop: Cop) -> void:
			if bag.metal and bag.punches == 1:
				place.raid.add_clue(tr("CLUE_BAG_CLANG")))
		bags.append(bag)
