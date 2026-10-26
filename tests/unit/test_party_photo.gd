extends GutTest

## The costume party's group photo (infiltracion-fiesta.md, step 3, decision 171): Serpentina calls it, the guests go
## to the steps and the boss to the office; a cop moving in the count or missing at the flash raises the guests who see
## it, and a cop in the office during the photo sees the boss.

const LEVEL := preload("res://scenes/levels/party_hall.tscn")

var hall: PartyHall
var photo: PartyPhoto
var cop: Cop


func before_each() -> void:
	hall = LEVEL.instantiate()
	cop = hall.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)
	photo = hall.photo
	cop.input_enabled = true


## Lets the guests walk to where the photo sends them.
func _walk() -> void:
	await wait_seconds(PartyPhoto.WALK + 0.2)


## Puts the cop on the spot no guest took, standing.
func _on_steps() -> void:
	var taken := hall.members.map(func(guest: ClubMember) -> Vector3: return guest.position)
	for spot: Vector3 in hall.photo_spots:
		if not taken.any(func(at: Vector3) -> bool: return at.distance_to(spot) < 0.5):
			cop.global_position = hall.global_transform * (spot + Vector3(0, 0.1, 0))
			break
	photo._last_at = Vector3.INF
	photo._track_walk()


func test_the_first_photo_comes_after_a_while() -> void:
	assert_false(photo.is_photo())
	photo._process(PartyPhoto.FIRST + 0.1)
	assert_true(photo.is_photo())
	assert_eq(hall.serpentina.said(), "PARTY_PHOTO_CALL")
	assert_almost_eq(photo.next_left, PartyPhoto.EVERY, 0.01)


func test_the_guests_go_to_the_steps_and_the_boss_to_the_office() -> void:
	photo.call_photo()
	await _walk()
	for guest: ClubMember in hall.members:
		if guest == hall.boss:
			assert_true(hall.in_back_room(guest.global_position + Vector3.UP), "the boss slips into the office")
		else:
			assert_true(hall.on_steps(guest.global_position + Vector3.UP * 0.1), "%s poses" % guest.name)
			assert_lt(guest.global_basis.z.z, -0.9, "facing the hall (+Z, as -Z is forward)")
	assert_true(hall.office_door.is_open, "he left the office open")


func test_everyone_goes_back_after_the_flash() -> void:
	var home := hall.members[0].position
	photo.call_photo()
	await _walk()
	photo._process(PartyPhoto.CALL + PartyPhoto.COUNT + 0.1)
	assert_false(photo.is_photo())
	await _walk()
	assert_almost_eq(hall.members[0].position.distance_to(home), 0.0, 0.01)
	assert_false(hall.office_door.is_open)
	assert_false(hall.office_door.locked, "but he forgot to lock it")


func test_holding_still_on_the_steps_is_right() -> void:
	photo.call_photo()
	await _walk()
	_on_steps()
	photo.photo_left = PartyPhoto.COUNT
	watch_signals(photo)
	photo.judge()
	assert_eq(photo.good_seconds, 1)
	assert_signal_not_emitted(photo, "missed")


func test_moving_in_the_count_is_wrong() -> void:
	photo.call_photo()
	await _walk()
	_on_steps()
	photo.photo_left = PartyPhoto.COUNT
	watch_signals(photo)
	photo._walked = PartyPhoto.STILL + 0.2
	photo.judge()
	assert_signal_emitted_with_parameters(photo, "missed", [cop, PartyPhoto.MOVED])


func test_missing_from_the_photo_is_seen() -> void:
	photo.call_photo()
	cop.global_position = hall.global_transform * Vector3(0, 0.1, 2.0)
	watch_signals(photo)
	photo.flash()
	assert_signal_emitted_with_parameters(photo, "missed", [cop, PartyPhoto.AWAY])


func test_on_the_steps_at_the_flash_is_fine() -> void:
	photo.call_photo()
	await _walk()
	_on_steps()
	watch_signals(photo)
	photo.flash()
	assert_signal_not_emitted(photo, "missed")


func test_the_guests_who_see_it_get_suspicious() -> void:
	photo.call_photo()
	await _walk()
	# In front of the steps, where the posing guests look.
	cop.global_position = hall.global_transform * Vector3(-3.0, 0.1, -5.5)
	await wait_physics_frames(1)
	var watchers := hall.members.filter(func(guest: ClubMember) -> bool: return guest.sees_cop(cop))
	assert_gt(watchers.size(), 0, "someone on the steps sees the cop")
	var before: float = watchers[0].suspicion
	photo.missed.emit(cop, PartyPhoto.AWAY)
	assert_almost_eq(watchers[0].suspicion, before + PartyPhoto.AWAY, 0.01)


func test_a_cop_in_the_office_sees_the_boss() -> void:
	photo.call_photo()
	await _walk()
	cop.global_position = hall.global_transform * Vector3(8.0, 0.1, -7.5)
	watch_signals(photo)
	photo._look_for_boss()
	assert_true(photo.saw_boss)
	assert_signal_emitted_with_parameters(photo, "boss_seen", [cop])
	photo._look_for_boss()
	assert_signal_emit_count(photo, "boss_seen", 1, "once a photo")


func test_the_office_is_empty_between_photos() -> void:
	cop.global_position = hall.global_transform * Vector3(8.0, 0.1, -7.5)
	photo._look_for_boss()
	assert_false(photo.saw_boss)


func test_the_photo_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PARTY_PHOTO_CALL", "HINT_PARTY_PHOTO", "PARTY_PHOTO", "PARTY_PHOTO_GO", "PARTY_PHOTO_POSE",
			"PARTY_PHOTO_GOOD", "PARTY_PHOTO_MOVED", "HINT_PARTY_SAW_BOSS"]:
		assert_ne(tr(key), key)
