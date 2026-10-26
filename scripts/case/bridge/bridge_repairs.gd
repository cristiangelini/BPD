class_name BridgeRepairs
extends Node

## Fixing the bridge (politico-puente.md, step 4, decision 178): SPARES spare planks lie in two piles by the builders'
## pickup. A loose plank (a spare, or one fished out of the canal) let go of with its middle within SNAP of an empty
## plank's place on the deck fits in with a "toc" (`fitted`). In the canal the water holds loose things up and slows
## them, and slows the cops wading in it (BankWater's numbers). Every number here is (propuesta).

signal fitted(span: int, slot: int)

const SPARES := 12
const PILE_AT := Vector3(-17.9, 0, 13)
const PILE_STEP := 2.8
## How far from a plank's place (along the bridge, across it, and up or down) its middle can be to fit.
const SNAP := Vector3(0.5, 0.6, 0.6)
## Faster than this it's still flying.
const SNAP_SPEED := 3.0

var park: BridgePark
var breaks: BridgeBreaks
var spares: Array[LoosePlank] = []
var fits := 0


func setup(the_park: BridgePark, the_breaks: BridgeBreaks) -> void:
	park = the_park
	breaks = the_breaks


func _ready() -> void:
	for i in SPARES:
		var spare := LoosePlank.new()
		spare.name = "Spare%d" % i
		var pile := i / (SPARES / 2)
		var level := i % (SPARES / 2)
		spare.position = PILE_AT + Vector3(0, BridgePark.PLANK.y * (level + 0.5) + 0.02, (pile - 0.5) * PILE_STEP)
		park.add_child.call_deferred(spare)
		spares.append(spare)


## The loose planks there are: spares and fallen ones.
func loose() -> Array[LoosePlank]:
	var list: Array[LoosePlank] = []
	for node in park.get_children():
		if node is LoosePlank and not node.is_queued_for_deletion():
			list.append(node)
	return list


func _physics_process(_delta: float) -> void:
	var host := multiplayer.is_server()
	for plank in loose():
		if not host:
			break
		# Only one a cop carried: not the ones just falling off.
		if plank.was_held and plank.holders.is_empty() and plank.linear_velocity.length() < SNAP_SPEED:
			if _try_fit(plank):
				continue
		_float(plank)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if "wade" in cop:
			cop.wade = BankWater.factor(_depth(cop.global_position))


## How deep the canal's water is over `at` (0 out of it).
func _depth(at: Vector3) -> float:
	if not park.in_water(at):
		return 0.0
	return BridgePark.WATER_TOP - park.to_local(at).y


func _try_fit(plank: LoosePlank) -> bool:
	var at := park.to_local(plank.global_position)
	for span in BridgePark.SPANS:
		for slot in BridgePark.PLANKS_PER_SPAN:
			if park.plank(span, slot) != null:
				continue
			var off := (at - BridgePark.plank_at(span, slot)).abs()
			if off.x < SNAP.x and off.y < SNAP.y and off.z < SNAP.z:
				plank.queue_free()
				spares.erase(plank)
				park.restore_plank(span, slot)
				for pillar: int in breaks.sagging:
					if BridgeBreaks.spans_over(pillar).has(span):
						breaks.sag(pillar, BridgeBreaks.SAG)
				fits += 1
				fitted.emit(span, slot)
				return true
	return false


func _float(plank: LoosePlank) -> void:
	if not plank.holders.is_empty():
		return
	var depth := _depth(plank.global_position)
	if depth <= 0.0:
		return
	var under := clampf(depth / BankWater.SUBMERGED + 0.5, 0.0, 1.0)
	plank.apply_central_force(Vector3.UP * plank.mass * GameScale.GRAVITY * BankWater.BUOYANCY * under
		- plank.linear_velocity * plank.mass * BankWater.DRAG * under)
