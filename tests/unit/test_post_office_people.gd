extends GutTest

## The post office's people (escena-correo.md, step 2): the six carriers alike, Doña Sellito and Cartita
## (CarrierTraits, PostCarrier, PostBoss, PostParrot).


func test_the_six_carriers_are_drawn_with_the_seed() -> void:
	var carriers := CarrierTraits.draw(11)
	assert_eq(carriers.size(), CarrierTraits.COUNT)
	assert_eq(CarrierTraits.draw(11), carriers, "same seed, same carriers")
	var looks := {}
	var routes := {}
	var blue := 0
	for carrier in carriers:
		looks[CarrierTraits.signature(carrier)] = true
		routes[carrier.route] = true
		blue += 1 if carrier.blue else 0
	assert_eq(looks.size(), CarrierTraits.COUNT, "no two look the same")
	assert_eq(routes.size(), CarrierTraits.ROUTES.size(), "each covers another route")
	assert_eq(CarrierTraits.ROUTES, PostOffice.ROUTE_BOXES.keys(), "the routes of the post boxes")
	assert_between(blue, CarrierTraits.BLUE.x, CarrierTraits.BLUE.y, "two or three have a blue tongue")


func test_the_people_are_in_their_places() -> void:
	var post_office := PostOffice.new()
	post_office.case_seed = 4
	add_child_autofree(post_office)
	assert_eq(post_office.carriers.size(), CarrierTraits.COUNT)
	var rooms := {}
	for carrier in post_office.carriers:
		var room := post_office.room(carrier.global_position)
		rooms[room] = rooms.get(room, 0) + 1
		var target: Vector3 = {"counter": carrier.position + Vector3(0, 0, 1), "boxes": PostOffice.box_at(9),
			"sorting": PostOffice.MACHINE_AT}[room]
		var to := post_office.to_global(target) - carrier.global_position
		to.y = 0
		assert_gt(carrier.global_basis.z.dot(to.normalized()), 0.8, "%s faces what they look after" % carrier.traits.name)
	assert_eq(rooms, {"counter": 2, "boxes": 1, "sorting": 3})
	for carrier in post_office.carriers.slice(0, 2):
		assert_lt(carrier.position.z, PostOffice.COUNTER_Z, "%s is behind the counter" % carrier.traits.name)
	assert_eq(post_office.suspect(2), post_office.carriers[2])
	assert_null(post_office.suspect(CarrierTraits.COUNT))
	assert_eq(post_office.room(post_office.boss.global_position), "counter", "Doña Sellito in the hall")
	assert_eq(post_office.room(post_office.parrot.global_position), "counter", "Cartita on the counter")
	assert_almost_eq(post_office.parrot.position.x, PostOffice.WINDOWS[1], 0.01, "at window 2")


func test_a_carrier_shows_their_own_traits() -> void:
	var post_office := PostOffice.new()
	post_office.case_seed = 9
	add_child_autofree(post_office)
	for carrier in post_office.carriers:
		assert_false(carrier.part("teeth").visible, "teeth only when they bite")
		assert_false(carrier.part("tongue").visible, "the tongue only when they stick it out")
		assert_true(carrier.part("cap").visible)
		var tag := carrier.part("tag").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		assert_eq((tag.material_override as StandardMaterial3D).albedo_color,
			PostOffice.ROUTE_COLORS[carrier.traits.route], "the tag of their route")


func test_a_carrier_tells_their_route() -> void:
	var post_office := PostOffice.new()
	post_office.case_seed = 2
	add_child_autofree(post_office)
	TranslationServer.set_locale("es")
	var carrier: PostCarrier = post_office.carriers[0]
	carrier.use(null)
	assert_string_contains(carrier.said(), carrier.route_name())
	carrier.talk()
	assert_string_contains(carrier.said(), carrier.route_name(), "every line says the route")
	post_office.boss.use(null)
	assert_eq(post_office.boss.said(), "POST_BOSS_LINE_0")
	post_office.parrot.use(null)
	assert_eq(post_office.parrot.said(), "PARROT_LINE_0")
