class_name WeddingClues
extends Node

## The wedding case's clues where they go (escena-boda.md, "Las pistas"), put by WeddingHall when the case comes: the
## empty ring box with the prints on the head table, the footprint in the rice by the door (a waiter sweeps it up after
## SWEEP_AT unless it was photographed), a hair in the frosting on the cake's top, the bite out of the cake's
## bottom tier (a photo of it), the videographer's camera and grandma Chola, who smelled the culprit's cologne. Cutting
## the cake open loses the hair and the bite if they weren't taken yet. Every number here is (propuesta).

const RING_BOX_MODEL := preload("res://assets/models/wedding_ring_box.glb")
## Seconds after the tip when the waiter sweeps the rice, and the footprint with it.
const SWEEP_AT := 360.0
## Where the ring box lies on the head table, from its middle.
const RING_BOX_AT := Vector3(1.6, 0, 0.1)
## The videographer's tripod, by the dance floor's east side, facing it.
const VIDEO_AT := Vector3(5.2, 0, -5.4)
## The hair, loose on the cake's top tier, from the cake table's top.
const HAIR_AT := Vector3(0.05, WeddingHall.CAKE_HEIGHT, 0.05)
## The bite out of the cake's bottom tier, on its side facing the hall, from the cake table's top.
const BITE_AT := Vector3(0.3, 0.31, 0.3)
const BITE_COLOR := Color(0.93, 0.78, 0.5)

var hall: WeddingHall
var case: CrimeSceneCase
var ring_box: EmptyFrame
var video: WeddingVideo
var footprint: FlourPrint
## The bite out of the cake, for the camera.
var bite: Node3D
var swept := false


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	var head_top := WeddingHall.HEAD_TABLE_AT + Vector3(0, WeddingHall.FLOOR_TOP + WeddingHall.HEAD_TABLE_SIZE.y, 0)
	ring_box = EmptyFrame.new(Vector2(0.1, 0.1))
	ring_box.name = "RingBox"
	ring_box.case = case
	ring_box.has_prints = plan.clues.has("prints")
	ring_box.keys = {"prompt": "PROMPT_RING_BOX", "touched": "HINT_RING_BOX_TOUCHED", "empty": "HINT_RING_BOX_EMPTY",
		"smudged": "PRINTS_RING_BOX_SMUDGED", "prints": "PRINTS_RING_BOX"}
	ring_box.position = head_top + RING_BOX_AT + Vector3(0, 0.05, 0)
	hall.add_child(ring_box)
	var box: Node3D = RING_BOX_MODEL.instantiate()
	box.position = Vector3(0, -0.05, 0)
	ring_box.add_child(box)
	(box.find_child("ring", true, false) as Node3D).visible = false
	video = WeddingVideo.new()
	video.name = "Video"
	video.case = case
	video.has_recording = plan.clues.has("recording")
	video.position = VIDEO_AT + Vector3(0, WeddingHall.FLOOR_TOP, 0)
	video.rotation.y = -PI / 2
	hall.add_child(video)
	hall.grandma.case = case
	hall.grandma.knows = plan.clues.has("witness")
	var cake_top := WeddingHall.CAKE_TABLE_AT + Vector3(0, WeddingHall.FLOOR_TOP + WeddingHall.TABLE_HEIGHT, 0)
	if plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "RicePrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = WeddingHall.RICE_COLOR
		var area := WeddingHall.RICE_AREA.grow(-0.6)
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(["wedding footprint", case.case_seed])
		footprint.position = Vector3(area.position.x + rng.randf() * area.size.x, WeddingHall.FLOOR_TOP - 0.04,
			area.position.y + rng.randf() * area.size.y)
		hall.add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		var item := CrimeClueItem.new()
		item.name = "Clue_hair"
		item.kind = "hair"
		item.look = "museum"
		item.case = case
		item.hair_color = WeddingTraits.HAIRS[who.hair]
		item.position = cake_top + HAIR_AT
		hall.add_child(item)
		case.items["hair"] = item
	if plan.clues.has("bite"):
		bite = CakeBite.new()
		bite.name = "CakeBite"
		bite.add_to_group("photo_clues")
		(bite as CakeBite).case = case
		bite.position = cake_top + BITE_AT
		hall.add_child(bite)
		PlaceBuilder.new(bite).mesh_box(Vector3.ZERO, Vector3(0.12, 0.1, 0.12), BITE_COLOR)


## The cake was cut open: the hair in its frosting and the bite out of it go, unless the cops had them already.
func cake_cut() -> void:
	if case.items.has("hair"):
		var hair: CrimeClueItem = case.items.hair
		if hall.to_local(hair.global_position).distance_to(
				WeddingHall.CAKE_TABLE_AT + Vector3(0, WeddingHall.FLOOR_TOP + WeddingHall.TABLE_HEIGHT, 0) + HAIR_AT) <= 0.4:
			hair.wash()
	if bite:
		case.ruin("bite")
		bite.visible = false


func _physics_process(_delta: float) -> void:
	# Online the host's wedding decides when the rice is swept (WeddingHall.apply_net_state).
	if swept or case.follower or not case.tip_given or case.elapsed < SWEEP_AT:
		return
	sweep()


## The waiter sweeps the rice by the door, and the footprint in it if nobody took its photo.
func sweep() -> void:
	swept = true
	hall.get_node("Rice").visible = false
	if footprint and not footprint.wiped and not case.clues_found.has("footprint"):
		footprint.wipe()
