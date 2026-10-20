class_name Armero
extends StaticBody3D

## The armero behind the armory counter (docs/diseno/comisaria.md, "La armería"): E on him opens his list for that
## cop, to buy with the common cash box and take what the station owns.

const MODEL := preload("res://assets/models/npc_armero.glb")

## Spends the campaign's cash box when there is one (solo or hosting), else a cash box for this shift only.
var armory := Armory.new(Campaign.current if Campaign.current else StationWallet.new())
var menu: ArmoryMenu


func _ready() -> void:
	add_child(MODEL.instantiate())
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	menu = ArmoryMenu.new()
	add_child(menu)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ARMERO"


## Online E on him happens on every PC, but the list only opens on the screen of the cop who asked.
func use(cop: Cop) -> void:
	if not cop.sync or cop.sync.is_multiplayer_authority():
		menu.open(armory, cop)


## A row chosen on the list (ArmoryMenu), through Cop.act. The host (or solo) decides with the common cash box and
## tells the guests what came of it (armory_given). Returns "" or the hint key.
func armory_choose(cop: Cop, id: String) -> String:
	if cop.sync and not cop.sync.net.is_host():
		return ""
	var owned := armory.owns(id)
	var error := armory.choose(id, cop)
	if cop.sync:
		cop.sync.net.actions.tell_guests(cop, "armory_given", self, [id, error, owned])
	_answer(cop, error, owned)
	return error


## Guests: what the host's armory did for `cop`. The cash box itself comes with NpcSync.
func armory_given(cop: Cop, id: String, error: String, owned: bool) -> void:
	if error == "" and owned:
		match id:
			"ram":
				cop.equip_ram()
			"gloves":
				cop.put_on_gloves()
			"wheelbarrow":
				armory.wheelbarrow = Armory.WHEELBARROW_SCENE.instantiate()
				cop.get_parent().add_child(armory.wheelbarrow)
				armory.wheelbarrow.push(cop)
	_answer(cop, error, owned)


func _answer(cop: Cop, error: String, owned: bool) -> void:
	if menu.visible and menu.cop == cop:
		menu.show_result(error, owned)


## Online: the cash box and what the station owns, from the host to the guests' list (NpcSync).
func net_state() -> Variant:
	return [armory.wallet.money, armory.wallet.items.duplicate()]


func apply_net_state(state: Variant) -> void:
	armory.wallet.money = state[0]
	armory.wallet.items.assign(state[1])
	if menu.visible:
		menu.redraw()
