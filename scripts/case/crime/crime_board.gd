class_name CrimeBoard
extends StaticBody3D

## The cork board in the station's board room (escena-del-crimen.md, "El tablero de la comisaría"). The cooks' files
## show up on the top row once they have a photo; E on the cork pins the clues: the bagged one in hand and the ones
## that were photographed or heard. E on a clue takes the red string; E on a file ties it there: if the clue doesn't fit
## that cook, the string snaps and his file gets a red cross. The rubber stamp under the board (BoardStamp) arms an
## accusation: E on a file with it accuses that cook, and the comisario comes to look. Every number here is (propuesta).

const SIZE := Vector2(6.0, 1.8)
const BOTTOM := 0.7
const CORK := Color(0.72, 0.53, 0.33)
const FRAME := Color(0.4, 0.27, 0.16)
const STRING := Color(0.85, 0.08, 0.1)

var case: CrimeSceneCase
## Index -> its file card, once it has a photo.
var file_cards := {}
## Clue kind -> its card, once pinned.
var clue_cards := {}
## [clue kind, cook index] for each string that held.
var strings: Array[Array] = []
## Who holds the red string from which clue: cop -> kind.
var string_from := {}
## Who holds the rubber stamp.
var stamp_by: Cop


func _ready() -> void:
	add_to_group("crime_board")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, SIZE.y, 0.06)
	shape.shape = box
	shape.position = Vector3(0, BOTTOM + SIZE.y / 2, 0)
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, BOTTOM + SIZE.y / 2, -0.01), Vector3(SIZE.x + 0.12, SIZE.y + 0.12, 0.03), FRAME)
	builder.mesh_box(Vector3(0, BOTTOM + SIZE.y / 2, 0.01), Vector3(SIZE.x, SIZE.y, 0.03), CORK)
	var title := Label3D.new()
	title.text = "BOARD_TITLE"
	title.font_size = 64
	title.pixel_size = 0.0035
	title.outline_size = 12
	title.position = Vector3(0, BOTTOM + SIZE.y + 0.18, 0.03)
	add_child(title)


func prompt_key(cop: Cop) -> String:
	return "PROMPT_BOARD_PIN" if _held_clue(cop) else "PROMPT_BOARD"


## E on the cork: pins the bagged clue in hand and every clue found without carrying it.
func use(cop: Cop) -> void:
	var item := _held_clue(cop)
	if item:
		_pin(item.kind)
		cop.get_node("Grabber").release()
		item.queue_free()
	for kind: String in case.clues_found:
		if not case.items.has(kind):
			_pin(kind)
	refresh()
	cop.show_hint("HINT_BOARD_PINNED" if not clue_cards.is_empty() else "HINT_BOARD_EMPTY")


## Adds the files that got a photo and redraws what each card says.
func refresh() -> void:
	for index: int in case.file_parts:
		if case.file_parts[index].photo and not file_cards.has(index):
			file_cards[index] = _card("file", index, _file_at(index))
	for index: int in file_cards:
		(file_cards[index] as BoardCard).label.text = file_text(index)


## What a file card says: the photo shows apron, glasses, hand and shoes; the rest as the cops got it.
func file_text(index: int) -> String:
	var cook: Dictionary = case.cooks[index]
	var parts: Dictionary = case.file_parts[index]
	var lines := PackedStringArray(["%d. %s" % [index + 1, cook.name]])
	lines.append(tr("FILE_APRON") % tr("APRON_" + str(cook.apron)))
	lines.append(tr("FILE_GLASSES") if cook.glasses else tr("FILE_NO_GLASSES"))
	lines.append(tr("FILE_LEFT") if cook.left else tr("FILE_RIGHT"))
	lines.append(tr("FILE_SHOE") % cook.shoe)
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(cook.hair)) if parts.hair else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(cook.teeth)) if parts.teeth else "?"))
	lines.append(tr("FILE_PRINTS") if parts.prints else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


func prompt_for(card: BoardCard, cop: Cop) -> String:
	if card.kind == "clue":
		return "PROMPT_BOARD_STRING"
	if stamp_by == cop:
		return "PROMPT_BOARD_ACCUSE"
	return "PROMPT_BOARD_TIE" if string_from.has(cop) else "PROMPT_BOARD_FILE"


func use_card(card: BoardCard, cop: Cop) -> void:
	if card.kind == "clue":
		string_from[cop] = card.id
		cop.show_hint("HINT_BOARD_STRING")
	elif stamp_by == cop:
		stamp_by = null
		case.accuse(card.id)
		card.set_crossed(card.id != case.plan.culprit)
	elif string_from.has(cop):
		tie(string_from[cop], card.id, cop)
		string_from.erase(cop)
	else:
		cop.show_hint(file_text(card.id).replace("\n", " · "))


## The string from a clue to a cook's file: it holds if he fits the clue, else it snaps and his file is crossed out.
## Returns whether it held.
func tie(kind: String, index: int, cop: Cop = null) -> bool:
	var fits := CrimePlan.fits(case.cooks[index], kind, case.culprit())
	if fits:
		strings.append([kind, index])
		_string(clue_cards[kind], file_cards[index])
	else:
		(file_cards[index] as BoardCard).set_crossed(true)
	if cop:
		cop.show_hint("HINT_BOARD_HOLDS" if fits else "HINT_BOARD_SNAPS")
	return fits


func _pin(kind: String) -> void:
	if clue_cards.has(kind) or not case.clues_found.has(kind):
		return
	var card := _card("clue", kind, Vector3(-SIZE.x / 2 + 0.9 + clue_cards.size() * 1.4, BOTTOM + 0.3, 0.05))
	card.label.text = case.clue_line(kind)
	clue_cards[kind] = card


func _file_at(index: int) -> Vector3:
	return Vector3(-SIZE.x / 2 + 0.5 + index * 1.0, BOTTOM + SIZE.y - 0.48, 0.05)


func _card(kind: String, id: Variant, at: Vector3) -> BoardCard:
	var card := BoardCard.new()
	card.name = "%s_%s" % [kind, id]
	card.board = self
	card.kind = kind
	card.id = id
	card.position = at
	add_child(card)
	return card


func _string(from: BoardCard, to: BoardCard) -> void:
	var a := from.position + Vector3(0, from.size.y / 2, 0.03)
	var b := to.position - Vector3(0, to.size.y / 2, -0.03)
	var bar := BoxMesh.new()
	bar.size = Vector3(0.02, a.distance_to(b), 0.01)
	PlaceBuilder.new(self).mesh(bar, (a + b) / 2, STRING, Vector3(0, 0, -atan2(b.x - a.x, b.y - a.y)))


func _held_clue(cop: Cop) -> CrimeClueItem:
	var held: Node = cop.get_node("Grabber").held
	return held if held is CrimeClueItem and (held as CrimeClueItem).bagged else null
