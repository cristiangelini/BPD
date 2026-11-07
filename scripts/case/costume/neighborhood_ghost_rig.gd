class_name NeighborhoodGhostRig
extends CostumeRig

## The neighborhood's ghost (allanamiento-disfraces.md, "El fantasma del barrio"): at night Don Fantoche dresses as a
## ghost with chains and scares the neighbors so they sell him their houses cheap. The ghost costume (6 kg, the main
## evidence), the howl recorder and the list of the neighborhood's houses are hidden. E on the light switch by the
## counter turns the shop's lights off: then a white costume on the monsters rack glows in the dark, and looking at it
## is the story's clue. The customers, neighbors of the block, come out of the fitting rooms talking about the ghost.
## Every number here is (propuesta).

const SWITCH_MODEL := preload("res://assets/models/costume_switch.glb")
## The switch on the east wall by the counter, facing the shop.
const SWITCH_AT := Vector3(CostumeShop.HALF_X - PlaceBuilder.WALL / 2 - 0.02, CostumeShop.FLOOR_TOP + 1.3, 7.6)
## The glowing costume, the last one on the monsters rack (RACKS[2]).
const GLOW_AT := Vector3(4.18, CostumeShop.FLOOR_TOP + 1.12, -2.0)
const GLOW_SIZE := Vector3(0.14, 1.0, 0.52)
## How much sky light is left inside with the lamps off, and how much the eye takes in.
const DARK_AMBIENT := 0.02
const DARK_EXPOSURE := 0.45
## What Don Fantoche adds each time he sees the lights go off.
const LIGHTS_OFF := 5.0
const TALK: Array[String] = ["CUSTOMER_GHOST_1", "CUSTOMER_GHOST_2", "CUSTOMER_GHOST_3"]

var dark := false
var lamps: Array[OmniLight3D] = []
var glow: GlowSpot
var switch: LightSwitch
var _glow_look: StandardMaterial3D
var _ambient := 0.0
var _exposure := 0.0
var _talks := 0


func setup(place: CostumeShop) -> void:
	super.setup(place)
	for lamp: Node in place.get_node("Built").find_children("*", "OmniLight3D", false, false):
		lamps.append(lamp)
	# Its own copy: the scene's environment is shared by every shop instance.
	var world: WorldEnvironment = place.get_node("Environment")
	world.environment = world.environment.duplicate()
	_ambient = world.environment.ambient_light_energy
	_exposure = world.environment.tonemap_exposure
	switch = LightSwitch.new()
	switch.rig = self
	switch.position = SWITCH_AT
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.1, 0.25, 0.2)
	shape.shape = box
	switch.add_child(shape)
	var look: Node3D = SWITCH_MODEL.instantiate()
	switch.add_child(look)
	place.add_child(switch)
	glow = GlowSpot.new()
	glow.rig = self
	glow.size = GLOW_SIZE
	glow.prompt = "PROMPT_GLOW_COSTUME"
	glow.text = tr("CLUE_GHOST_GLOW")
	glow.position = GLOW_AT
	glow.read.connect(place.raid.add_clue)
	var costume := MeshInstance3D.new()
	var sheet := BoxMesh.new()
	sheet.size = GLOW_SIZE
	_glow_look = StandardMaterial3D.new()
	_glow_look.albedo_color = Color(0.96, 0.96, 0.94)
	_glow_look.emission = Color(0.4, 1.0, 0.55)
	_glow_look.emission_energy_multiplier = 4.0
	sheet.material = _glow_look
	costume.mesh = sheet
	glow.add_child(costume)
	place.add_child(glow)
	for customer: CostumeCustomer in place.customers:
		customer.came_out.connect(_on_came_out)


## The lamps off (the costume glows) or on again.
func set_dark(on: bool) -> void:
	dark = on
	for lamp in lamps:
		lamp.visible = not on
	var world: WorldEnvironment = shop.get_node("Environment")
	world.environment.ambient_light_energy = DARK_AMBIENT if on else _ambient
	world.environment.tonemap_exposure = DARK_EXPOSURE if on else _exposure
	_glow_look.emission_enabled = on
	if on and shop.owner_boss:
		shop.owner_boss.blame(LIGHTS_OFF, "FANTOCHE_LIGHTS")


func _on_came_out(customer: CostumeCustomer) -> void:
	customer.say(TALK[_talks % TALK.size()])
	_talks += 1


## The light switch by the counter.
class LightSwitch:
	extends StaticBody3D

	var rig: NeighborhoodGhostRig

	func prompt_key(_cop: Cop) -> String:
		return "PROMPT_LIGHTS_ON" if rig.dark else "PROMPT_LIGHTS_OFF"

	func use(_cop: Cop) -> void:
		rig.set_dark(not rig.dark)


## The white costume on the monsters rack: only something to look at while it glows in the dark.
class GlowSpot:
	extends ClueSpot

	var rig: NeighborhoodGhostRig

	func prompt_key(cop: Cop) -> String:
		return super.prompt_key(cop) if rig.dark else "PROMPT_GRAB"

	func use(cop: Cop) -> void:
		if rig.dark:
			super.use(cop)
