extends GutTest

## The carriers' files (escena-correo.md, step 3): the culprit's blue tongue (CarrierTraits), PostCarrier's parts, the
## cap and the tongue, and CrimeSceneCase's post_office variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_has_a_blue_tongue() -> void:
	for seed_value in range(1, 30):
		var carriers := CarrierTraits.draw(seed_value)
		var plan := CrimePlan.draw(carriers, seed_value, CrimeSceneCase.VARIANTS.post_office.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(CarrierTraits.COUNT, seed_value))
		assert_true(carriers[plan.culprit].blue, "seed %d: the culprit licked the stamp" % seed_value)
		var blue := carriers.filter(func(c: Dictionary) -> bool: return c.blue).size()
		assert_between(blue, CarrierTraits.BLUE.x, CarrierTraits.BLUE.y)
		assert_eq(CrimePlan.suspects_left(carriers, carriers[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## A post office with its case set up, and a cop at hand.
func _post_office_case(seed_value: int) -> Array:
	var post_office := PostOffice.new()
	post_office.case_seed = seed_value
	add_child_autofree(post_office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = post_office
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [post_office, case, cop]


func _not_stubborn(post_office: PostOffice) -> PostCarrier:
	for carrier in post_office.carriers:
		if not carrier.stubborn:
			return carrier
	return null


func test_empty_hands_get_the_route_the_cap_then_the_tongue() -> void:
	var made := _post_office_case(4)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, CarrierTraits.draw(4), "the case's suspects are the carriers")
	var carrier := _not_stubborn(post_office)
	assert_eq(carrier.prompt_key(cop), "PROMPT_CARRIER_TALK")
	carrier.use(cop)
	assert_string_contains(carrier.said(), carrier.route_name())
	assert_eq(case.file_traits(carrier.index).route, carrier.traits.route, "the route is in the file")
	assert_eq(carrier.prompt_key(cop), "PROMPT_CARRIER_CAP")
	carrier.use(cop)
	assert_false(carrier.part("cap").visible, "the cap comes off")
	assert_eq(case.file_traits(carrier.index).hair, carrier.traits.hair)
	assert_eq(carrier.prompt_key(cop), "PROMPT_CARRIER_TONGUE")
	carrier.use(cop)
	assert_true(carrier.part("tongue").visible, "out comes the tongue")
	assert_eq(carrier.said(), "CARRIER_TONGUE_BLUE" if carrier.traits.blue else "CARRIER_TONGUE_PINK")
	assert_eq(case.file_traits(carrier.index).blue, carrier.traits.blue, "the tongue is in the file")
	assert_eq(carrier.prompt_key(cop), "PROMPT_CARRIER_TALK", "then they talk about their route again")


func test_a_bite_before_the_tongue_washes_the_blue_off() -> void:
	var made := _post_office_case(7)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var carrier: PostCarrier = post_office.carriers[case.plan.culprit]
	carrier.stubborn = false
	var bread := Bread.new()
	add_child_autofree(bread)
	carrier.feed(bread)
	assert_true(carrier.washed)
	carrier.talk()
	carrier.ask_cap()
	carrier.stick_out_tongue()
	assert_eq(carrier.said(), "CARRIER_TONGUE_WASHED", "the culprit's blue is gone")
	assert_false(case.file_traits(carrier.index).has("blue"), "so the file can't tell")
	assert_true(case.file_parts[carrier.index].tongue, "but the part is done")
	TranslationServer.set_locale("es")
	assert_string_contains(case.file_text(carrier.index), tr("FILE_TONGUE_WASHED"))
	var other := post_office.carriers[(case.plan.culprit + 1) % CarrierTraits.COUNT]
	other.stubborn = false
	other.talk()
	other.ask_cap()
	other.stick_out_tongue()
	other.feed(bread)
	assert_false(other.washed, "a bite after the look changes nothing")


func test_the_stubborn_carrier_keeps_the_cap_until_they_eat() -> void:
	var made := _post_office_case(6)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := post_office.carriers.filter(func(c: PostCarrier) -> bool: return c.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn carrier")
	var carrier: PostCarrier = stubborn[0]
	carrier.use(cop)
	carrier.use(cop)
	assert_eq(carrier.said(), "CARRIER_CAP_NO")
	assert_true(carrier.cap_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	carrier.feed(bread)
	assert_true(carrier.part("teeth").visible, "they show their teeth biting")
	assert_false(carrier.cap_on, "fed, they take it off")
	assert_true(case.file_parts[carrier.index].teeth and case.file_parts[carrier.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _post_office_case(8)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var carrier := post_office.carriers[2]
	assert_false(case.file_parts.has(2), "no file yet")
	carrier.photographed(cop)
	assert_eq(carrier.said(), "CARRIER_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, carrier.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % carrier.traits.shoe, "the photo shows the shoes")
	assert_string_contains(text, tr("FILE_TONGUE_UNKNOWN"))
	assert_eq(carrier.dusted(cop), tr("PRINTS_COOK") % carrier.traits.name)
	carrier.stubborn = false
	carrier.use(cop)
	carrier.use(cop)
	carrier.use(cop)
	var bread := Bread.new()
	add_child_autofree(bread)
	carrier.feed(bread)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, tongue and route: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_ROUTE") % carrier.route_name())
	assert_string_contains(text, tr("FILE_TONGUE_BLUE") if carrier.traits.blue else tr("FILE_TONGUE_PINK"))
	for key in ["PROMPT_CARRIER_TONGUE", "CARRIER_CAP_NO", "FILE_TONGUE_BLUE", "FILE_ROUTE", "BRIEF_POST_OFFICE_A_stamp",
			"HINT_CARRIER_LEFT", "HINT_FILE_tongue", "FILE_PART_route"]:
		assert_ne(tr(key), key, "%s is translated" % key)
