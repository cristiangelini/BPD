class_name SingerGuitarRig
extends PawnRig

## The singer's guitar (allanamiento-empenos.md, "La guitarra del cantante"): the famous singer's stolen guitar (6 kg,
## the main evidence) is hidden in the shop with his signed photo and the tour contract. Another guitar leans on a
## middle shelf with a recorder inside: it plays by itself when a cop walks by, and looking at it is the story's clue.
## The shop's radio, while it's still in the shop, gives the news of the robbery every RADIO_EVERY seconds, and a cop
## who hears it gets that clue too. Every number here is (propuesta).

const GUITAR_MODEL := preload("res://assets/models/star_guitar.glb")
## Standing against the front of the shelf west of the old TV, its neck up and its face to the aisle.
const LEANS_AT := PawnShop.SHELVES[2] + Vector3(1.0, 0.5, PawnShop.SHELF_SIZE.z / 2 + 0.02)
const PLAY_RANGE := 1.5
const PLAY_AGAIN := 15.0
const RADIO_EVERY := 25.0
const HEAR_RANGE := 5.0

var look: ClueSpot
var plays := 0
var news := 0
var _play_wait := 0.0
var _radio_left := RADIO_EVERY


func setup(place: PawnShop) -> void:
	super.setup(place)
	var guitar: Node3D = GUITAR_MODEL.instantiate()
	guitar.name = "TalkingGuitar"
	guitar.transform = Transform3D(Basis(Vector3.UP, Vector3.BACK, Vector3.RIGHT), LEANS_AT)
	place.add_child(guitar)
	look = ClueSpot.new()
	look.size = Vector3(0.45, 1.1, 0.3)
	look.prompt = "PROMPT_PAWN_GUITAR"
	look.text = tr("CLUE_SINGER_GUITAR")
	look.position = LEANS_AT + Vector3(0, 0.05, 0.1)
	look.read.connect(place.raid.add_clue)
	place.add_child(look)


## The recorder inside plays its bit.
func play() -> void:
	plays += 1
	_play_wait = PLAY_AGAIN
	shop.say_at(shop.to_global(LEANS_AT + Vector3.UP * 1.1), "PAWN_GUITAR_PLAYS")


## The radio for sale gives the news, if it's still in the shop; a cop near it hears it.
func radio_news() -> void:
	var radio: Grabbable = shop.goods[1] if shop.goods.size() > 1 else null
	if not radio or not is_instance_valid(radio) or not shop.is_inside(shop.to_local(radio.global_position)):
		return
	news += 1
	shop.say_at(radio.global_position + Vector3.UP * 0.6, "PAWN_RADIO_NEWS")
	if shop.cop_near(shop.to_local(radio.global_position), HEAR_RANGE):
		shop.raid.add_clue(tr("CLUE_RADIO_NEWS"))


func _physics_process(delta: float) -> void:
	_play_wait -= delta
	if _play_wait <= 0.0 and shop.cop_near(LEANS_AT, PLAY_RANGE):
		play()
	_radio_left -= delta
	if _radio_left <= 0.0:
		_radio_left = RADIO_EVERY
		radio_news()
