class_name PostOfficeClues
extends Node

## The post office case's clues where they go (escena-correo.md, "Las pistas"), put by PostOffice when the case comes:
## the prints on the safe's door (Doña Sellito wipes it to seal it after a while, and they're gone), the footprint in
## the sorting room's dust (DustPrint: the machine's first run uncovers it, the next one covers it), the hair in the cap
## forgotten in the depot (the second run blows it into a sack), the bitten cookie behind the parcel scale (searching
## the scale finds it; Cartita comes down from her perch and eats it after a while) and the letter stamped at 3 in the
## morning in the returns sack (ReturnsSack; anything dropped in the sack covers it). The blue tongue shows on the
## carriers (PostCarrier), and Cartita as a witness comes in the next step. Every number here is (propuesta).

## Cartita comes down from her perch for the cookie this long after the cops get there, in seconds; Doña Sellito wipes
## the safe's door later.
const PARROT_SECONDS := 180.0
const POLISH_SECONDS := 240.0
## Where the footprint can be: in the sorting room, off the machine and the sacks.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(-10.0, 0, -4.0), Vector3(1.5, 0, -4.0), Vector3(-7.0, 0, -10.5)]
## The cap forgotten on the depot's floor, the hair by it.
const CAP_AT := Vector3(10.0, 0, -1.5)
const HAIR_AT := Vector3(9.3, 0, -1.2)

var post_office: PostOffice
var case: CrimeSceneCase
var safe_door: EmptyFrame
var footprint: DustPrint
var hair: CrimeClueItem
## The bitten cookie: made with the case (so every PC has it), hidden behind the scale until someone searches it.
var cookie: CrimeClueItem
var cookie_out := false
var has_letter := false
## Something went into the returns sack before anyone looked: the 3 a.m. letter is under it.
var letter_covered := false
var _elapsed := 0.0


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	safe_door = EmptyFrame.new(Vector2(1.0, 1.2))
	safe_door.name = "SafeDoorPrints"
	safe_door.look = "POSTSAFE"
	safe_door.case = case
	safe_door.has_prints = plan.clues.has("prints")
	safe_door.position = PostOffice.SAFE_AT + Vector3(-1.0, 0.7, 0.55)
	safe_door.rotation.y = -PI / 2
	post_office.add_child(safe_door)
	if plan.clues.has("footprint"):
		footprint = DustPrint.new()
		footprint.name = "DustPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		var at: Vector3 = FOOTPRINT_SPOTS[absi(hash(["post office footprint", case.case_seed])) % FOOTPRINT_SPOTS.size()]
		footprint.position = at + Vector3(0, PostOffice.FLOOR_TOP - 0.04, 0)
		# The steps point to where the stamp went.
		var to := (post_office.loot_spots[post_office.loot_spot] as Node3D).position - at
		footprint.rotation.y = atan2(to.x, to.z)
		post_office.add_child(footprint)
		case.flour_print = footprint
	_cap()
	if plan.clues.has("hair"):
		hair = CrimeClueItem.new()
		hair.name = "Clue_hair"
		hair.kind = "hair"
		hair.look = "post_office"
		hair.case = case
		hair.hair_color = CarrierTraits.HAIRS[who.hair]
		hair.position = HAIR_AT + Vector3(0, PostOffice.FLOOR_TOP, 0)
		post_office.add_child(hair)
		case.items["hair"] = hair
	if plan.clues.has("bite"):
		cookie = CrimeClueItem.new()
		cookie.name = "Clue_bite"
		cookie.kind = "bite"
		cookie.look = "post_office"
		cookie.case = case
		var spot := post_office.loot_spots["scale"] as Node3D
		cookie.position = Vector3(spot.position.x, PostOffice.FLOOR_TOP, spot.position.z) + spot.get_meta("out") \
			+ Vector3(0.6, 0, 0)
		post_office.add_child(cookie)
		cookie.visible = false
		cookie.freeze = true
		cookie.collision_layer = 0
	has_letter = plan.clues.has("letter")
	post_office.returns.clues = self
	post_office.sorting.started.connect(_on_sorting_started)


## A search of a spot is over (PostOffice.searched): behind the scale, the bitten cookie turns up too.
func searched(spot: String) -> void:
	if spot != "scale" or not cookie or cookie_out or case.ruined.has("bite"):
		return
	cookie_out = true
	cookie.visible = true
	cookie.collision_layer = 4
	cookie.freeze = false
	case.items["bite"] = cookie


## The sorting machine started: the first run blows the letters off the footprint; any later one covers it again and
## blows the cap's hair into a sack, unless it's bagged.
func _on_sorting_started(first: bool) -> void:
	if first:
		if footprint:
			footprint.uncover()
		return
	if footprint and not case.clues_found.has("footprint"):
		footprint.cover()
	if hair and not hair.bagged and not case.clues_found.has("hair"):
		hair.spoiled = true
		hair.visible = false
		case.ruin("hair")


## E on the returns sack with empty hands: the 3 a.m. letter and the culprit's route, if it's a clue and nothing
## covered it.
func look_at_returns(cop: Cop) -> void:
	if has_letter and not letter_covered:
		case.found("letter")
		if cop:
			cop.show_hint(tr("HINT_RETURNS_3AM") % tr("ROUTE_" + str(case.culprit().route)))
		return
	if cop:
		cop.show_hint("HINT_RETURNS_COVERED" if letter_covered else "HINT_RETURNS_NOTHING")


## E on the returns sack with something in hand: into the sack it goes, on top of the 3 a.m. letter.
func drop_in_returns(cop: Cop, item: Node3D) -> void:
	letter_covered = true
	if cop:
		cop.get_node("Grabber").release()
		cop.show_hint("HINT_RETURNS_DROPPED")
	if item:
		item.global_position = post_office.returns.global_position + Vector3(0, 0.7, 0)
	if has_letter and not case.clues_found.has("letter"):
		case.ruin("letter")


func _physics_process(delta: float) -> void:
	if case.follower or not case.at_tent or _elapsed >= POLISH_SECONDS:
		return
	var was := _elapsed
	_elapsed += delta
	if was < PARROT_SECONDS and _elapsed >= PARROT_SECONDS:
		parrot_snack()
	if _elapsed >= POLISH_SECONDS:
		polish()


## Cartita comes down from her perch and finds the cookie, behind the scale or out of it, unless it's bagged.
func parrot_snack() -> void:
	if not cookie or case.clues_found.has("bite") or cookie.bagged:
		return
	cookie.spoiled = true
	cookie.visible = false
	cookie.collision_layer = 0
	post_office.parrot.say("PARROT_COOKIE")
	case.ruin("bite")


## Doña Sellito wipes the safe's door to seal it: whatever prints were on it are gone.
func polish() -> void:
	if safe_door.has_prints and not case.clues_found.has("prints"):
		safe_door.has_prints = false
		post_office.boss.say("POST_BOSS_POLISH")
		case.ruin("prints")


## The carrier's cap forgotten on the depot's floor, upside down, in every case (the hair by it only when it's a clue).
func _cap() -> void:
	var builder := PlaceBuilder.new(post_office)
	var crown := CylinderMesh.new()
	crown.top_radius = 0.2
	crown.bottom_radius = 0.21
	crown.height = 0.13
	builder.mesh(crown, CAP_AT + Vector3(0, PostOffice.FLOOR_TOP + 0.065, 0), PostOffice.POST_BLUE)
	var visor := CylinderMesh.new()
	visor.top_radius = 0.16
	visor.bottom_radius = 0.16
	visor.height = 0.02
	builder.mesh(visor, CAP_AT + Vector3(0.12, PostOffice.FLOOR_TOP + 0.13, 0.08), PostOffice.POST_BLUE.darkened(0.2))
