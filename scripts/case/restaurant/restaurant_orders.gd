class_name RestaurantOrders
extends Node3D

## The Chef Flambé's orders (infiltracion-restaurante.md, step 4, decision 174): FIRST seconds in and then every EVERY
## seconds he shouts an order and hangs it on the rail over the pass; there are DEADLINE seconds to leave the dish on
## the pass's counter and ring the bell. The bell judges every plate on the counter against the oldest order it
## doesn't make: right and on time, "¡Eso!" and a waiter takes it; wrong (something missing or extra, raw or burnt) the
## order is lost too. A lost order (wrong, burnt or late) makes the cooks who see the kitchen suspicious (`failed`, to
## RestaurantHall), more when it was burnt. The host decides all of it and tells the guests. Every number here is
## (propuesta).

signal ordered(dish: String)
signal served(dish: String)
signal failed(amount: float)

## What goes in each dish: kind -> [the vessel it's cooked in ("" raw, added on the plate), the least seconds on the
## fire]. A dish has exactly these, one of each, and nothing burnt.
const RECIPES := {
	"soup": {"tomato": ["pot", 6.0], "onion": ["pot", 6.0]},
	"salad": {"lettuce": ["", 0.0], "tomato": ["", 0.0]},
	"fish": {"fish": ["pan", 4.0]},
	"pasta": {"pasta": ["pot", 5.0], "tomato": ["", 0.0]},
}
const DISHES: Array[String] = ["soup", "salad", "fish", "pasta"]
const FIRST := 20.0
const EVERY := 40.0
const DEADLINE := 60.0
## The Chef warns this long before an order runs out.
const HURRY := 15.0
const WRONG := 20.0
const BURNT := 30.0
const MAX_OPEN := 3

## The orders hanging on the rail, oldest first: {id, dish, left (s)} (every PC).
var orders: Array[Dictionary] = []
## Seconds to the next order (host).
var next_left := FIRST
var case_seed := 0
var chef: ClubMember
## The plates standing on the pass's counter (RestaurantHall sets it).
var plates_on_pass: Callable = func() -> Array[KitchenVessel]: return []
## Whether a world position is where the orders are seen: the kitchen and the rooms behind it.
var inside: Callable = func(_at: Vector3) -> bool: return false
var _rng := RandomNumberGenerator.new()
var _made := 0
var _rail: Label3D
var _hud: CanvasLayer
var _list: Label


func _ready() -> void:
	add_to_group("restaurant_orders")
	_rng.seed = hash(["restaurant orders", case_seed])
	_rail = Label3D.new()
	_rail.font_size = 40
	_rail.pixel_size = 0.004
	_rail.outline_size = 10
	_rail.double_sided = false
	_rail.modulate = Color(1, 0.95, 0.8)
	_rail.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(_rail)
	_build_hud()
	_refresh()


## The dish's name key, for the rail and the Chef.
static func dish_key(dish: String) -> String:
	return "DISH_" + dish.to_upper()


## What a plate with `items` is for `dish`: "good", "burnt", "raw" (the right things, not cooked enough) or "wrong".
static func judge(dish: String, items: Array[Dictionary]) -> String:
	if items.any(func(item: Dictionary) -> bool: return item.burnt):
		return "burnt"
	var recipe: Dictionary = RECIPES[dish]
	if items.size() != recipe.size():
		return "wrong"
	var raw := false
	var seen := {}
	for item in items:
		if not recipe.has(item.kind) or seen.has(item.kind):
			return "wrong"
		seen[item.kind] = true
		var needs: Array = recipe[item.kind]
		if item["in"] != needs[0]:
			return "wrong"
		if item.cooked < needs[1]:
			raw = true
	return "raw" if raw else "good"


## Host: a new order on every PC (the next dish drawn with the seed, or this one: tests and the debug panel).
func order(dish := "") -> void:
	next_left = EVERY
	if orders.size() >= MAX_OPEN:
		return
	if dish.is_empty():
		dish = DISHES[_rng.randi_range(0, DISHES.size() - 1)]
	orders.append({"id": _made, "dish": dish, "left": DEADLINE})
	_made += 1
	ordered.emit(dish)
	_tell("FLAMBE_ORDER", dish)


## Host: the bell. Every plate on the pass goes out against an order, right or wrong.
func ring(cop: Cop = null) -> void:
	var plates: Array[KitchenVessel] = plates_on_pass.call().filter(func(plate: KitchenVessel) -> bool:
		return not plate.items.is_empty())
	if plates.is_empty():
		if cop:
			cop.show_hint("HINT_PASS_EMPTY")
		_tell("FLAMBE_NO_DISH")
		return
	if orders.is_empty():
		_tell("FLAMBE_NO_ORDER")
		return
	var line := ""
	for plate in plates:
		if orders.is_empty():
			break
		var at := orders.find_custom(func(open: Dictionary) -> bool: return judge(open.dish, plate.items) == "good")
		if at != -1:
			var dish: String = orders[at].dish
			orders.remove_at(at)
			served.emit(dish)
			line = "FLAMBE_GOOD"
		else:
			var verdict := judge(orders[0].dish, plate.items)
			orders.remove_at(0)
			failed.emit(BURNT if verdict == "burnt" else WRONG)
			line = "FLAMBE_" + verdict.to_upper()
		plate.items.clear()
		plate._changed()
	_tell(line)


func _process(delta: float) -> void:
	for open in orders:
		var was: float = open.left
		open.left = maxf(open.left - delta, 0.0)
		if multiplayer.is_server() and was > HURRY and open.left <= HURRY:
			_tell("FLAMBE_HURRY", open.dish)
	if multiplayer.is_server():
		next_left -= delta
		if next_left <= 0.0:
			order()
		if not orders.is_empty() and orders[0].left <= 0.0:
			orders.remove_at(0)
			failed.emit(WRONG)
			_tell("FLAMBE_LATE")
	_refresh()


## Host: the Chef says `line` (about `dish`, if it has one) and every PC gets the rail as it is now.
func _tell(line: String, dish := "") -> void:
	_say(line, dish)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_orders_now.rpc_id(peer, orders, line, dish)


@rpc("authority", "call_remote", "reliable")
func _orders_now(now: Array, line: String, dish: String) -> void:
	orders.assign(now)
	_say(line, dish)


func _say(line: String, dish: String) -> void:
	if chef and not line.is_empty():
		chef.say(tr(line) % tr(dish_key(dish)) if RECIPES.has(dish) else line)
	_refresh()


## The rail's tickets and, for a cop in the kitchen, the same list on screen.
func _refresh() -> void:
	var lines := PackedStringArray()
	for open in orders:
		lines.append("%s  %d" % [tr(dish_key(open.dish)), ceili(open.left)])
	_rail.text = "\n".join(lines)
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = not orders.is_empty() and cop != null and inside.call(cop.global_position)
	if _hud.visible:
		_list.text = tr("HUD_ORDERS") + "\n" + _rail.text


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_list = Label.new()
	_list.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_list.position = Vector2(-300, 90)
	_list.custom_minimum_size = Vector2(280, 0)
	_list.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_list.add_theme_font_size_override("font_size", 24)
	_list.add_theme_constant_override("outline_size", 8)
	_list.add_theme_color_override("font_outline_color", Color.BLACK)
	_hud.add_child(_list)
	_hud.hide()
	add_child(_hud)


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net
