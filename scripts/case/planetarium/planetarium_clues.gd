class_name PlanetariumClues
extends Node

## The planetarium case's clues where they go (escena-planetario.md, "Las pistas"), put by Planetarium when the case
## comes: the prints on El Pedrusco's display case (Doctor Órbita polishes it after a while, and they're gone), the
## moon-boot print that glows in the dome room (GlowPrint, only in the dark), the hair in the helmet forgotten in the
## control room (the robot vacuum gets it after a while), the bitten astronaut ice cream inside the kids' rocket (a
## school visit comes, and a kid eats it) and the photo booth's last photo. The glow paint shows on the guides' gloves,
## and Doña Nebulosa comes in the next step. Every number here is (propuesta).

## The robot vacuum goes through the control room this long after the cops get there, in seconds; Doctor Órbita
## polishes the display case and the school visit comes later.
const VACUUM_SECONDS := 180.0
const POLISH_SECONDS := 240.0
## Where the glowing print can be: in the dome room, off the ring of seats.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(-1.0, 0, -1.5), Vector3(-6.5, 0, -2.0), Vector3(2.5, 0, -9.5)]
## The helmet forgotten on the control room's chair.
const HELMET_AT := Vector3(11.0, 0.5, -6.5)

var planetarium: Planetarium
var case: CrimeSceneCase
var glass: EmptyFrame
var footprint: GlowPrint
var ice_cream: CrimeClueItem
var has_bite := false
## Whether a search of the rocket brought the ice cream out.
var ice_cream_out := false
var has_photo := false
## Someone took a new photo in the booth: the 3 a.m. one is covered.
var photo_covered := false
var _elapsed := 0.0


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	glass = EmptyFrame.new(Vector2(0.9, 0.8))
	glass.name = "CaseGlass"
	glass.look = "METEORITE"
	glass.case = case
	glass.has_prints = plan.clues.has("prints")
	glass.position = Planetarium.CASE_AT + Vector3(0, 1.4, 0.47)
	planetarium.add_child(glass)
	if plan.clues.has("footprint"):
		footprint = GlowPrint.new()
		footprint.name = "GlowPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		var at: Vector3 = FOOTPRINT_SPOTS[absi(hash(["planetarium footprint", case.case_seed])) % FOOTPRINT_SPOTS.size()]
		footprint.position = at + Vector3(0, Planetarium.FLOOR_TOP - 0.04, 0)
		# The steps point to where the stone went.
		var to := (planetarium.loot_spots[planetarium.loot_spot] as Node3D).position - at
		footprint.rotation.y = atan2(to.x, to.z)
		planetarium.add_child(footprint)
		case.flour_print = footprint
	# The helmet is there in every case; the hair in it only when it's a clue.
	var helmet := MeshInstance3D.new()
	helmet.name = "ForgottenHelmet"
	var dome := SphereMesh.new()
	dome.radius = 0.25
	dome.height = 0.5
	helmet.mesh = dome
	helmet.material_override = PlaceBuilder.new(planetarium).material(Planetarium.WHITE)
	helmet.position = HELMET_AT + Vector3(0, 0.25, 0)
	planetarium.add_child(helmet)
	if plan.clues.has("hair"):
		var hair := CrimeClueItem.new()
		hair.name = "Clue_hair"
		hair.kind = "hair"
		hair.look = "planetarium"
		hair.case = case
		hair.hair_color = CookTraits.HAIRS[who.hair]
		hair.position = HELMET_AT + Vector3(-0.6, -0.44, 0)
		planetarium.add_child(hair)
		case.items["hair"] = hair
	has_bite = plan.clues.has("bite")
	# The ice cream is in the rocket from the start, hidden, so every PC online has the same one.
	if has_bite:
		ice_cream = CrimeClueItem.new()
		ice_cream.name = "Clue_bite"
		ice_cream.kind = "bite"
		ice_cream.look = "planetarium"
		ice_cream.case = case
		planetarium.add_child(ice_cream)
		_hide_ice_cream()
		case.items["bite"] = ice_cream
	has_photo = plan.clues.has("booth")
	planetarium.booth.clues = self
	planetarium.booth_tray.clues = self


## Lights out or back on: the glowing print shows only in the dark.
func set_dark(on: bool) -> void:
	if footprint:
		footprint.set_dark(on)


## A search of a spot is over (Planetarium.searched): in the kids' rocket, the bitten ice cream turns up too.
func searched(spot: String) -> void:
	if spot != "rocket" or not has_bite or ice_cream_out or case.ruined.has("bite"):
		return
	show_ice_cream()


## Out of the rocket, on the floor in front of it, for a cop to bag (also a guest's online, Planetarium.apply_net_state).
func show_ice_cream() -> void:
	ice_cream_out = true
	var body := planetarium.loot_spots["rocket"] as Node3D
	ice_cream.position = Vector3(body.position.x, Planetarium.FLOOR_TOP, body.position.z) + body.get_meta("out") \
		+ Vector3(0, 0, 0.5)
	ice_cream.visible = true
	ice_cream.freeze = false
	ice_cream.collision_layer = 4


## Inside the rocket: not seen, not grabbed, not falling.
func _hide_ice_cream() -> void:
	var body := planetarium.loot_spots["rocket"] as Node3D
	ice_cream.position = Vector3(body.position.x, Planetarium.FLOOR_TOP + 0.1, body.position.z)
	ice_cream.visible = false
	ice_cream.freeze = true
	ice_cream.collision_layer = 0


## E on the booth's tray: the 3 a.m. photo with the culprit's planet pin, if it's a clue and nobody covered it.
func look_at_tray(cop: Cop) -> void:
	if has_photo and not photo_covered:
		case.found("booth")
		if cop:
			cop.show_hint(tr("HINT_BOOTH_3AM") % tr("PLANET_" + str(case.culprit().planet)))
		return
	if cop:
		cop.show_hint("HINT_BOOTH_YOUR_FACE" if photo_covered else "HINT_BOOTH_EMPTY")


## E on the booth: the cop's own face on the Moon, over whatever photo was last.
func take_photo(cop: Cop) -> void:
	photo_covered = true
	if has_photo and not case.clues_found.has("booth"):
		case.ruin("booth")
	if cop:
		cop.show_hint("HINT_BOOTH_FLASH")


func _physics_process(delta: float) -> void:
	if case.follower or not case.at_tent or _elapsed >= POLISH_SECONDS:
		return
	var was := _elapsed
	_elapsed += delta
	if was < VACUUM_SECONDS and _elapsed >= VACUUM_SECONDS:
		vacuum()
	if _elapsed >= POLISH_SECONDS:
		polish()
		school_visit()


## The robot vacuum through the control room: the hair by the helmet goes, unless it's bagged.
func vacuum() -> void:
	var hair := case.items.get("hair") as CrimeClueItem
	if not hair or case.clues_found.has("hair"):
		return
	if not hair.bagged:
		hair.spoiled = true
		hair.visible = false
	case.ruin("hair")


## Doctor Órbita's cloth on El Pedrusco's display case: whatever prints were on it are gone.
func polish() -> void:
	if glass.has_prints and not case.clues_found.has("prints"):
		glass.has_prints = false
		planetarium.director.say("DIRECTOR_POLISH")
		case.ruin("prints")


## A school visit runs through the kids' corner, and a kid finds the ice cream, in the rocket or out of it, unless it's
## bagged.
func school_visit() -> void:
	if not has_bite or case.clues_found.has("bite"):
		return
	if ice_cream and not ice_cream.bagged:
		ice_cream.spoiled = true
		ice_cream.visible = false
	case.ruin("bite")
