class_name StolenFilmRig
extends CinemaRig

## The stolen film (allanamiento-cine.md, "La película robada"): doña Bobina shows the festival's prize film she kept
## after the screening. The can with the film is hidden with the festival badge and the statuette; the film is so good
## that every CRY_EVERY seconds a spectator bursts into tears, and in the screen's corner "PROPIEDAD DEL FESTIVAL" can
## be read: a cop who walks up to the front by that corner while the film runs finds the story's own clue (on the
## checklist the first time). Every number here is (propuesta).

signal read_by(cop: Cop)

const CRY_EVERY := 8.0
const CRIES: Array[String] = ["CINEMA_CRY_1", "CINEMA_CRY_2", "CINEMA_CRY_3"]
## The watermark in the screen's top right corner (seen from the seats), and the floor in front of it where a cop reads it.
const MARK_AT := Vector3(-5.2, 5.6, 6.1)
const READ_AT := Vector3(-5.2, 0.0, 3.6)
const NEAR := 2.5

var mark: Label3D
var read_by_cops := {}
var crying := 0
var _until_cry := CRY_EVERY / 2


func setup(place: Cinema) -> void:
	super.setup(place)
	mark = Label3D.new()
	mark.name = "FestivalMark"
	mark.text = "CINEMA_FESTIVAL_MARK"
	mark.font_size = 40
	mark.pixel_size = 0.006
	mark.modulate = Color(0.25, 0.25, 0.3, 0.8)
	mark.position = MARK_AT
	mark.rotation.y = PI
	place.add_child(mark)
	var area := Area3D.new()
	area.name = "NearMark"
	area.collision_layer = 0
	area.collision_mask = 2
	area.position = READ_AT + Vector3(0, place.floor_at(READ_AT.z), 0)
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = NEAR
	shape.shape = ball
	area.add_child(shape)
	place.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			read_mark(body))


## `cop` came up to the front by the watermark: if the film is running they read it and, the first time anyone does,
## it's the clue.
func read_mark(cop: Cop) -> void:
	if read_by_cops.has(cop) or not cinema.film_running:
		return
	read_by_cops[cop] = true
	cop.show_hint("HINT_FESTIVAL_MARK")
	if read_by_cops.size() == 1:
		cinema.raid.add_clue(tr("CLUE_FESTIVAL_MARK"))
	read_by.emit(cop)


func _process(delta: float) -> void:
	mark.visible = cinema.film_running
	if not cinema.film_running or cinema.spectators.is_empty():
		return
	_until_cry -= delta
	if _until_cry <= 0.0:
		_until_cry = CRY_EVERY
		cinema.spectators[crying % cinema.spectators.size()].say(tr(CRIES[crying % CRIES.size()]))
		crying += 1
