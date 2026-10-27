class_name PlaceDraw
extends RefCounted

## Which place a match happens in (panaderia.md, "El orden para hacerlo", step 5): Play draws a case seed and, from
## it, the grandpa's house, the bakery, the pet salon, the hardware store (ferreteria.md), the doll factory
## (fabrica.md), the insurance office (seguros.md), the cake lab (laboratorio.md), the Hotel Gran Siesta (hotel-allanamiento.md), the gym or the apartment building (edificio.md), with even odds (propuesta). Every third shift is an interrogation instead (interrogatorio.md, "Sale como un caso más"), and of the rest half are chases
## (persecucion.md, "Sale como un caso más"). Of the shifts left, one in CRIME_EVERY is the crime scene
## (escena-del-crimen.md, propuesta; a quarter each at the pastry contest, the circus, the museum and the hotel), then one in
## TRAFFIC_EVERY the traffic control (control-transito.md; the level draws rush hour or clown convoy), then one in
## INFILTRATION_EVERY an infiltration (infiltracion.md), a third each at the grandparents' club, the church choir
## (infiltracion-coro.md) and the mime troupe's theater (infiltracion-mimos.md), then one in BANK_EVERY the bank robbery (robo-banco.md), then one in RALLY_EVERY the
## politician's protection (proteccion-politico.md), half at the plaza and half at the market (politico-mercado.md),
## then one in PRISON_EVERY a prison case, a quarter each the riot in the
## canteen (carcel-motin.md), the prisoner transfer (traslado-presos.md), the blackout (carcel-corte-de-luz.md) and the
## visiting day (carcel-visitas.md), and
## the rest are raids. A
## campaign whose cops missed the quota goes to the jailbreak first (fuga.md). --place=<id> forces one. The level then
## takes that seed, so the place, the story and the hiding spots all come from one seed.

const PLACES := {
	"grandpa": "res://scenes/levels/grandpa_house.tscn",
	"bakery": "res://scenes/levels/bakery.tscn",
	"groomer": "res://scenes/levels/groomer.tscn",
	"interrogation": "res://scenes/levels/interrogation.tscn",
	"chase": "res://scenes/levels/chase.tscn",
	"crime_scene": "res://scenes/levels/crime_scene.tscn",
	"traffic": "res://scenes/levels/traffic_control.tscn",
	"jailbreak": "res://scenes/levels/jailbreak.tscn",
	"club": "res://scenes/levels/grandpa_club.tscn",
	"choir": "res://scenes/levels/church_choir.tscn",
	"mime": "res://scenes/levels/mime_theater.tscn",
	"party": "res://scenes/levels/party_hall.tscn",
	"gym": "res://scenes/levels/gym_hall.tscn",
	"school": "res://scenes/levels/school_hall.tscn",
	"restaurant": "res://scenes/levels/restaurant_hall.tscn",
	"chess": "res://scenes/levels/chess_club.tscn",
	"biker": "res://scenes/levels/biker_bar.tscn",
	"auction": "res://scenes/levels/auction_house.tscn",
	"bank": "res://scenes/levels/bank.tscn",
	"plaza": "res://scenes/levels/plaza_rally.tscn",
	"prison": "res://scenes/levels/prison.tscn",
	"circus": "res://scenes/levels/circus.tscn",
	"museum": "res://scenes/levels/museum.tscn",
	"hotel": "res://scenes/levels/hotel.tscn",
	"hotel_raid": "res://scenes/levels/hotel_raid.tscn",
	"transfer": "res://scenes/levels/prisoner_transfer.tscn",
	"blackout": "res://scenes/levels/prison_blackout.tscn",
	"visits": "res://scenes/levels/prison_visits.tscn",
	"market": "res://scenes/levels/market.tscn",
	"double": "res://scenes/levels/plaza_double.tscn",
	"birthday": "res://scenes/levels/plaza_birthday.tscn",
	"convertible": "res://scenes/levels/plaza_convertible.tscn",
	"laundry": "res://scenes/levels/prison_laundry.tscn",
	"hardware": "res://scenes/levels/hardware_store.tscn",
	"doll_factory": "res://scenes/levels/doll_factory.tscn",
	"insurance": "res://scenes/levels/insurance_office.tscn",
	"cake_lab": "res://scenes/levels/cake_lab.tscn",
	"gym_raid": "res://scenes/levels/gym_raid.tscn",
	"apartments": "res://scenes/levels/apartment_tower.tscn",
	"costume_shop": "res://scenes/levels/costume_shop.tscn",
	"prison_tunnel": "res://scenes/levels/prison_tunnel.tscn",
	"prison_talent": "res://scenes/levels/prison_talent.tscn",
	"prison_vip": "res://scenes/levels/prison_vip.tscn",
	"prison_garden": "res://scenes/levels/prison_garden.tscn",
	"prison_count": "res://scenes/levels/prison_count.tscn",
	"bridge": "res://scenes/levels/bridge_park.tscn",
	"school_visit": "res://scenes/levels/school_visit.tscn",
	"football": "res://scenes/levels/football_pitch.tscn",
	"debate": "res://scenes/levels/tv_studio.tscn",
	"wrong_house": "res://scenes/levels/wrong_house.tscn",
	"airport": "res://scenes/levels/airport.tscn",
}
## The raids, drawn by the seed.
const ORDER := ["grandpa", "bakery", "groomer", "hardware", "doll_factory", "insurance", "cake_lab", "hotel_raid", "gym_raid", "apartments"]
## One shift in this many is an interrogation (Cristian, 20/10): shifts 3, 6... of a campaign, or 1 in 3 by the seed
## without one.
const INTERROGATION_EVERY := 3
## Of the shifts that aren't interrogations, one in this many is a chase (Cristian, 20/10: half and half).
const CHASE_EVERY := 2
## Of the shifts that are neither, one in this many is the crime scene, and of the rest one in TRAFFIC_EVERY is the
## traffic control (propuesta: each as often as each raid).
const CRIME_EVERY := 5
const TRAFFIC_EVERY := 4
## The crime scenes, drawn by the seed: the pastry contest, the circus (escena-circo.md), the museum (escena-museo.md)
## and the hotel (escena-hotel.md), in quarters (propuesta).
const CRIME_SCENES := ["crime_scene", "circus", "museum", "hotel"]
## Of the rest, one in this many is an infiltration (propuesta: as often as each raid), at one of these by the seed.
const INFILTRATION_EVERY := 4
const INFILTRATIONS := ["club", "choir", "mime", "party", "gym", "school", "restaurant", "chess", "biker", "auction"]
## Of the rest, one in this many is the bank robbery (robo-banco.md, propuesta: as often as each raid).
const BANK_EVERY := 4
## Of the rest, one in this many is the politician's protection (proteccion-politico.md, propuesta), at one of these
## by the seed: the rally at the plaza, the walk through the market (politico-mercado.md), the bridge's opening
## (politico-puente.md), the rally with the double (politico-doble.md), the birthday party (politico-cumple.md), the
## parade in a convertible (politico-descapotable.md), the charity football match (politico-futbol.md), the school
## visit (politico-escuela.md), the TV debate (politico-debate.md) or the trip from the airport
## (politico-aeropuerto.md), a tenth each.
const RALLY_EVERY := 4
const RALLIES := ["plaza", "market", "bridge", "double", "birthday", "convertible", "football", "school_visit", "debate",
	"airport"]
## Of the rest, one in this many is a prison case (propuesta), one of these by the seed: the riot in the canteen
## (carcel-motin.md), the prisoner transfer (traslado-presos.md), the blackout (carcel-corte-de-luz.md), the
## visiting day (carcel-visitas.md), the laundry (carcel-lavanderia.md), the tunnel (carcel-tunel.md), the talent show
## (carcel-talentos.md), the VIP inmate (carcel-vip.md), the garden (carcel-huerta.md) or the count
## (carcel-recuento.md).
const PRISON_EVERY := 4
const PRISONS := ["prison", "transfer", "blackout", "visits", "laundry", "prison_tunnel", "prison_talent",
	"prison_vip", "prison_garden", "prison_count"]

## The seed the next level takes (0 = none drawn; the level draws its own).
static var pending_seed := 0
## The owner brought in from the last raid without a campaign (RaidCase.custody); a campaign keeps its own.
static var custody := {}


## The place for this seed: from --place=<id> among the user args, or drawn. It hashes the seed instead of taking
## seed % 4, because the stories are drawn with seed % their count and the two draws would go together.
## `shift` is the campaign's shift (0 without a campaign). Without `chases` every shift that isn't an interrogation is
## a raid.
static func pick(case_seed: int, args: PackedStringArray, shift := 0, chases := true) -> String:
	for arg in args:
		if arg.begins_with("--place=") and PLACES.has(arg.trim_prefix("--place=")):
			return arg.trim_prefix("--place=")
	# A missed quota locks the cops up before anything else (decision 99, fuga.md).
	if Campaign.current and Campaign.current.jailed:
		return "jailbreak"
	# An owner in custody is interrogated next, whatever the shift (decision 93).
	if is_interrogation(case_seed, shift) or not custody_now().is_empty():
		return "interrogation"
	if chases and hash("case kind %d" % case_seed) % CHASE_EVERY == 0:
		return "chase"
	# Hashed as an array: string hashes of the same seed with another prefix go together in their low bits.
	if chases and hash(["crime scene", case_seed]) % CRIME_EVERY == 0:
		return CRIME_SCENES[hash(["crime scene place", case_seed]) % CRIME_SCENES.size()]
	if chases and hash(["traffic control", case_seed]) % TRAFFIC_EVERY == 0:
		return "traffic"
	if chases and hash(["infiltration", case_seed]) % INFILTRATION_EVERY == 0:
		return INFILTRATIONS[hash(["infiltration place", case_seed]) % INFILTRATIONS.size()]
	if chases and hash(["bank robbery", case_seed]) % BANK_EVERY == 0:
		return "bank"
	if chases and hash(["politician rally", case_seed]) % RALLY_EVERY == 0:
		return RALLIES[hash(["politician place", case_seed]) % RALLIES.size()]
	if chases and hash(["prison riot", case_seed]) % PRISON_EVERY == 0:
		return PRISONS[hash(["prison case", case_seed]) % PRISONS.size()]
	return ORDER[hash(["raid place", case_seed]) % ORDER.size()]


static func is_interrogation(case_seed: int, shift: int) -> bool:
	if shift > 0:
		return shift % INTERROGATION_EVERY == 0
	return hash("interrogation %d" % case_seed) % INTERROGATION_EVERY == 0


## The owner waiting to be interrogated: the campaign's, or the one from the last raid without one.
static func custody_now() -> Dictionary:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.custody
	return custody


## Lets the owner go once he's been interrogated.
static func release_custody() -> void:
	custody = {}
	if Campaign.current:
		Campaign.current.custody = {}


## The shift being played, or 0 without a campaign.
static func shift_now() -> int:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.shift
	return 0


## A new case seed: never 0 (0 means "none"), and odd or even, so every story can come up (seed % count).
static func new_seed() -> int:
	return randi_range(1, 0x7fffffff)


## The seed of the next case: the current campaign's shift (docs/diseno/guardado.md), or a new one without a campaign.
static func next_seed() -> int:
	if Campaign.current and not Campaign.current.is_over():
		return Campaign.current.case_seed()
	return new_seed()


## Takes the next case seed and opens its place.
static func start(tree: SceneTree) -> void:
	pending_seed = next_seed()
	tree.change_scene_to_file(PLACES[pick(pending_seed, OS.get_cmdline_user_args(), shift_now())])


## The seed Play drew for this level, once; 0 if the level was opened some other way.
static func take_seed() -> int:
	var drawn := pending_seed
	pending_seed = 0
	return drawn
