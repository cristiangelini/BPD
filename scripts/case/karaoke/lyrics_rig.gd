class_name LyricsRig
extends KaraokeRig

## The lyrics with messages (allanamiento-karaoke.md, "Las letras con mensajes"): Rosaura passes messages to a gang of
## smugglers in the songs' lyrics. While a customer sings, the screen shows a line every LINE_EVERY seconds, and every
## CODE_EVERY lines one doesn't belong in any song ("y el camión llega a las tres"), and it stays STUCK seconds, with a
## shed's number. A cop who's in front of the screen and looking at it when one shows notices (the first time, the
## clue). The broken screen shows nothing. The lyrics computer, the notebook of codes and the receipt for "goods" are
## hidden. Every number here is (propuesta).

const LYRICS := ["KARAOKE_LYRIC_1", "KARAOKE_LYRIC_2", "KARAOKE_LYRIC_3", "KARAOKE_LYRIC_4"]
const CODES := ["KARAOKE_CODE_1", "KARAOKE_CODE_2", "KARAOKE_CODE_3"]
const LINE_EVERY := 4.0
const CODE_EVERY := 3
const STUCK := 6.0
## A cop this close to the screen (along the floor) and facing it reads it.
const READ_RANGE := 10.0
const READ_FACING := 0.6
const SCREEN_BLUE := Color(0.16, 0.22, 0.62)

var noticed := false
var lines := 0
## The line on the screen now (a LYRICS or CODES key, empty when nobody sings).
var showing := ""
var _text: Label3D
var _screen: MeshInstance3D
var _line_left := 0.0


func shared() -> Array[String]:
	return ["noticed"]


func setup(place: Karaoke) -> void:
	super.setup(place)
	karaoke.main = karaoke.hidden[0]
	# The story's own lyrics, over a plain blue screen.
	_screen = MeshInstance3D.new()
	var plate := BoxMesh.new()
	plate.size = Vector3(4.6, 2.0, 0.01)
	var blue := StandardMaterial3D.new()
	blue.albedo_color = SCREEN_BLUE
	blue.emission_enabled = true
	blue.emission = SCREEN_BLUE * 0.5
	plate.material = blue
	_screen.mesh = plate
	_screen.position = Karaoke.SCREEN_AT + Vector3(0, 0, 0.43)
	karaoke.add_child(_screen)
	_text = Label3D.new()
	_text.font_size = 56
	_text.pixel_size = 0.01
	_text.outline_size = 12
	_text.width = 800.0
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.modulate = Color(1.0, 0.95, 0.5)
	_text.position = Karaoke.SCREEN_AT + Vector3(0, 0, 0.45)
	karaoke.add_child(_text)


## The next line on the screen: a lyric, or one of the messages (it stays longer).
func next_line() -> void:
	lines += 1
	var code := lines % CODE_EVERY == 0
	showing = CODES[(lines / CODE_EVERY) % CODES.size()] if code else LYRICS[lines % LYRICS.size()]
	_text.text = showing
	_line_left = STUCK if code else LINE_EVERY
	if code:
		_read()


## A cop in front of the screen looking at it reads the message; the first time, the clue.
func _read() -> void:
	if noticed or not multiplayer.is_server():
		return
	var screen := karaoke.to_global(Karaoke.SCREEN_AT)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var to := Vector3(screen.x - cop.global_position.x, 0, screen.z - cop.global_position.z)
		var facing := -cop.global_basis.z
		if to.length() < READ_RANGE and Vector3(facing.x, 0, facing.z).normalized().dot(to.normalized()) > READ_FACING:
			noticed = true
			karaoke.raid.add_clue(tr("KARAOKE_LYRICS_CLUE"))
			return


func _physics_process(delta: float) -> void:
	_text.visible = not karaoke.screen_cracked
	_screen.visible = not karaoke.screen_cracked
	if not karaoke.on_turn or not karaoke.on_turn.singing or karaoke.screen_cracked:
		showing = ""
		_text.text = ""
		_line_left = 0.0
		return
	_line_left -= delta
	if _line_left <= 0.0:
		next_line()
