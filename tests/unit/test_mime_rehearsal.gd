extends GutTest

## The mimes' rehearsal (infiltracion-mimos.md, step 4, decision 170): Maestra Pausa switches between mime (hold H)
## and statue (don't move) on the stage; a cop doing it wrong in front of a mime raises their suspicion, off the stage
## during a rehearsal too, and during a statue the mimes see less.

const LEVEL := preload("res://scenes/levels/mime_theater.tscn")

var theater: MimeTheater
var rehearsal: MimeRehearsal
var cop: Cop


func before_each() -> void:
	theater = LEVEL.instantiate()
	cop = theater.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(theater)
	await wait_physics_frames(2)
	rehearsal = theater.rehearsal
	cop.input_enabled = true


## Puts the cop on the free mark in front of the most mimes, standing.
func _on_stage() -> void:
	cop.global_position = theater.global_transform * (theater.free_marks[0] + Vector3(0, 0.1, 0))
	rehearsal._last_at = Vector3.INF
	rehearsal._track_walk()


## A mime who isn't busy miming the robbery to a neighbor (the recording), so they look around.
func _watching_mime() -> ClubMember:
	for member: ClubMember in theater.members:
		if not member.distracted:
			return member
	return null


## Lets the grace after a switch pass and judges.
func _judge() -> void:
	rehearsal.since_switch = MimeRehearsal.GRACE + 0.1
	rehearsal.judge()


func test_the_first_rehearsal_starts_after_a_while_with_the_mime() -> void:
	assert_false(rehearsal.is_rehearsal())
	rehearsal._lead(MimeRehearsal.FIRST + 0.1)
	assert_true(rehearsal.is_rehearsal())
	assert_false(rehearsal.statue, "mime first")
	assert_eq(theater.pausa.said(), "PAUSA_REHEARSAL")


func test_it_switches_between_mime_and_statue() -> void:
	rehearsal.start_rehearsal()
	rehearsal._lead(MimeRehearsal.MIME.y + 0.1)
	assert_true(rehearsal.statue)
	rehearsal._lead(MimeRehearsal.STATUE.y + 0.1)
	assert_false(rehearsal.statue)


func test_miming_during_the_mime_is_right() -> void:
	rehearsal.start_rehearsal()
	_on_stage()
	rehearsal.force_miming = true
	watch_signals(rehearsal)
	_judge()
	assert_eq(rehearsal.good_seconds, 1)
	assert_signal_not_emitted(rehearsal, "missed")


func test_not_miming_during_the_mime_is_wrong() -> void:
	rehearsal.start_rehearsal()
	_on_stage()
	watch_signals(rehearsal)
	_judge()
	assert_signal_emitted_with_parameters(rehearsal, "missed", [cop, MimeRehearsal.NOT_MIMING])


func test_moving_during_the_statue_is_wrong_and_standing_still_is_right() -> void:
	rehearsal.start_rehearsal()
	rehearsal._switch(true)
	_on_stage()
	_judge()
	assert_eq(rehearsal.good_seconds, 1, "still")
	watch_signals(rehearsal)
	cop.global_position += Vector3(0.6, 0, 0)
	rehearsal._track_walk()
	_judge()
	assert_signal_emitted_with_parameters(rehearsal, "missed", [cop, MimeRehearsal.MOVED])


func test_the_mimes_who_see_it_get_suspicious() -> void:
	var mime := _watching_mime()
	cop.global_position = mime.global_transform * Vector3(0, 0.1, -2.0)
	assert_true(mime.sees_cop(cop))
	rehearsal.missed.emit(cop, MimeRehearsal.MOVED)
	assert_almost_eq(mime.suspicion, MimeRehearsal.MOVED, 0.01)


func test_off_the_stage_during_a_rehearsal_is_suspicious() -> void:
	cop.put_on_disguise("mime_beret", 0.0)
	cop.put_on_disguise("mime_face", 0.0)
	assert_eq(theater.suspicion.offence(cop, 0.0), 0.0)
	rehearsal.start_rehearsal()
	assert_eq(theater.suspicion.offence(cop, 0.0), ClubSuspicion.SITTING_OUT)
	_on_stage()
	assert_eq(theater.suspicion.offence(cop, 0.0), 0.0, "on the stage")


func test_the_mimes_see_less_during_a_statue() -> void:
	var mime := _watching_mime()
	var angle := deg_to_rad(55.0)
	# To the side toward the middle of the room: a mime by the wall would have the cop behind it.
	var left := mime.global_transform * Vector3(sin(angle) * 3.0, 0.1, -cos(angle) * 3.0)
	var right := mime.global_transform * Vector3(-sin(angle) * 3.0, 0.1, -cos(angle) * 3.0)
	cop.global_position = left if theater.to_local(left).length() < theater.to_local(right).length() else right
	assert_true(mime.sees_cop(cop), "off to the side, in the usual cone")
	rehearsal.start_rehearsal()
	rehearsal._switch(true)
	assert_false(mime.sees_cop(cop), "a statue doesn't turn its head")
	rehearsal._switch(false)
	assert_true(mime.sees_cop(cop))


func test_the_rehearsal_ends_and_the_mimes_look_around_again() -> void:
	rehearsal.start_rehearsal()
	rehearsal._switch(true)
	rehearsal._process(MimeRehearsal.REHEARSAL + 1.0)
	assert_false(rehearsal.is_rehearsal())
	assert_false(rehearsal.statue)
	assert_eq(theater.members[0].sight_angle, ClubMember.SIGHT_ANGLE)
