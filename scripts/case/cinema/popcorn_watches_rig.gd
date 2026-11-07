class_name PopcornWatchesRig
extends CinemaRig

## The watches in the popcorn (allanamiento-cine.md, "Los relojes en las palomitas"): doña Bobina smuggles watches in
## the popcorn buckets. The bucket full of watches is hidden with the ticket booth's scale and the list of clients; on
## the candy counter one popcorn is made of metal and goes "tic tac" (E on it is the story's own clue, on the checklist
## the first time), and every POP_EVERY seconds the popcorn machine pops a watch instead of a popcorn. Every number here
## is (propuesta).

signal popped

const POP_EVERY := 15.0
## How long a popped watch shows over the machine.
const POP_SECONDS := 2.5
## The metal popcorn on the counter, between the bowl's place and the machine.
const TICKING_AT := Vector3(4.1, 1.08, 9.5)
const GOLD := Color(0.9, 0.72, 0.2)

var ticking: ClueSpot
var pops := 0
var _until_pop := POP_EVERY
var _watch: Node3D
var _watch_left := 0.0


func setup(place: Cinema) -> void:
	super.setup(place)
	ticking = ClueSpot.new()
	ticking.name = "TickingPopcorn"
	ticking.size = Vector3(0.2, 0.15, 0.2)
	ticking.prompt = "PROMPT_TICKING_POPCORN"
	ticking.text = "HINT_TICKING_POPCORN"
	ticking.position = TICKING_AT + Vector3(0, Cinema.FLOOR_TOP, 0)
	place.add_child(ticking)
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.75, 0.75, 0.78)
	metal.metallic = 0.9
	metal.roughness = 0.25
	var corn := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.035
	sphere.height = 0.06
	corn.mesh = sphere
	corn.material_override = metal
	ticking.add_child(corn)
	var tick := Label3D.new()
	tick.text = "CINEMA_TICK_TACK"
	tick.font_size = 32
	tick.pixel_size = 0.005
	tick.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tick.position.y = 0.2
	ticking.add_child(tick)
	ticking.read.connect(func(_text: String) -> void: place.raid.add_clue(tr("CLUE_TICKING_POPCORN")))
	_watch = Node3D.new()
	_watch.name = "PoppedWatch"
	_watch.visible = false
	var gold := StandardMaterial3D.new()
	gold.albedo_color = GOLD
	gold.metallic = 0.8
	var shell := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.06
	disc.bottom_radius = 0.06
	disc.height = 0.02
	shell.mesh = disc
	shell.rotation.x = PI / 2
	shell.material_override = gold
	_watch.add_child(shell)
	var bang := Label3D.new()
	bang.text = "CINEMA_WATCH_POP"
	bang.font_size = 40
	bang.pixel_size = 0.006
	bang.outline_size = 8
	bang.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bang.position.y = 0.25
	_watch.add_child(bang)
	place.add_child(_watch)


## The machine pops a watch: it jumps out over the glass for a moment.
func pop() -> void:
	pops += 1
	_watch_left = POP_SECONDS
	_watch.visible = true
	popped.emit()


func _process(delta: float) -> void:
	if _watch_left > 0.0:
		_watch_left = maxf(_watch_left - delta, 0.0)
		var up := 1.0 - _watch_left / POP_SECONDS
		_watch.position = Cinema.POPCORN_AT + Vector3(0, Cinema.POPCORN_SIZE.y + 0.2 + sin(up * PI) * 0.6, 0.35)
		_watch.rotation.y += delta * 6.0
		_watch.visible = _watch_left > 0.0
		return
	if cinema.glass_cracked:
		return
	_until_pop -= delta
	if _until_pop <= 0.0:
		_until_pop = POP_EVERY
		pop()
