extends GutTest

## The visiting day's tells: the hiders' looks, whistles and sweat, the nervous innocents, the clonc, the coo and the
## weight (carcel-visitas.md, step 4).

const LEVEL := preload("res://scenes/levels/prison_visits.tscn")

var prison: PrisonLevel
var plan: VisitPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.visits


func _item(kind: VisitItem.Kind, hidden: bool) -> VisitItem:
	var item := VisitItem.new()
	item.kind = kind
	item.hidden = hidden
	prison.add_child(item)
	return item


func test_a_hider_gives_themselves_away() -> void:
	var visitor := plan.visitors[0]
	visitor.pocket_hidden = true
	visitor.nervous = false
	visitor._tell_left = -1.0
	visitor._tell(0.0)
	assert_between(visitor._tell_left, PrisonVisitor.TELL_EVERY.x, PrisonVisitor.TELL_EVERY.y)
	visitor._tell(visitor._tell_left + 0.01)
	assert_has(PrisonVisitor.TELLS, visitor.said())


func test_a_calm_innocent_never_does() -> void:
	var visitor := plan.visitors[0]
	visitor.pocket_hidden = false
	visitor.item_hidden = false
	visitor.nervous = false
	visitor._tell_left = -1.0
	visitor._tell(0.0)
	visitor._tell(100.0)
	assert_eq(visitor.said(), "")


func test_a_nervous_innocent_frets() -> void:
	var visitor := plan.visitors[0]
	visitor.pocket_hidden = false
	visitor.item_hidden = false
	visitor.nervous = true
	visitor._tell_left = -1.0
	visitor._tell(0.0)
	assert_between(visitor._tell_left, PrisonVisitor.NERVOUS_EVERY.x, PrisonVisitor.NERVOUS_EVERY.y)
	visitor._tell(visitor._tell_left + 0.01)
	assert_string_starts_with(visitor.said(), "VISITOR_NERVOUS_")


func test_only_innocents_are_nervous() -> void:
	for visitor in plan.visitors:
		if visitor.nervous:
			assert_false(visitor.item_hidden or visitor.pocket_hidden)


func test_metal_inside_goes_clonc() -> void:
	var cake := _item(VisitItem.Kind.CAKE, true)
	cake.set_down()
	assert_eq(cake.sound(), "VISIT_ITEM_CLONC")
	var plain := _item(VisitItem.Kind.CAKE, false)
	plain.set_down()
	assert_eq(plain.sound(), "")
	var flowers := _item(VisitItem.Kind.FLOWERS, true)
	flowers.set_down()
	assert_eq(flowers.sound(), "", "a paper map makes no noise")


func test_the_pigeon_coos_until_its_found() -> void:
	var hat := _item(VisitItem.Kind.HAT, true)
	hat._process(VisitItem.NOISE_EVERY.y + 0.1)
	assert_eq(hat.sound(), "VISIT_ITEM_COO")
	var phone := _item(VisitItem.Kind.WATERMELON, true)
	phone._process(VisitItem.NOISE_EVERY.y + 0.1)
	assert_eq(phone.sound(), "VISIT_ITEM_BUZZ")
	var empty := _item(VisitItem.Kind.HAT, false)
	empty._process(VisitItem.NOISE_EVERY.y + 0.1)
	assert_eq(empty.sound(), "")


func test_hidden_things_weigh_more() -> void:
	var full := _item(VisitItem.Kind.WATERMELON, true)
	var plain := _item(VisitItem.Kind.WATERMELON, false)
	assert_almost_eq(full.mass, plain.mass * VisitItem.HEAVIER, 0.001)
