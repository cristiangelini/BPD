extends GutTest

## The club's bingo (infiltracion.md, step 3): Doña Chela calls numbers, each cop takes a card and has 6 s to mark a
## called number on it, and a miss makes the neighbor at the table notice.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var cop: Cop


func before_each() -> void:
	club = LEVEL.instantiate()
	club.case_seed = 4242
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	# The test calls the numbers itself.
	club.bingo.set_physics_process(false)


## Calls numbers until one is on `card`, and returns it.
func _call_until_on(card: ClubBingoCard) -> int:
	for i in ClubBingo.ROUND_CALLS:
		club.bingo.call_next()
		if card.has_number(club.bingo.last_called()):
			return club.bingo.last_called()
	return 0


func test_a_card_per_cop_on_free_seats() -> void:
	assert_eq(club.bingo.cards.size(), GrandpaClub.CARDS)
	for card in club.bingo.cards:
		var on_table := false
		for table: Vector3 in club.tables:
			var at := club.global_transform * table
			on_table = on_table or Vector2(card.global_position.x - at.x, card.global_position.z - at.z).length() < 0.6
		assert_true(on_table, "lying on a table")


func test_a_card_has_the_bingo_columns_and_a_free_middle() -> void:
	var numbers := ClubBingoCard.numbers_for(4242, 0)
	assert_eq(numbers.size(), 25)
	assert_eq(numbers[12], 0, "free middle")
	for i in numbers.size():
		if i == 12:
			continue
		var column := int(i / 5.0)
		assert_between(numbers[i], column * 15 + 1, column * 15 + 15)
	assert_eq(ClubBingoCard.numbers_for(4242, 0), numbers, "same seed, same card")
	assert_eq(ClubBingoCard.label(12), "B-12")
	assert_eq(ClubBingoCard.label(75), "O-75")


func test_same_seed_same_calls() -> void:
	var first: Array[int] = []
	for i in 5:
		club.bingo.call_next()
		first.append(club.bingo.last_called())
	var other := ClubBingo.new()
	other.case_seed = 4242
	add_child_autofree(other)
	other.set_physics_process(false)
	for i in 5:
		other.call_next()
		assert_eq(other.last_called(), first[i])


func test_a_taken_card_marks_what_was_called() -> void:
	var card := club.bingo.cards[0]
	card.use(cop)
	assert_true(card.claimed)
	var n := _call_until_on(card)
	assert_ne(n, 0, "one of its numbers came out")
	assert_true(card.pending.has(n))
	card.use(cop)
	assert_true(card.marked.has(n), "marked")
	assert_true(card.pending.is_empty())


func test_an_untaken_card_doesnt_wait_for_marks() -> void:
	var card := club.bingo.cards[1]
	_call_until_on(card)
	assert_true(card.pending.is_empty())


func test_a_number_left_unmarked_is_a_miss_the_neighbor_notices() -> void:
	var card := club.bingo.cards[0]
	card.use(cop)
	_call_until_on(card)
	watch_signals(club.bingo)
	club.bingo._physics_process(ClubBingo.MARK_TIME + 0.1)
	assert_eq(card.misses, 1)
	assert_signal_emitted(club.bingo, "missed")
	var spoke := club.members.filter(func(member: ClubMember) -> bool: return member.said().begins_with("BINGO_NEIGHBOR"))
	assert_eq(spoke.size(), 1, "the neighbor says it")


func test_after_a_round_chela_wins_and_the_marks_go() -> void:
	var card := club.bingo.cards[0]
	card.use(cop)
	_call_until_on(card)
	card.use(cop)
	for i in ClubBingo.ROUND_CALLS + 1:
		club.bingo.call_next()
	assert_eq(club.bingo.round_number, 1)
	assert_true(card.marked.is_empty(), "a clean card")


func test_a_guest_follows_the_hosts_bingo() -> void:
	var card := club.bingo.cards[0]
	card.use(cop)
	_call_until_on(card)
	card.use(cop)
	club.bingo.call_next()
	var state: Array = club.bingo.net_state()
	var guest: GrandpaClub = LEVEL.instantiate()
	guest.case_seed = 4242
	guest.get_node("Cop").input_enabled = false
	add_child_autofree(guest)
	await wait_physics_frames(1)
	guest.bingo.set_physics_process(false)
	guest.bingo.apply_net_state(state)
	assert_eq(guest.bingo.last_called(), club.bingo.last_called())
	assert_eq(guest.bingo.cards[0].marked, card.marked)
	assert_true(guest.bingo.cards[0].claimed)
