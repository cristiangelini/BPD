class_name LotteryRig
extends BakeryRig

## The sweet bread lottery (panaderia.md, "La lotería del pan"): Marta raffles ten sweet breads with a number in sugar
## on top, cooling on the kneading table, and the winning ticket she kept is baked into one of them. The list of
## numbers, hidden in the bakery, says which one. Every number here is (propuesta).

const SWEET_SCENE := preload("res://scenes/props/sweet_bread.tscn")
const TICKET_SCENE := preload("res://scenes/props/lottery_ticket.tscn")
const COUNT := 10
## Two rows of five on the kneading table, clear of the clue note that can lie at its west end.
const TABLE_TOP := 0.91
const ROW_X := [2.95, 3.85, 4.25, 4.65, 5.05]
const ROW_Z := [-2.75, -2.25]
const HALF_HEIGHT := 0.07

var sweets: Array[Bread] = []
## The winning sweet bread's number (1 to COUNT).
var winning := 0


func setup(place: Bakery) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 17 + 3
	winning = rng.randi_range(1, COUNT)
	for i in COUNT:
		var sweet: Bread = SWEET_SCENE.instantiate()
		sweet.position = Vector3(ROW_X[i % ROW_X.size()], TABLE_TOP + HALF_HEIGHT + 0.01, ROW_Z[i / ROW_X.size()])
		sweet.add_child(_number(i + 1))
		place.add_child(sweet)
		sweet.broken.connect(place._on_goods_broken)
		sweets.append(sweet)
	place.main = TICKET_SCENE.instantiate()
	sweets[winning - 1].stuff(place.main, false)
	for extra in place.extras:
		if extra is NumberList:
			(extra as NumberList).winning = winning


## The number painted in sugar on top of a sweet bread.
func _number(n: int) -> Label3D:
	var label := Label3D.new()
	label.text = str(n)
	label.position.y = HALF_HEIGHT + 0.005
	label.rotation.x = -PI / 2
	label.pixel_size = 0.002
	label.font_size = 64
	label.outline_size = 6
	label.outline_modulate = Color(0.55, 0.3, 0.1)
	return label
