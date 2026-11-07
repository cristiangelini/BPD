class_name HauntedCinemaRig
extends CinemaRig

## The haunted cinema (allanamiento-cine.md, "El cine embrujado"): doña Bobina fakes a ghost to sell "terror tours". The
## ghost projector is hidden with the sheet with holes and the record of screams; every GHOST_EVERY seconds of film a
## ghost crosses the screen and every spectator screams, and behind the screen a speaker goes "uuuuh": a cop who gets
## close to it finds the story's own clue (on the checklist the first time). Every number here is (propuesta).

signal ghost_crossed
signal heard(cop: Cop)

const GHOST_EVERY := 30.0
const GHOST_SECONDS := 4.0
## The speaker behind the screen, by its east end where a cop can squeeze in, and how close a cop hears it.
const SPEAKER_AT := Vector3(5.0, 0.25, 6.7)
const NEAR := 2.0
const OOH_EVERY := 5.0

var ghost: Node3D
var speaker: Node3D
var crossings := 0
var heard_by := {}
var _until_ghost := GHOST_EVERY
var _ghost_left := 0.0
var _until_ooh := 0.0
var _ooh: Label3D


func setup(place: Cinema) -> void:
	super.setup(place)
	ghost = Node3D.new()
	ghost.name = "Ghost"
	ghost.visible = false
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.95, 0.97, 1.0, 0.85)
	white.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.6
	capsule.height = 2.4
	body.mesh = capsule
	body.scale = Vector3(1, 1, 0.1)
	body.material_override = white
	ghost.add_child(body)
	var black := StandardMaterial3D.new()
	black.albedo_color = Color.BLACK
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for side: float in [-0.22, 0.22]:
		var eye := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.12
		sphere.height = 0.24
		eye.mesh = sphere
		eye.scale = Vector3(1, 1.4, 0.2)
		eye.position = Vector3(side, 0.45, -0.08)
		eye.material_override = black
		ghost.add_child(eye)
	place.add_child(ghost)
	speaker = Node3D.new()
	speaker.name = "GhostSpeaker"
	speaker.position = SPEAKER_AT + Vector3(0, Cinema.FLOOR_TOP, 0)
	place.add_child(speaker)
	var box := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3(0.35, 0.5, 0.3)
	box.mesh = cube
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.12, 0.12, 0.14)
	box.material_override = dark
	speaker.add_child(box)
	_ooh = Label3D.new()
	_ooh.text = "CINEMA_GHOST_OOH"
	_ooh.font_size = 40
	_ooh.pixel_size = 0.008
	_ooh.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ooh.position.y = 0.7
	_ooh.no_depth_test = true
	_ooh.visible = false
	speaker.add_child(_ooh)
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = NEAR
	shape.shape = ball
	area.add_child(shape)
	speaker.add_child(area)
	area.body_entered.connect(func(body_in: Node3D) -> void:
		if body_in is Cop:
			hear(body_in))


## `cop` got close to the speaker behind the screen: what they hear and, the first time anyone does, the clue.
func hear(cop: Cop) -> void:
	if heard_by.has(cop):
		return
	heard_by[cop] = true
	cop.show_hint("HINT_GHOST_SPEAKER")
	if heard_by.size() == 1:
		cinema.raid.add_clue(tr("CLUE_GHOST_SPEAKER"))
	heard.emit(cop)


## A ghost crosses the screen from west to east and every spectator screams.
func haunt() -> void:
	crossings += 1
	_ghost_left = GHOST_SECONDS
	ghost.visible = true
	for spectator in cinema.spectators:
		spectator.say(tr("CINEMA_SCREAM"))
	ghost_crossed.emit()


func _process(delta: float) -> void:
	_until_ooh -= delta
	if _until_ooh <= 0.0:
		_until_ooh = OOH_EVERY
		_ooh.visible = not _ooh.visible
	if _ghost_left > 0.0:
		_ghost_left = maxf(_ghost_left - delta, 0.0)
		var half := Cinema.SCREEN_SIZE.x / 2 - 1.0
		ghost.position = Cinema.SCREEN_AT + Vector3(lerpf(-half, half, 1.0 - _ghost_left / GHOST_SECONDS), -0.3, -0.08)
		ghost.visible = _ghost_left > 0.0
		return
	if not cinema.film_running:
		return
	_until_ghost -= delta
	if _until_ghost <= 0.0:
		_until_ghost = GHOST_EVERY
		haunt()
