extends GutTest

## The internal affairs agent (docs/diseno/sobornos.md, decisions 191 and 192).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func after_each() -> void:
	Campaign.current = null


func _cop(at := Vector3.ZERO) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.position = at
	add_child_autofree(cop)
	return cop


func _agent(at: Vector3) -> InternalAffairsAgent:
	var agent := InternalAffairsAgent.new()
	agent.position = at
	add_child_autofree(agent)
	return agent


func test_he_only_comes_while_investigating() -> void:
	var cop := _cop()
	var campaign := Campaign.start_new()
	assert_null(InternalAffairsAgent.join(cop), "no investigation, no agent")
	campaign.investigation = true
	var agent := InternalAffairsAgent.join(cop)
	assert_not_null(agent)
	autofree(agent)
	assert_null(InternalAffairsAgent.join(cop), "only one")
	campaign.jailed = true
	assert_false(InternalAffairsAgent.investigating(), "not in the jailbreak's night")


func test_he_sees_a_cop_close_by_but_not_far_or_behind_a_wall() -> void:
	var cop := _cop()
	var agent := _agent(Vector3(0, 0, 6))
	await wait_physics_frames(2)
	assert_true(agent.sees(cop))
	agent.position = Vector3(0, 0, Bribes.SEEN_REACH + 3)
	await wait_physics_frames(1)
	assert_false(agent.sees(cop), "too far")
	agent.position = Vector3(0, 0, 6)
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4, 4, 0.2)
	shape.shape = box
	wall.add_child(shape)
	wall.position = Vector3(0, 1, 3)
	add_child_autofree(wall)
	await wait_physics_frames(2)
	assert_false(agent.sees(cop), "a wall in between")


func test_a_bribe_in_front_of_him_is_caught() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	var cop := _cop()
	var agent := _agent(Vector3(0, 0, 6))
	await wait_physics_frames(2)
	cop.belt_bribe(null, 200)
	assert_eq(campaign.shift_bribes, 0, "the bribe doesn't count")
	assert_eq(campaign.shift_caught, 1)
	assert_eq(agent.said(), "AGENT_CAUGHT")


func test_a_bribe_out_of_his_sight_counts() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	var cop := _cop()
	_agent(Vector3(0, 0, Bribes.SEEN_REACH + 5))
	await wait_physics_frames(2)
	cop.belt_bribe(null, 200)
	assert_eq(campaign.shift_bribes, 200)


func test_he_follows_the_cop_and_shows_his_badge() -> void:
	var cop := _cop()
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 0.2, 60)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	add_child_autofree(floor_body)
	var agent := _agent(Vector3(0, 0, 20))
	await wait_physics_frames(60)
	assert_lt(agent.global_position.z, 20.0, "he walks after the cop")
	agent.cuffed(20.0)
	assert_false(agent.is_cuffed())
	assert_eq(agent.said(), "AGENT_BADGE")
	assert_eq(Handcuffs.offer_of(agent), 0, "and never offers a bribe")
	assert_ne(cop, null)


func test_the_cop_is_told_when_the_agent_sees_the_bribe() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	var cop := _cop()
	_agent(Vector3(0, 0, 6))
	await wait_physics_frames(2)
	cop.belt_bribe(null, 150)
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_BRIBE_CAUGHT")


func test_an_offer_is_made_once_for_every_cop() -> void:
	var cop := _cop()
	var person: StaticBody3D = preload("res://tests/unit/test_bribes.gd").Cuffable.new()
	add_child_autofree(person)
	cop.belt_bribe_offered(person)
	assert_eq(Handcuffs.offer_of(person), 0, "nobody gets it again")
