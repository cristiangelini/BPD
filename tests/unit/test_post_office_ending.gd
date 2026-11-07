extends GutTest

## The post office's ending (escena-correo.md, step 7): the comisario gives the case at the station, and the culprit who
## runs off goes in the mail van, slow, dropping two "Frágil" parcels at every corner it turns (SuspectCar, ChaseDrops,
## ChaseParcel); the patrol car that hits one gets its windshield covered in envelopes for a second, a cop on foot
## kicks it, and the carrier is interrogated as one.

const LEVEL := preload("res://scenes/levels/post_office.tscn")


func test_the_mail_van_is_a_slow_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.post_office.getaway, SuspectCar.MAIL_VAN)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.MAIL_VAN))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.MAIL_VAN], SuspectCar.SPEED, "slow")
	assert_true(ChaseSuspect.MODELS.has("carrier"), "they get out as a carrier")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_carrier"), "and are interrogated as one")
	for key: String in ["CRIME_owner_carrier", "CONFESS_owner_carrier", "HINT_ESCAPE_carrier", "PROMPT_KICK_PARCEL",
			"HINT_PARCEL_KICKED"]:
		assert_ne(tr(key), key)


func test_the_van_waits_at_the_curb_and_drives_out() -> void:
	var post_office := PostOffice.new()
	add_child_autofree(post_office)
	var getaway := post_office.getaway(0, null)
	var at := post_office.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.MAIL_VAN].z / 2, PostOffice.FRONT_Z + 1.5, "clear of the door")
	assert_gt(absf(at.x - PostOffice.DOOR_FRONT_X), 5.0, "not in front of the door")
	assert_gt(absf(at.x - PostOffice.MAILBOX_AT.x), 2.0, "nor on the giant mailbox")
	assert_gt(post_office.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_parcel_is_kicked_or_hit_and_covers_the_windshield() -> void:
	var drops := DropsStub.new()
	add_child_autofree(drops)
	var kicked := ChaseParcel.new()
	kicked.gravity_scale = 0.0
	add_child_autofree(kicked)
	assert_eq(kicked.prompt_key(null), "PROMPT_KICK_PARCEL")
	kicked.use(null)
	assert_true(kicked.kicked)
	await wait_physics_frames(2)
	assert_gt(kicked.linear_velocity.length(), 1.0, "off it goes")
	var car := Node3D.new()
	add_child_autofree(car)
	var parcel := ChaseParcel.new()
	parcel.car = car
	parcel.drops = drops
	parcel.gravity_scale = 0.0
	add_child_autofree(parcel)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		if not is_instance_valid(parcel):
			break
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_almost_eq(drops.envelopes_left, ChaseParcel.ENVELOPE_SECONDS, 0.01, "the envelopes on the windshield")


func test_the_culprit_runs_off_in_the_van_dropping_parcels() -> void:
	var level: PostOfficeLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case, "the comisario gives the case")
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.MAIL_VAN)
	assert_eq(chase.who, "carrier")
	chase.chasing = true
	chase.drops._on_corner(true)
	assert_eq(chase.drops.parcels.size(), ChaseDrops.PARCELS_PER_CORNER, "two parcels at every corner")
	assert_eq(chase.drops.parcels[0].car, chase.car)
	chase.drops.parcels[0].break_open()
	await wait_physics_frames(2)
	var cover := chase.car.get_node_or_null("ConfettiCover") as Node3D
	assert_not_null(cover)
	assert_true(cover.visible, "the windshield covered")
	await wait_seconds(ChaseParcel.ENVELOPE_SECONDS + 0.2)
	assert_false(cover.visible, "and a second later it's clear")


class DropsStub:
	extends ChaseDrops

	func _ready() -> void:
		pass

	func _physics_process(_delta: float) -> void:
		pass
