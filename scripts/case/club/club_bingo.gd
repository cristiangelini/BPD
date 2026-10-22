class_name ClubBingo
extends Node3D

## Doña Chela's bingo at the grandparents' club (infiltracion.md, step 3): she calls a number every CALL_EVERY seconds
## from the bingo stand, in an order drawn with the seed, and after ROUND_CALLS numbers she shouts "¡Bingo!" herself
## and a new round starts. Each cop takes a card on a table (ClubBingoCard) and has MARK_TIME to mark a number on it;
## a miss makes the neighbor at that table notice (`missed`, for the suspicion in step 4). The host calls and decides
## the misses; online the guests follow its state (NpcSync). Every number here is (propuesta).

signal missed(card: ClubBingoCard)

const CALL_EVERY := 8.0
const MARK_TIME := 6.0
const ROUND_CALLS := 24
const SAY_TIME := 3.0

@export var case_seed := 0
var cards: Array[ClubBingoCard] = []
## The grandparents at the tables, for who notices a miss.
var members: Array = []
var round_number := 0
## How many numbers were called this round.
var calls := 0
var _order: Array[int] = []
var _call_left := CALL_EVERY
var _bubble: Label3D
var _bubble_left := 0.0
var _board: Label3D
## Guests: the misses already shown, card by card.
var _shown_misses := {}


func _ready() -> void:
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.05, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.005
	_bubble.outline_size = 10
	_bubble.font_size = 48
	_bubble.hide()
	add_child(_bubble)
	_board = Label3D.new()
	_board.name = "Board"
	_board.position = Vector3(0, 2.42, 0)
	_board.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_board.pixel_size = 0.006
	_board.outline_size = 12
	_board.font_size = 64
	_board.modulate = Color(1, 0.85, 0.3)
	add_child(_board)
	_start_round()


## Puts card `card` (number `index` of the club) under the bingo.
func add_card(card: ClubBingoCard, index: int) -> void:
	card.numbers = ClubBingoCard.numbers_for(case_seed, index)
	card.bingo = self
	cards.append(card)


func last_called() -> int:
	return _order[calls - 1] if calls > 0 else 0


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _start_round() -> void:
	calls = 0
	_order.clear()
	for n in range(1, 76):
		_order.append(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["club bingo", case_seed, round_number])
	for i in range(_order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := _order[i]
		_order[i] = _order[j]
		_order[j] = swap
	for card in cards:
		card.clear()
	_show_board()


## Host: the next number now.
func call_next() -> void:
	if calls >= ROUND_CALLS:
		_say(tr("BINGO_WIN_CHELA"))
		round_number += 1
		_start_round()
		return
	var n := _order[calls]
	calls += 1
	_say(tr("BINGO_CALL") % ClubBingoCard.label(n))
	for card in cards:
		card.called(n)
	_show_board()


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	for card in cards:
		for n: int in card.pending.keys():
			card.pending[n] += delta
			if card.pending[n] >= MARK_TIME:
				card.pending.erase(n)
				card.misses += 1
				_noticed(card)
	_call_left -= delta
	if _call_left <= 0.0:
		_call_left = CALL_EVERY
		call_next()


## The miss on `card`: the grandparent nearest to it says so.
func _noticed(card: ClubBingoCard) -> void:
	_shown_misses[card] = card.misses
	var nearest: Node3D = null
	for member: Node3D in members:
		if not nearest or member.global_position.distance_to(card.global_position) \
				< nearest.global_position.distance_to(card.global_position):
			nearest = member
	if nearest:
		nearest.say("BINGO_NEIGHBOR_%d" % (card.misses % 3))
	missed.emit(card)


func _say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = SAY_TIME


func _show_board() -> void:
	_board.text = ClubBingoCard.label(last_called()) if calls > 0 else "BINGO"


## Online: what the guests need (NpcSync): the round, the numbers called and every card.
func net_state() -> Array:
	return [round_number, calls, cards.map(func(card: ClubBingoCard) -> Array: return card.net_state())]


func apply_net_state(state: Array) -> void:
	if state[0] != round_number:
		round_number = state[0]
		_start_round()
	calls = state[1]
	for i in mini(cards.size(), state[2].size()):
		cards[i].apply_net_state(state[2][i])
		# A miss the host decided: the neighbor says it here too.
		if cards[i].misses > _shown_misses.get(cards[i], 0):
			_noticed(cards[i])
	_show_board()
