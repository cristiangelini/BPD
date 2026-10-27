extends GutTest

## Twice the blocks (Cristian, 26/10): 10 x 7 around the old 7 x 5, every place in the block it had, the highway and
## the golf club outside the bigger city, and chases and street events that reach the new streets.

const OLD_BLOCKS := {
	"station": Vector2i(2, 2), "bank": Vector2i(3, 0), "prison": Vector2i(5, 2), "circus": Vector2i(5, 3),
	"grandpa": Vector2i(1, 2),
}


func test_the_city_has_seventy_blocks() -> void:
	assert_eq(CityLayout.blocks().size(), 70)
	assert_eq(CityLayout.blocks()[0], CityLayout.FIRST)
	assert_eq(CityLayout.blocks().back(), CityLayout.FIRST + Vector2i(CityLayout.COLUMNS, CityLayout.ROWS) - Vector2i.ONE)


func test_new_blocks_wrap_the_old_ones() -> void:
	assert_eq(CityLayout.FIRST, Vector2i(-1, -1), "one column on the west and one row on the north")
	assert_eq(CityLayout.FIRST.x + CityLayout.COLUMNS - 1, 8, "two columns on the east")
	assert_eq(CityLayout.FIRST.y + CityLayout.ROWS - 1, 5, "one row on the south")
	for id: String in OLD_BLOCKS:
		assert_eq(CityLayout.place(id).block, OLD_BLOCKS[id], "%s keeps its block" % id)


func test_blocks_sit_between_their_streets() -> void:
	for block in CityLayout.blocks():
		var c := CityLayout.block_center(block)
		assert_almost_eq(c.x, (CityLayout.street_x(block.x) + CityLayout.street_x(block.x + 1)) / 2, 0.01)
		assert_almost_eq(c.z, (CityLayout.street_z(block.y) + CityLayout.street_z(block.y + 1)) / 2, 0.01)
	assert_almost_eq(CityLayout.street_x(CityLayout.WEST), -CityLayout.SIZE.x / 2 + CityLayout.STREET / 2, 0.01)
	assert_almost_eq(CityLayout.street_x(CityLayout.EAST), CityLayout.SIZE.x / 2 - CityLayout.STREET / 2, 0.01)
	assert_almost_eq(CityLayout.street_z(CityLayout.SOUTH), CityLayout.SIZE.y / 2 - CityLayout.STREET / 2, 0.01)


func test_every_inner_crossing_has_street_names() -> void:
	assert_eq(CityLayout.crossings(true).size(), (CityLayout.COLUMNS - 1) * (CityLayout.ROWS - 1))
	assert_eq(CityLayout.crossings().size(), (CityLayout.COLUMNS + 1) * (CityLayout.ROWS + 1))
	for c in CityLayout.crossings(true):
		assert_true(c.y - CityLayout.NORTH - 1 < CityLayout.STREETS_EW.size())
		assert_true(c.x - CityLayout.WEST - 1 < CityLayout.STREETS_NS.size())


func test_the_highway_and_golf_stay_outside() -> void:
	assert_gt(HighwayLayout.HALF.x - HighwayLayout.WIDTH / 2, CityLayout.SIZE.x / 2)
	assert_gt(GolfLayout.CENTER.x - GolfLayout.HALF.x, CityLayout.SIZE.x / 2)
	assert_almost_eq(GolfLayout.CENTER.z, CityLayout.street_z(HighwayLayout.RAMP_STREET_Z), 0.01, "gate on the east ramp")


func test_a_chase_reaches_the_new_streets() -> void:
	var seen_new := false
	for s in 40:
		for c in ChaseRoute.draw(s).corners:
			assert_true(CityLayout.on_grid(c))
			seen_new = seen_new or c.x < 0 or c.y < 0 or c.x > 7 or c.y > 5
	assert_true(seen_new, "some chase goes into the new blocks")
	assert_eq(ChaseRoute.nearest_corner(Vector3(-1000, 0, -1000)), Vector2i(CityLayout.WEST, CityLayout.NORTH))
