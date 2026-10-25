class_name FleeingCar
extends CityEvent

## The fleeing car (ciudad-viva.md, "Auto que huye"): a car runs a red light and speeds off down the middle of the
## streets, turning at random crossings. Boxed in by the patrol car until it's stuck STOP_STUCK seconds, it's stopped
## and pays MONEY; through its last crossing, it got away. A short chase, like the chase case's (persecucion.md).
## Every number here is (propuesta).

const MONEY := 80
const LEGS := 10
const STOP_STUCK := ChaseCase.STOP_SECONDS

var car: SuspectCar


## A random drive over the street grid from crossing `start` (column, row of streets): LEGS stretches, never back the
## way it came, never off the grid. Points on the ground, in the city's space.
static func route(start: Vector2i, rng: RandomNumberGenerator) -> Array[Vector3]:
	var at := start
	var came := Vector2i.ZERO
	var points: Array[Vector3] = [_crossing(at)]
	for leg in LEGS:
		var options: Array[Vector2i] = []
		for dir: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var to := at + dir
			if dir == -came or to.x < 0 or to.y < 0 or to.x > CityLayout.COLUMNS or to.y > CityLayout.ROWS:
				continue
			options.append(dir)
		came = options[rng.randi() % options.size()]
		at += came
		points.append(_crossing(at))
	return points


static func _crossing(at: Vector2i) -> Vector3:
	return Vector3(CityLayout.street_x(at.x), 0, CityLayout.street_z(at.y))


func begin(start: Vector2i, rng: RandomNumberGenerator) -> void:
	car = SuspectCar.new()
	car.kind = "traffic_%d" % (rng.randi() % 4)
	add_child(car)
	car.follow_path(route(start, rng), global_transform)
	car.global_position += Vector3.UP * 0.2


func _physics_process(_delta: float) -> void:
	if done or not car:
		return
	if car.stuck_for >= STOP_STUCK:
		car.driving = false
		finish(MONEY)
	elif car.finished():
		car.hide()
		finish(0)
