class_name AuctionSale
extends Node

## The auction itself (infiltracion-subasta.md, step 4, decision 177): FIRST seconds in and then every EVERY seconds Don
## Martillo puts the next lot on the easel (in the order the seed gave the kinds), opening at START. A bid takes the
## price (the first one at START, every next one STEP more): a cop's is E on a free chair he stands by (BidSeat), the
## buyers' come from the chairs they sit in, each up to the top the seed gave him for this lot. After ONCE seconds
## without bids "A la una...", after TWICE "a las dos..." and after HAMMER the gavel comes down: the lot goes to the
## last bidder. If that's a cop, the lot is delivered beside his chair and its price comes out of the shift's pay
## (`spent`, step 5 puts it on the planilla). A lot no cop bid on makes the buyers in the hall suspicious. While a lot
## is up, the buyers out of the hall come to watch and notice nothing else: the moment to search. The host decides all
## of it and tells the guests: the lines, the lot and its price, the paddles and the gavel (the lot bought is a prop,
## PropSync copies it). Every number here is (propuesta).

signal opened(kind: String)
signal bid(price: int, by: Node)
signal sold(kind: String, price: int, to_cop: bool)

const FIRST := 20.0
const EVERY := 60.0
const START := 100
const STEP := 50
const ONCE := 2.0
const TWICE := 4.0
const HAMMER := 6.0
## The buyers' tops: between these, in STEPs.
const TOP_MIN := 150
const TOP_MAX := 600
## A buyer waits between these seconds before outbidding.
const RIVAL_MIN := 1.0
const RIVAL_MAX := 2.5
const NO_BID := 25.0
## A cop bids from a chair this close (m, on the floor).
const SEAT_REACH := 1.2
const IDLE := 0
const SELLING := 1
## What a lot weighs once it's yours (kg) and its box.
const LOT_KG := {"painting": 6.0, "vase": 4.0, "statue": 12.0, "chair": 5.0}
const LOT_SIZES := {"painting": Vector3(0.7, 0.85, 0.1), "vase": Vector3(0.33, 0.5, 0.33),
	"statue": Vector3(0.34, 0.55, 0.27), "chair": Vector3(0.37, 0.53, 0.31)}

var house: AuctionHouse
var case_seed := 0
var state := IDLE
## Seconds to the next lot (host), and the order of the kinds and which comes next.
var next_left := FIRST
var order: Array[String] = []
var next_lot := 0
## The lot up: its kind, its price, who bid last (a Cop or a ClubMember) and from which chair, whether any cop bid,
## the seconds since the last bid and each seated buyer's top.
var kind := ""
var price := 0
var last_bidder: Node
var last_seat: BidSeat
var cop_bid := false
var quiet := 0.0
var tops := {}
var rival_left := 0.0
## How many lots the cops bought and what they paid, and the lots themselves.
var bought := 0
var spent := 0
var lots: Array[Grabbable] = []
## The lot stolen from a museum, or "" (when it isn't among the evidence): a buyer whispers it when it comes up, and
## buying it is evidence (step 5).
var stolen := ""
var _called := 0
var _watching: Array[ClubMember] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = hash(["auction sale", case_seed])
	order.assign(LotEasel.KINDS)
	for i in range(order.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap := order[i]
		order[i] = order[j]
		order[j] = swap
	for seat in house.seats:
		seat.raised.connect(_on_raised)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		IDLE:
			next_left -= delta
			if next_left <= 0.0:
				open()
		SELLING:
			_selling(delta)


## Host: Don Martillo puts the next lot up. Nothing if one is already up.
func open() -> bool:
	next_left = EVERY
	if state != IDLE:
		return false
	kind = order[next_lot % order.size()]
	next_lot += 1
	state = SELLING
	price = START
	last_bidder = null
	last_seat = null
	cop_bid = false
	quiet = 0.0
	_called = 0
	tops.clear()
	for member in house.members:
		if seat_of(member):
			tops[member] = _rng.randi_range(TOP_MIN / STEP, TOP_MAX / STEP) * STEP
	rival_left = _rng.randf_range(RIVAL_MIN, RIVAL_MAX)
	_show(kind, price)
	_say(house.martillo, "AUCTION_LOT_" + kind)
	for cop: Cop in house.get_tree().get_nodes_in_group("cops"):
		if house.is_inside(cop.global_position):
			cop.show_hint("HINT_AUCTION_LOT")
	_watch(true)
	if kind == stolen:
		var whisperer := house.members[_rng.randi_range(0, house.members.size() - 1)]
		_say(whisperer, "AUCTION_STOLEN_" + kind)
	opened.emit(kind)
	return true


## The chair `member` sits in, or null.
func seat_of(member: ClubMember) -> BidSeat:
	for seat in house.seats:
		if Vector2(seat.position.x - member.position.x, seat.position.z - member.position.z).length() < 0.1:
			return seat
	return null


## Whether a buyer sits in `seat`.
func taken(seat: BidSeat) -> bool:
	for member in house.members:
		if seat_of(member) == seat:
			return true
	return false


func _on_raised(cop: Cop, seat: BidSeat) -> void:
	if state != SELLING or taken(seat) or last_bidder == cop:
		return
	if Vector2(cop.global_position.x - seat.global_position.x, cop.global_position.z - seat.global_position.z).length() \
			> SEAT_REACH:
		return
	cop_bid = true
	_bid(cop, seat)


func _bid(by: Node, seat: BidSeat) -> void:
	if last_bidder:
		price += STEP
	last_bidder = by
	last_seat = seat
	quiet = 0.0
	_called = 0
	rival_left = _rng.randf_range(RIVAL_MIN, RIVAL_MAX)
	_raise(seat)
	_show(kind, price)
	bid.emit(price, by)


func _selling(delta: float) -> void:
	quiet += delta
	rival_left -= delta
	if rival_left <= 0.0:
		rival_left = _rng.randf_range(RIVAL_MIN, RIVAL_MAX)
		var next := price + (STEP if last_bidder else 0)
		var willing: Array = tops.keys().filter(func(member: ClubMember) -> bool:
			return member != last_bidder and tops[member] >= next)
		if not willing.is_empty():
			var member: ClubMember = willing[_rng.randi_range(0, willing.size() - 1)]
			_bid(member, seat_of(member))
			return
	if quiet >= HAMMER:
		_sell()
	elif quiet >= TWICE and _called < 2:
		_called = 2
		_say(house.martillo, "AUCTION_TWICE")
	elif quiet >= ONCE and _called < 1:
		_called = 1
		_say(house.martillo, "AUCTION_ONCE")


## The gavel comes down: the lot is the last bidder's (or nobody's).
func _sell() -> void:
	var done := kind
	var paid := price
	var to_cop := last_bidder is Cop
	_bang()
	if to_cop:
		bought += 1
		spent += paid
		_say(house.martillo, "AUCTION_SOLD_COP")
		_deliver(done, last_seat)
		if done == stolen and house.case:
			house.case.found("lot")
	else:
		_say(house.martillo, "AUCTION_SOLD" if last_bidder else "AUCTION_NO_SALE")
	if not cop_bid:
		for member in house.members:
			if house.in_hall(member.global_position + Vector3.UP):
				house.suspicion.raise(member, NO_BID)
		_say(house.members[_rng.randi_range(0, house.members.size() - 1)], "AUCTION_NOBODY_BID")
	_end()
	sold.emit(done, paid, to_cop)


## The bought lot, delivered on the floor beside the cop's chair: theirs to carry (or drop).
func _deliver(lot_kind: String, seat: BidSeat) -> void:
	var item := BoughtLot.new()
	item.name = "Bought%d" % bought
	item.kind = lot_kind
	item.position = seat.position + Vector3(0, LOT_SIZES[lot_kind].y / 2 + 0.02, 0.7)
	house.add_child(item)
	lots.append(item)


## While a lot is up, the buyers out of the hall come to watch and notice nothing else.
func _watch(on: bool) -> void:
	if on:
		for member in house.members:
			if not member.distracted and not house.in_hall(member.global_position + Vector3.UP):
				member.distracted = true
				_watching.append(member)
	else:
		for member in _watching:
			member.distracted = false
		_watching.clear()


func _end() -> void:
	_watch(false)
	_show("", 0)
	state = IDLE
	next_left = EVERY
	kind = ""
	tops.clear()


## Host: `who` (Don Martillo or a buyer) says `line`, on every PC.
func _say(who: ClubMember, line: String) -> void:
	var index := house.members.find(who)
	_said(index, line)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_said.rpc_id(peer, index, line)


## Index -1 is Don Martillo.
@rpc("authority", "call_remote", "reliable")
func _said(index: int, line: String) -> void:
	if index < 0:
		house.martillo.say(line)
	elif index < house.members.size():
		house.members[index].say(line)


## Host: the lot on the easel and its price on the board ("" and 0 between lots), on every PC.
func _show(lot: String, value: int) -> void:
	_shown(lot, value)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_shown.rpc_id(peer, lot, value)


@rpc("authority", "call_remote", "reliable")
func _shown(lot: String, value: int) -> void:
	if house.easel.lot != lot:
		house.easel.show_lot(lot)
	house.podium.show_price(value)


## Host: the paddle up over `seat`, on every PC.
func _raise(seat: BidSeat) -> void:
	var index := house.seats.find(seat)
	_raised_seat(index)
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_raised_seat.rpc_id(peer, index)


@rpc("authority", "call_remote", "reliable")
func _raised_seat(index: int) -> void:
	if index >= 0 and index < house.seats.size():
		house.seats[index].raise()


## Host: the gavel comes down, on every PC.
func _bang() -> void:
	_banged()
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_banged.rpc_id(peer)


@rpc("authority", "call_remote", "reliable")
func _banged() -> void:
	house.podium.bang()


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net
