class_name CityCrash
extends CityEvent

## The crash (ciudad-viva.md, "El choque"): two cars hit each other at a crossing, smoke comes out and both drivers
## argue in the street while the cars behind wait and honk. A cop who talks to both drivers calms them: they push the
## cars to the curb and the street clears, paying MONEY. If nobody comes, after GIVE_UP seconds they leave on their own.
## Every number here is (propuesta).

const MONEY := 50
const GIVE_UP := 180.0
const LOOKS: Array[String] = ["cliente", "clienta", "senora", "mudancero", "abogado", "portero"]

## The two wrecks and their drivers.
var wrecks: Array[CityCar] = []
var drivers: Array[CrashDriver] = []
var _left := GIVE_UP
var _smoke: CPUParticles3D


## The two cars' places at crossing `at`: one heading east in its lane, nosed by one heading south.
static func layout(at: Vector3) -> Array[Transform3D]:
	var lane := CityLayout.STREET / 4
	return [Transform3D(Basis(Vector3.UP, PI / 2 + 0.25), at + Vector3(-lane - 1.5, 0, lane)),
		Transform3D(Basis(Vector3.UP, 0.15), at + Vector3(-lane, 0, lane - 2.6))]


func begin(at: Vector3) -> void:
	var spots := layout(at)
	for i in 2:
		var car := CityCar.new()
		car.look = randi() % TrafficCar.MODELS.size()
		car.wreck = true
		add_child(car)
		car.global_transform = spots[i]
		wrecks.append(car)
		var driver := CrashDriver.new()
		driver.look = LOOKS[randi() % LOOKS.size()]
		add_child(driver)
		driver.global_position = spots[i] * Vector3(-2.2, 0, 0)
		driver.calmed.connect(_on_calmed)
		drivers.append(driver)
	drivers[0].look_at(drivers[1].global_position, Vector3.UP, true)
	drivers[1].look_at(drivers[0].global_position, Vector3.UP, true)
	_smoke = CPUParticles3D.new()
	_smoke.amount = 30
	_smoke.lifetime = 2.5
	_smoke.direction = Vector3.UP
	_smoke.spread = 20.0
	_smoke.initial_velocity_min = 0.8
	_smoke.initial_velocity_max = 1.4
	_smoke.gravity = Vector3(0.3, 0.2, 0)
	var puff := SphereMesh.new()
	puff.radius = 0.35
	puff.height = 0.7
	var grey := StandardMaterial3D.new()
	grey.albedo_color = Color(0.4, 0.4, 0.42, 0.5)
	grey.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = grey
	_smoke.mesh = puff
	add_child(_smoke)
	_smoke.global_position = (spots[0].origin + spots[1].origin) / 2 + Vector3.UP * 0.9


func _physics_process(delta: float) -> void:
	if done:
		return
	_left -= delta
	if _left <= 0.0:
		_clear()
		finish(0)


func _on_calmed(_driver: CrashDriver) -> void:
	if done or drivers.any(func(d: CrashDriver) -> bool: return not d.calm):
		return
	_clear()
	finish(MONEY)


## The cars go to the curb and stop blocking, the smoke stops.
func _clear() -> void:
	_smoke.emitting = false
	for car in wrecks:
		var out := car.global_basis.x.normalized()
		car.global_position += out * 2.5
		car.remove_from_group("city_cars")
		car.collision_layer = 0
