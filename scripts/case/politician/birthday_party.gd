class_name BirthdayParty
extends Node

## Deputy Lustre's birthday party at the plaza (politico-cumple.md, step 1, decision 221): the speech is the party's
## clock, and at BLOW_AT seconds into it he leaves the lectern for the next cake on the long table (the one with its
## candles lit), the crowd sings to him for SING_TIME seconds and he blows its candles out; then he goes back to the
## lectern and the next cake's candles are lit. Only on the stage: off greeting or led by the hand, the cake waits until
## he's back at the lectern. It runs on the host. Every number here is (propuesta).

signal blew(cake: BirthdayCake)

enum State { WAITING, GOING, SINGING, RETURNING, DONE }

const BLOW_AT: Array[float] = [120.0, 240.0, 350.0]
const SING_TIME := 10.0
## He leaves the lectern this long before the song should start.
const GO_LEAD := 4.0
const SPEED := 1.6
const ARRIVED := 0.2
## He stands this far behind the cake (north of the table), facing the crowd.
const BEHIND := 0.7
const SONG_LINES := 4
const SONG_EVERY := 2.5
const BLOW_LINES := 3

var politician: Politician
var speech: PoliticianSpeech
var walks: PoliticianWalks
var fans: Array[RallyFan] = []
## In the order he blows them.
var cakes: Array[BirthdayCake] = []
var state := State.WAITING
## The cake he's on now, or the next one.
var next := 0
var blown := 0
var _target := Vector3.ZERO
var _sing_left := 0.0
var _song_left := 0.0
var _song_line := 0


func setup(speaker: Politician, the_speech: PoliticianSpeech, crowd: Array[RallyFan],
		table_cakes: Array[BirthdayCake], case_seed: int) -> void:
	politician = speaker
	speech = the_speech
	walks = PoliticianWalks.of(politician)
	fans = crowd
	cakes = table_cakes.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["birthday order", case_seed])
	for i in range(cakes.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := cakes[i]
		cakes[i] = cakes[j]
		cakes[j] = swap
	_light_next()


## The cake he'll blow next (its candles are lit), null when there's none left.
func next_cake() -> BirthdayCake:
	return cakes[next] if next < cakes.size() else null


## Seconds of the speech gone by.
func elapsed() -> float:
	return PoliticianSpeech.SPEECH_TIME - speech.left


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		State.WAITING:
			if next >= cakes.size():
				state = State.DONE
			elif speech.speaking and walks.state == PoliticianWalks.State.SPEAKING \
					and elapsed() >= BLOW_AT[mini(next, BLOW_AT.size() - 1)] - SING_TIME - GO_LEAD:
				_go()
		State.GOING:
			speech.hold_lines(1.0)
			if _walk_to(_target, delta):
				_sing()
		State.SINGING:
			speech.hold_lines(1.0)
			_sing_left -= delta
			_song_left -= delta
			if _song_left <= 0.0 and _sing_left > 0.0:
				_song_left = SONG_EVERY
				_song_line += 1
				for fan in fans:
					fan.say("BIRTHDAY_SONG_%d" % ((_song_line - 1) % SONG_LINES + 1))
			if _sing_left <= 0.0:
				_blow()
		State.RETURNING:
			speech.hold_lines(1.0)
			if _walk_to(walks.podium, delta):
				_back()


func _go() -> void:
	var cake := next_cake()
	state = State.GOING
	walks.set_physics_process(false)
	_target = Vector3(cake.global_position.x, walks.podium.y, cake.global_position.z - BEHIND)
	politician.say("BIRTHDAY_TO_CAKE")


func _sing() -> void:
	state = State.SINGING
	politician.rotation.y = PI
	_sing_left = SING_TIME
	_song_left = 0.0


func _blow() -> void:
	var cake := next_cake()
	cake.blow()
	blown += 1
	politician.say("BIRTHDAY_BLOW_%d" % ((next % BLOW_LINES) + 1))
	next += 1
	blew.emit(cake)
	state = State.RETURNING


func _back() -> void:
	politician.global_position = walks.podium
	politician.rotation.y = PI
	politician.velocity = Vector3.ZERO
	walks.set_physics_process(true)
	speech.hold_lines(Politician.SAY_TIME)
	_light_next()
	state = State.WAITING


func _light_next() -> void:
	var cake := next_cake()
	if cake:
		cake.light()


## Walks him over the stage's boards toward `to`; true once there.
func _walk_to(to: Vector3, delta: float) -> bool:
	var way := to - politician.global_position
	way.y = 0.0
	if way.length() < ARRIVED:
		politician.velocity = Vector3.ZERO
		return true
	var wish := way.normalized() * SPEED
	politician.look_at(politician.global_position + wish, Vector3.UP)
	politician.velocity.x = wish.x
	politician.velocity.z = wish.z
	politician.velocity.y = 0.0 if politician.is_on_floor() else politician.velocity.y - GameScale.GRAVITY * delta
	politician.move_and_slide()
	return false
