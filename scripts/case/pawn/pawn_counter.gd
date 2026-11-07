class_name PawnCounter
extends Area3D

## "Todo tiene precio" (allanamiento-empenos.md, step 2): the top of the pawn shop's counter. Something a cop leaves on
## it (let go, resting there TAKE_AFTER seconds) changes hands:
## - something for sale (the shop's own goods, or something pawned before) is bought: its price comes off the case
##   money and it's the cops' from then on;
## - anything else is pawned: Don Regateo appraises it (Appraisal: he turns away for a while, or prices it at a
##   glance, or catches on and won't buy), then the shop pays and puts it up for sale in a glass case at twice that,
##   with its tag. Evidence too: to get it back you buy it, or take it out of the shop without paying.
## Something for sale that leaves the shop without being paid for was taken, and the shop knows (Don Regateo adds it to
## the complaint, step 3). Every number here is (propuesta).

signal pawned(item: Grabbable, price: int)
signal bought(item: Grabbable, price: int)
signal taken(item: Grabbable)

const TAKE_AFTER := 2.0
## What the shop pays: evidence by its value, anything else a little.
const EVIDENCE_SHARE := 0.05
const LEAST := 5
const MARKUP := 2
const STEAL_COMPLAINT := 10.0
const RESTING := 0.3

var shop: PawnShop
## What's for sale (item -> price), and what the cops already paid for (item -> true).
var for_sale := {}
var paid := {}
## What the shop paid the cops for what they pawned, and what the cops paid the shop.
var cash_out := 0
var spent := 0
var _resting := {}
## What Don Regateo is appraising now, and what he refused (ignored until it leaves the counter).
var _appraising: Grabbable
var _refused := {}


func setup(place: PawnShop, center: Vector3, size: Vector3) -> void:
	shop = place
	position = center
	collision_layer = 0
	collision_mask = 4
	monitoring = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


## The shop's own goods: for sale from the start, with their tags.
func stock(item: Grabbable, price: int) -> void:
	for_sale[item] = price
	_tag(item, price)


## What the shop pays for `item`.
static func appraise(item: Grabbable) -> int:
	if item is Evidence:
		return maxi(LEAST, roundi((item as Evidence).value * EVIDENCE_SHARE))
	return LEAST


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	var here := {}
	var refused := {}
	for body in get_overlapping_bodies():
		var item := body as Grabbable
		if not item or paid.has(item) or item == _appraising:
			continue
		if _refused.has(item):
			refused[item] = true
			continue
		if item.is_held() or item.linear_velocity.length() > RESTING:
			continue
		here[item] = _resting.get(item, 0.0) + delta
		if here[item] >= TAKE_AFTER and _change_hands(item):
			here.erase(item)
			if _refused.has(item):
				refused[item] = true
	_resting = here
	_refused = refused
	for item: Grabbable in for_sale.keys():
		if not is_instance_valid(item):
			for_sale.erase(item)
		elif not shop.is_inside(shop.to_local(item.global_position)):
			for_sale.erase(item)
			_untag(item)
			taken.emit(item)


## Whether `item` changed hands (or is being appraised, or was refused); false while he's busy with another one.
func _change_hands(item: Grabbable) -> bool:
	if for_sale.has(item):
		var price: int = for_sale[item]
		for_sale.erase(item)
		paid[item] = true
		spent += price
		_untag(item)
		shop.say_at(item.global_position + Vector3.UP * 0.6, "PAWN_SOLD")
		bought.emit(item, price)
		return true
	var verdict := shop.appraisal.bring() if shop.appraisal else "quick"
	match verdict:
		"busy":
			return false
		"refused":
			_refused[item] = true
		"slow":
			_appraising = item
		_:
			_pawn(item)
	return true


## Don Regateo is done with his loupe: what he looked at is pawned, if it's still on the counter and nobody took it.
func appraisal_done() -> void:
	var item := _appraising
	_appraising = null
	if item and is_instance_valid(item) and not item.is_held() and overlaps_body(item):
		_pawn(item)


## The shop pays for `item` and puts it on show at twice that.
func _pawn(item: Grabbable) -> void:
	var paid_out := appraise(item)
	cash_out += paid_out
	var slot := shop.free_display_slot()
	item.linear_velocity = Vector3.ZERO
	item.angular_velocity = Vector3.ZERO
	item.global_transform = Transform3D(shop.global_basis, shop.to_global(slot + Vector3.UP * 0.2))
	for_sale[item] = paid_out * MARKUP
	_tag(item, paid_out * MARKUP)
	shop.say_at(shop.to_global(shop.COUNTER_AT + Vector3(0, 2.0, 0.6)), tr("PAWN_APPRAISED") % paid_out)
	pawned.emit(item, paid_out)


## The price tag over something for sale.
func _tag(item: Grabbable, price: int) -> void:
	var tag := Label3D.new()
	tag.name = "PriceTag"
	tag.text = "$%d" % price
	tag.font_size = 40
	tag.pixel_size = 0.004
	tag.outline_size = 8
	tag.modulate = Color(1.0, 0.85, 0.3)
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.position = Vector3.UP * 0.45
	tag.top_level = false
	item.add_child(tag)


func _untag(item: Grabbable) -> void:
	var tag := item.get_node_or_null("PriceTag")
	if tag:
		tag.queue_free()
