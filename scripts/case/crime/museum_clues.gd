class_name MuseumClues
extends Node

## The museum case's clues where they go (escena-museo.md, "Las pistas"), put by Museum when the case comes: the
## empty frame with the prints, the footprint on the waxed floor and the polisher that goes round it, the hair on the
## velvet rope's post (it falls if someone crosses the rope), the bitten sandwich on the security desk and the monitors
## with last night's recording. Every number here is (propuesta).

## The polisher's round, in the gallery: along the back wall, down the east side, back past the bench and up again.
const POLISHER_ROUTE: Array[Vector3] = [
	Vector3(-6, 0, -11), Vector3(13, 0, -11), Vector3(13, 0, -1.5), Vector3(-6, 0, -1.5),
]
## Where the footprint can be: all on the polisher's round, none too close to where it starts.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(13, 0, -6), Vector3(8, 0, -1.5), Vector3(-6, 0, -6)]
## A cop this close to the rope's line, between its end posts, is crossing it, in meters.
const ROPE_REACH := 0.25
const MONITORS_AT := Vector3(0.3, 0.02, -0.1)

var museum: Museum
var case: CrimeSceneCase
var frame: EmptyFrame
var polisher: GalleryPolisher
var monitors: SecurityMonitors


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	frame = EmptyFrame.new(Museum.FRAME_SIZE)
	frame.name = "EmptyFrame"
	frame.case = case
	frame.has_prints = plan.clues.has("prints")
	frame.position = Museum.EMPTY_FRAME_AT
	museum.add_child(frame)
	monitors = SecurityMonitors.new()
	monitors.name = "Monitors"
	monitors.case = case
	monitors.has_recording = plan.clues.has("recording")
	monitors.position = Museum.DESK_AT + Vector3(0, Museum.DESK_SIZE.y, 0) + MONITORS_AT
	museum.add_child(monitors)
	polisher = GalleryPolisher.new()
	polisher.name = "Polisher"
	polisher.route.assign(POLISHER_ROUTE.map(func(at: Vector3) -> Vector3: return at + Vector3(0, Museum.FLOOR_TOP, 0)))
	museum.add_child(polisher)
	if plan.clues.has("footprint"):
		var footprint := FlourPrint.new()
		footprint.name = "WaxPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = Museum.WAXED.darkened(0.2)
		# On top of the waxed floor, which sits on the building's.
		footprint.position = FOOTPRINT_SPOTS[hash(["museum footprint", case.case_seed]) % FOOTPRINT_SPOTS.size()] \
			+ Vector3(0, Museum.FLOOR_TOP, 0)
		museum.add_child(footprint)
		case.flour_print = footprint
		polisher.footprint = footprint
	if plan.clues.has("hair"):
		_clue_item("hair", Vector3((Museum.ROPE_FROM + Museum.ROPE_TO) / 2, 1.01, Museum.ROPE_Z))
	if plan.clues.has("bite"):
		_clue_item("bite", Museum.SANDWICH_AT + Vector3(0, 0.02, 0))


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "museum"
	item.case = case
	item.hair_color = CookTraits.HAIRS[case.culprit().hair]
	item.position = at
	museum.add_child(item)
	case.items[kind] = item


func _physics_process(_delta: float) -> void:
	# Online the host's museum decides when the polisher starts and when the hair falls (Museum.apply_net_state).
	if case.follower:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Node3D
		if not polisher.running and museum.in_gallery(cop.global_position):
			polisher.running = true
		var at := museum.to_local(cop.global_position)
		if at.x > Museum.ROPE_FROM and at.x < Museum.ROPE_TO and absf(at.z - Museum.ROPE_Z) <= ROPE_REACH:
			drop_hair()


## Someone crossed the velvet rope: the hair on its post falls and is lost, unless it was already taken.
func drop_hair() -> void:
	if not case.items.has("hair"):
		return
	var hair: CrimeClueItem = case.items.hair
	var post := Vector3((Museum.ROPE_FROM + Museum.ROPE_TO) / 2, 1.01, Museum.ROPE_Z)
	if museum.to_local(hair.global_position).distance_to(post) <= 0.4:
		hair.wash()
