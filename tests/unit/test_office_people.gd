extends GutTest

## Formularios Infinitos' people (escena-oficina.md, step 2; FormsOffice, OfficePerson, RobotVacuum).


func _office() -> FormsOffice:
	var office := FormsOffice.new()
	add_child_autofree(office)
	return office


func _walk_all(office: FormsOffice) -> void:
	for _step in 3000:
		var moving := false
		for employee in office.employees:
			if employee.walking():
				employee._physics_process(0.05)
				moving = true
		if not moving:
			return


func test_six_employees_at_six_different_desks() -> void:
	var office := _office()
	assert_eq(office.employees.size(), FormsOffice.EMPLOYEES)
	var seen := {}
	for i in office.employees.size():
		var employee := office.employees[i]
		assert_eq(employee.who, "employee")
		assert_false(seen.has(office.desk_of[i]), "nobody shares a desk")
		seen[office.desk_of[i]] = true
		assert_eq(employee.position, FormsOffice.stand_at(office.desk_of[i]), "each stands at his desk")
		assert_eq(office.room_of(office.to_global(employee.position + Vector3.UP)), "open_space")
		assert_not_null(employee.part("briefcase"), "all with the same briefcase")


func test_the_bell_sends_each_one_to_another_free_desk() -> void:
	var office := _office()
	var before := office.desk_of.duplicate()
	office.ring_desk_bell()
	var seen := {}
	for i in office.employees.size():
		assert_ne(office.desk_of[i], before[i], "a new desk")
		assert_false(seen.has(office.desk_of[i]), "and free")
		seen[office.desk_of[i]] = true
		assert_true(office.employees[i].walking(), "he walks there")
	_walk_all(office)
	for i in office.employees.size():
		assert_false(office.employees[i].walking())
		assert_almost_eq(office.employees[i].position, FormsOffice.stand_at(office.desk_of[i]), Vector3.ONE * 0.01,
			"and gets there")


func test_the_bell_rings_by_itself() -> void:
	var office := _office()
	assert_eq(office.bell_in, FormsOffice.DESK_CHANGE_EVERY)
	var before := office.desk_of.duplicate()
	office._physics_process(FormsOffice.DESK_CHANGE_EVERY + 0.1)
	assert_ne(office.desk_of, before, "after the wait they change desks")
	assert_eq(office.bell_in, FormsOffice.DESK_CHANGE_EVERY, "and it waits again")


func test_the_same_seed_puts_them_at_the_same_desks() -> void:
	var one := FormsOffice.new()
	one.case_seed = 7
	add_child_autofree(one)
	var two := FormsOffice.new()
	two.case_seed = 7
	add_child_autofree(two)
	assert_eq(one.desk_of, two.desk_of)


func test_the_manager_the_intern_and_pelusa() -> void:
	var office := _office()
	assert_eq(office.manager.who, "manager")
	assert_eq(office.room_of(office.to_global(office.manager.position + Vector3.UP)), "manager",
		"el señor Trámite is in his office")
	assert_not_null(office.manager.part("stamp"), "with his stamp")
	assert_eq(office.intern.who, "intern")
	assert_eq(office.room_of(office.to_global(office.intern.position + Vector3.UP)), "open_space",
		"Benja is by the reception")
	assert_not_null(office.intern.part("papers"), "behind his papers")
	var start := office.vacuum.position
	assert_eq(office.floor_of(office.to_global(start + Vector3.UP * 0.2)), 1, "Pelusa goes round the first floor")
	for _step in 20:
		office.vacuum._physics_process(0.1)
	assert_gt(office.vacuum.position.distance_to(start), 0.5, "and it moves")
	for point in FormsOffice.VACUUM_ROUTE:
		assert_ne(office.room_of(office.to_global(point + Vector3.UP * 0.2)), "", "its round stays inside")


## (An employee says his lines while he's off for a coffee; otherwise E asks him for one, test_office_files.)
func test_their_lines_go_round_and_translate() -> void:
	var office := _office()
	office.employees[0].on_break = true
	for person: OfficePerson in [office.employees[0], office.manager, office.intern]:
		var lines := int(OfficePerson.WHO[person.who].lines)
		assert_eq(person.line_key(lines), person.line_key(0), "they go round")
		for n in lines:
			assert_ne(tr(person.line_key(n)), person.line_key(n), "%s is translated" % person.line_key(n))
		assert_ne(tr(person.prompt_key(null)), person.prompt_key(null))
		person.use(null)
		assert_eq(person.said(), person.line_key(person.index))
		person.use(null)
		assert_eq(person.said(), person.line_key(person.index + 1), "a different one each time")
