class_name FoamCakesRig
extends CakeLabRig

## The foam cakes (laboratorio.md, "Los pasteles de espuma"): the chef won every cake contest with fakes made of foam,
## that look perfect and nobody can eat. The box with the fakes' mold is the main evidence (4 kg), hidden with the
## contest diploma and the cream spray. And half the showcase is foam, drawn with the seed: those cakes never squash,
## they bounce with a "boing". The story's own clue: the first time one bounces. Every number here is (propuesta).

signal bounced(cake: Ornament)

const FOAM := 4
const BOUNCE := 0.85
## A foam cake touching something faster than this bounced (the clue).
const BOUNCE_SPEED := 1.0

var foam: Array[Ornament] = []
var bounces := 0


func setup(place: CakeLab) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 7 + 1
	var order: Array = range(place.cakes.size())
	for i in order.size():
		var j := rng.randi_range(i, order.size() - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	var springy := PhysicsMaterial.new()
	springy.bounce = BOUNCE
	for k: int in order.slice(0, FOAM):
		var cake := place.cakes[k]
		cake.unbreakable = true
		cake.mass = 0.3
		cake.physics_material_override = springy
		cake.body_entered.connect(func(_body: Node) -> void: _touched(cake))
		foam.append(cake)


func is_foam(cake: Ornament) -> bool:
	return foam.has(cake)


func _touched(cake: Ornament) -> void:
	if cake.linear_velocity.length() < BOUNCE_SPEED:
		return
	bounces += 1
	lab.raid.float_label(tr("FOAM_BOING"), cake.global_position, Color(0.95, 0.85, 0.3))
	if bounces == 1:
		lab.raid.add_clue(tr("CLUE_FOAM_BOUNCE"))
	bounced.emit(cake)
