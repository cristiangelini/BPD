class_name EndlessInstallmentsRig
extends FurnitureRig

## The endless installments (allanamiento-muebleria.md, "Las cuotas infinitas"): Don Cajón sells everything in
## installments that never end. The book of installments is hidden with the "Cuota 1 de 999" stamp and the calculator
## that always gives more. Every sofa and bed carries a price tag, "120 cuotas de $1", with fine print underneath, "por
## mes, por siempre": a cop who comes close enough reads it, the story's own clue (on the checklist the first time). And
## Don Cajón offers installments to every cop who looks at him, however high his complaint is. Every number here is
## (propuesta).

## The price tag floats this high over a sofa or a bed, and its fine print this much lower.
const TAG_UP := 1.2
const FINE_DOWN := 0.18
## The fine print is only readable this close.
const READ_RANGE := 1.6
## A cop looks at Don Cajón when he's this close and within this angle of the middle of the screen.
const LOOK_RANGE := 6.0
const LOOK_ANGLE := deg_to_rad(12.0)
## Don Cajón doesn't make the same cop another offer before this.
const OFFER_EVERY := 10.0
const OFFER_LINES := ["CAJON_OFFER_1", "CAJON_OFFER_2", "CAJON_OFFER_3"]

## The price tags (each a Label3D with its fine print as a child), how many offers he made and the wait per cop.
var tags: Array[Label3D] = []
var fine_print_read := false
var offers := 0
var _offer_wait := {}


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	for seat: ShowroomSeat in place.sofas + place.beds:
		var tag := _tag_label("PRICE_TAG_INSTALLMENTS", 40)
		tag.name = "PriceTag"
		tag.position = place.to_local(seat.global_position) + Vector3.UP * TAG_UP
		var fine := _tag_label("PRICE_TAG_FINE_PRINT", 16)
		fine.name = "FinePrint"
		fine.position = Vector3.DOWN * FINE_DOWN
		tag.add_child(fine)
		place.add_child(tag)
		tags.append(tag)


func _tag_label(key: String, size: int) -> Label3D:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.005
	label.outline_size = 10
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	return label


func _physics_process(delta: float) -> void:
	for id: int in _offer_wait.keys():
		_offer_wait[id] = maxf(_offer_wait[id] - delta, 0.0)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if not fine_print_read:
			for tag in tags:
				var flat := tag.global_position - cop.global_position
				flat.y = 0.0
				if flat.length() <= READ_RANGE:
					read_fine_print(cop)
					break
		# Online the host's Don Cajón makes the offers (every cop's head turns there too) and his bubble goes to all.
		if multiplayer.is_server() and is_instance_valid(store.cajon) and looks_at_cajon(cop):
			offer(cop)


## Whether `cop` has Don Cajón in the middle of the screen, close by.
func looks_at_cajon(cop: Cop) -> bool:
	var eye := cop.camera.global_position
	var to := store.cajon.global_position + Vector3.UP * FloorBoss.EYE - eye
	if to.length() > LOOK_RANGE:
		return false
	return (-cop.camera.global_basis.z).angle_to(to) <= LOOK_ANGLE


## `cop` reads the fine print under a price tag: the clue.
func read_fine_print(cop: Cop) -> void:
	if fine_print_read:
		return
	fine_print_read = true
	cop.show_hint("HINT_FINE_PRINT")
	store.raid.add_clue(tr("CLUE_FINE_PRINT"))


## `cop` looked at Don Cajón: he offers installments, complaint or no complaint, at most every OFFER_EVERY s per cop.
func offer(cop: Cop) -> bool:
	var id := cop.get_instance_id()
	if _offer_wait.get(id, 0.0) > 0.0:
		return false
	_offer_wait[id] = OFFER_EVERY
	store.cajon.say(OFFER_LINES[offers % OFFER_LINES.size()], 4.0)
	offers += 1
	return true
