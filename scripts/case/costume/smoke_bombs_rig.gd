class_name SmokeBombsRig
extends CostumeRig

## The smoke bombs (allanamiento-disfraces.md, "Las bombas de humo"): Don Fantoche sells banned colored smoke bombs
## to magicians and party pranksters. The box of bombs (8 kg, the main evidence), the hat with a double bottom and the
## list of buyers are hidden. The show hat on the wig trunk puffs smoke when it's thrown (ShowHat, the story's clue),
## and every PINK_EVERY seconds a pink cloud comes out of the stock room. Every number here is (propuesta).

const HAT_AT := Vector3(CostumeShop.TRUNK_AT.x, CostumeShop.FLOOR_TOP + 0.51, CostumeShop.TRUNK_AT.z)
const PINK_AT := Vector3(-1.5, CostumeShop.FLOOR_TOP + 0.3, CostumeShop.STOCK_Z)
const PINK_EVERY := 25.0
const PINK := Color(1.0, 0.48, 0.78, 0.6)

var hat: ShowHat
var pink_clouds := 0
var _pink_left := PINK_EVERY
var _heard := false


func setup(place: CostumeShop) -> void:
	super.setup(place)
	hat = ShowHat.new()
	hat.position = HAT_AT
	place.add_child(hat)
	hat.puffed.connect(_on_puffed)


func _on_puffed() -> void:
	if not _heard:
		_heard = true
		shop.raid.add_clue(tr("CLUE_SHOW_HAT"))


func _physics_process(delta: float) -> void:
	_pink_left -= delta
	if _pink_left > 0.0:
		return
	_pink_left = PINK_EVERY
	pink_clouds += 1
	cloud(shop, PINK_AT, PINK, 2.0)


## A one-shot cloud of `color` smoke at `at` (in `parent`'s space), `size` times the hat's, that frees itself.
static func cloud(parent: Node, at: Vector3, color: Color, size: float) -> CPUParticles3D:
	var smoke := CPUParticles3D.new()
	smoke.name = "SmokeCloud"
	smoke.position = at
	smoke.one_shot = true
	smoke.explosiveness = 0.85
	smoke.amount = int(30 * size)
	smoke.lifetime = 3.0
	smoke.direction = Vector3.UP
	smoke.spread = 70.0
	smoke.gravity = Vector3(0, 0.2, 0)
	smoke.initial_velocity_min = 0.3 * size
	smoke.initial_velocity_max = 0.9 * size
	smoke.damping_min = 0.4
	smoke.damping_max = 0.8
	smoke.scale_amount_min = 1.0 * size
	smoke.scale_amount_max = 2.2 * size
	var ball := SphereMesh.new()
	ball.radius = 0.12
	ball.height = 0.24
	ball.radial_segments = 8
	ball.rings = 4
	var look := StandardMaterial3D.new()
	look.albedo_color = color
	look.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material = look
	smoke.mesh = ball
	parent.add_child(smoke)
	smoke.emitting = true
	smoke.finished.connect(smoke.queue_free)
	return smoke
