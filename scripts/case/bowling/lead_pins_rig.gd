extends BowlingRig

## The lead pins (allanamiento-bolera.md, "Los pinos de plomo"): on the lane Don Chuza's rivals play, the pins are cast
## in lead. Lane 4's ten pins weigh 5 kg, don't tip over and hardly slide, so a ball bounces off them and rolls back
## toward whoever threw it. A cop who picks one up feels the weight (the first time, the clue). The mold, a spare lead
## pin and the lead works' invoice are hidden. Every number here is (propuesta).

const LANE := 3
const LEAD_KG := 5.0
const LEAD_BOUNCE := 0.9
## A ball that reaches them comes back with this much of its speed.
const REBOUND := 0.7

var felt := false


func shared() -> Array[String]:
	return ["felt"]


func setup(place: Bowling) -> void:
	super.setup(place)
	alley.main = alley.hidden[0]
	var lead := PhysicsMaterial.new()
	lead.bounce = LEAD_BOUNCE
	for pin: RigidBody3D in alley.pins[LANE]:
		pin.mass = LEAD_KG
		pin.axis_lock_angular_x = true
		pin.axis_lock_angular_z = true
		pin.physics_material_override = lead
	var wall := alley._area(Vector3(Bowling.LANE_X[LANE], Bowling.FLOOR_TOP + 0.2, Bowling.HEAD_PIN_Z + 0.12),
		Vector3(Bowling.LANE_WIDTH, 0.4, 0.2))
	wall.body_entered.connect(_rebound)


## A ball rolling into the lead pins bounces off them and rolls back, spinning the other way.
func _rebound(body: Node3D) -> void:
	var ball := body as BowlingBall
	if not ball or not multiplayer.is_server():
		return
	var v := alley.global_basis.inverse() * ball.linear_velocity
	if v.z > -1.0:
		return
	ball.linear_velocity = alley.global_basis * Vector3(v.x, 0, -v.z) * REBOUND
	ball.angular_velocity = -ball.angular_velocity * REBOUND


func _physics_process(_delta: float) -> void:
	for pin: Grabbable in alley.pins[LANE]:
		# Rooted to the lane, except in a cop's hands.
		pin.axis_lock_linear_x = not pin.is_held()
		pin.axis_lock_linear_z = not pin.is_held()
		if pin.is_held() and not felt:
			felt = true
			alley._say(alley.to_local(pin.global_position) + Vector3.UP * 0.8, "BOWL_LEAD_HEAVY")
			alley.raid.add_clue(tr("BOWL_LEAD_CLUE"))
			return
