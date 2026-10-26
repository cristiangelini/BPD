class_name CircusTruck
extends RefCounted

## The circus move check (control-circo.md): the circus leaves town down the avenue, its striped trucks each with a
## cage on the bed and an animal in it, among a few city cars. One of the animals is El Peludo, the jewelry thief in
## a costume (step 4). Every number here is (propuesta).

## The animals that ride in the cages, their names on the papers, and their models (facing +Z, feet at y = 0).
const ANIMALS: Array[String] = ["lion", "bear", "gorilla", "monkey", "seal", "zebra", "kangaroo"]
const ANIMAL_NAMES: Array[String] = ["ANIMAL_LION", "ANIMAL_BEAR", "ANIMAL_GORILLA", "ANIMAL_MONKEY", "ANIMAL_SEAL",
	"ANIMAL_ZEBRA", "ANIMAL_KANGAROO"]
const ANIMAL_MODELS: Array[PackedScene] = [preload("res://assets/models/animal_lion.glb"),
	preload("res://assets/models/animal_bear.glb"), preload("res://assets/models/animal_gorilla.glb"),
	preload("res://assets/models/animal_monkey.glb"), preload("res://assets/models/seal.glb"),
	preload("res://assets/models/animal_zebra.glb"), preload("res://assets/models/animal_kangaroo.glb")]
## The truck's stripes, and the names the radio gives them.
const STRIPES: Array[Color] = [Color("d8342c"), Color("3a82d8"), Color("3a9a4a"), Color("8a4ac8")]
const STRIPE_NAMES: Array[String] = ["COLOR_RED", "COLOR_BLUE", "COLOR_GREEN", "COLOR_VIOLET"]
## The cages' numbers, painted over their doors.
const CAGES := Vector2i(1, 20)
## Without a plan, about this share of the queue are circus trucks; the rest, city cars.
const SHARE := 0.7
const TRUCK_MODEL := preload("res://assets/models/circus_truck.glb")
const CAGE_MODEL := preload("res://assets/models/circus_cage.glb")
const DOOR_MODEL := preload("res://assets/models/circus_cage_door.glb")
const DRIVER_MODEL := preload("res://assets/models/npc_domadora.glb")
## On the truck (forward +Z): the cage's floor middle, its size (the model's), the driver's seat and the side sign.
const CAGE_AT := Vector3(0, 0.8, -0.95)
const CAGE_SIZE := Vector3(1.9, 1.7, 2.5)
const DRIVER_AT := Vector3(0.5, -0.05, 1.1)
const SIGN_AT := Vector3(1.07, 1.05, 1.0)
## The animal stands a bit back from the door, facing it (and the cops behind the truck).
const ANIMAL_AT := Vector3(0, 0.1, 0.2)
## The patrol car's food buckets (step 2), and what each animal eats.
const FOODS: Array[String] = ["bananas", "fish", "meat", "carrots"]
const DIET := {"lion": "meat", "bear": "fish", "gorilla": "bananas", "monkey": "bananas", "seal": "fish",
	"zebra": "carrots", "kangaroo": "carrots"}
## A bucket this close to a cage (m, from its bars) feeds the animal in it.
const FEED_REACH := 1.5
## Fed the wrong food, an animal roars and shakes its cage: the queue's patience goes up this much.
const ANGRY_PATIENCE := 5.0
## What El Peludo says when he's offered food, only a person would (CIRCUS_REFUSE_0 to 9).
const REFUSE_LINES := 10
## Step 3: El Peludo, unwatched this long (s), does something only a person would (CIRCUS_HUMAN_0 to 9) for
## ACT_SECONDS. A cop watches his cage when it's this close (m) and within WATCH_ANGLE of where the cop faces.
const UNWATCHED := 5.0
const ACT_SECONDS := 2.0
const HUMAN_ACTS := 10
const WATCH_RANGE := 25.0
const WATCH_ANGLE := deg_to_rad(70.0)
## A real animal out of its open cage (LooseAnimal) goes for good after this long (s): a complaint from the circus.
const LOOSE_SECONDS := 40.0


## A car's circus traits when no plan says them: from its plate, so every PC agrees. Empty for a city car.
static func traits_of(plate: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["circus traits", plate])
	if rng.randf() >= SHARE:
		return {}
	return draw(rng)


## A circus truck's animal (one of ANIMALS), its stripes (one of STRIPES) and its cage's number.
static func draw(rng: RandomNumberGenerator) -> Dictionary:
	return {"animal": ANIMALS[rng.randi() % ANIMALS.size()], "stripes": rng.randi() % STRIPES.size(),
		"cage": rng.randi_range(CAGES.x, CAGES.y)}


## The name the papers give `animal`.
static func animal_name(animal: String) -> String:
	return ANIMAL_NAMES[maxi(ANIMALS.find(animal), 0)]


## Builds `car` (a QueueCar) as the circus truck in `traits`: its body to bump into, the striped truck, the cage with
## its door and number, the animal in it and its driver, the circus's tamer.
static func build(car: QueueCar, traits: Dictionary) -> void:
	car._add_box(Vector3(2.1, 1.55, 1.95), Vector3(0, 0.975, 1.325))
	car._add_box(Vector3(2.1, 0.6, 2.65), Vector3(0, 0.5, -0.975))
	car._add_box(CAGE_SIZE, CAGE_AT + Vector3(0, CAGE_SIZE.y / 2, 0))
	var paint := StandardMaterial3D.new()
	paint.albedo_color = STRIPES[int(traits.get("stripes", 0)) % STRIPES.size()]
	var model: Node3D = TRUCK_MODEL.instantiate()
	model.name = "Model"
	car.add_child(model)
	QueueCar._paint(model, paint)
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		car.add_child(wheel)
	var cage := Node3D.new()
	cage.name = "Cage"
	cage.position = CAGE_AT
	car.add_child(cage)
	var bars: Node3D = CAGE_MODEL.instantiate()
	bars.name = "Bars"
	cage.add_child(bars)
	QueueCar._paint(bars, paint)
	var door := CageDoor.new()
	door.name = "Door"
	door.car = car
	door.position = Vector3(CAGE_SIZE.x / 2, 0, -CAGE_SIZE.z / 2)
	cage.add_child(door)
	door.opened.connect(car.open_cage)
	var animal: Node3D = ANIMAL_MODELS[maxi(ANIMALS.find(traits.get("animal", "")), 0)].instantiate()
	animal.name = "Animal"
	animal.position = ANIMAL_AT
	animal.rotation.y = PI
	cage.add_child(animal)
	var number := _label(car.tr("CIRCUS_CAGE") % int(traits.get("cage", 1)), 44, Color(0.98, 0.85, 0.3))
	number.name = "Number"
	number.position = Vector3(0, CAGE_SIZE.y - 0.12, -CAGE_SIZE.z / 2 - 0.08)
	number.rotation.y = PI
	cage.add_child(number)
	var driver: Node3D = DRIVER_MODEL.instantiate()
	driver.name = "Driver"
	driver.position = DRIVER_AT
	car.add_child(driver)
	var sign := _label(car.tr("CIRCUS_SIGN"), 56, paint.albedo_color)
	sign.name = "Sign"
	sign.position = SIGN_AT
	sign.rotation.y = PI / 2
	car.add_child(sign)


## What `animal` eats (one of FOODS).
static func food_of(animal: String) -> String:
	return DIET.get(animal, "")


## The sound `animal` makes when it's angry.
static func sound_of(animal: String) -> String:
	return "ANIMAL_SOUND_" + animal.to_upper()


## What El Peludo says the `fed`th time he's offered food.
static func refuse_line(plate: String, fed: int) -> String:
	return "CIRCUS_REFUSE_%d" % ((absi(hash(["circus refuse", plate])) + fed) % REFUSE_LINES)


## What El Peludo does the `acts`th time nobody watches him.
static func human_act(plate: String, acts: int) -> String:
	return "CIRCUS_HUMAN_%d" % ((absi(hash(["circus human", plate])) + acts) % HUMAN_ACTS)


## Whether some cop watches `car`'s cage: close enough and facing it.
static func watched(car: Node3D) -> bool:
	var cage := car.global_transform * (CAGE_AT + Vector3(0, CAGE_SIZE.y / 2, 0))
	for cop: Cop in car.get_tree().get_nodes_in_group("cops"):
		var flat := cage - cop.global_position
		flat.y = 0.0
		if flat.length() > WATCH_RANGE:
			continue
		var look := -cop.global_basis.z
		look.y = 0.0
		if flat.length() < 0.5 or look.normalized().angle_to(flat.normalized()) <= WATCH_ANGLE / 2:
			return true
	return false


## Where an animal goes back into `car`'s cage, on the street behind it (world space).
static func cage_mouth(car: Node3D) -> Vector3:
	var at := car.global_transform * (CAGE_AT + Vector3(0, 0, -CAGE_SIZE.z / 2 - 0.8))
	at.y = car.global_position.y
	return at


## Whether `point` (world space) is close enough to `car`'s cage to feed the animal in it.
static func near_cage(car: Node3D, point: Vector3) -> bool:
	var off := car.to_local(point) - CAGE_AT
	var out := Vector2(maxf(absf(off.x) - CAGE_SIZE.x / 2, 0.0), maxf(absf(off.z) - CAGE_SIZE.z / 2, 0.0))
	return out.length() < FEED_REACH and off.y > -1.5 and off.y < CAGE_SIZE.y + 0.5


## The animal in `car`'s cage bobs, eating.
static func munch(car: Node3D) -> void:
	var animal := animal_of(car)
	if animal:
		var tween := car.create_tween()
		for i in 3:
			tween.tween_property(animal, "scale", Vector3(1.05, 0.92, 1.05), 0.15)
			tween.tween_property(animal, "scale", Vector3.ONE, 0.15)


## `car`'s cage shakes: the animal in it is angry.
static func shake(car: Node3D) -> void:
	var cage := car.get_node_or_null("Cage") as Node3D
	if cage:
		var tween := car.create_tween()
		for i in 6:
			tween.tween_property(cage, "position:x", CAGE_AT.x + (0.06 if i % 2 == 0 else -0.06), 0.06)
		tween.tween_property(cage, "position:x", CAGE_AT.x, 0.06)


## The animal riding in `car`'s cage, or null for a city car.
static func animal_of(car: Node3D) -> Node3D:
	return car.get_node_or_null("Cage/Animal") as Node3D


static func _label(text: String, size: int, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.004
	label.modulate = color
	label.outline_modulate = Color(0.1, 0.08, 0.06)
	label.outline_size = 14
	return label
