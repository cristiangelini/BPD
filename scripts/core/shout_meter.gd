class_name ShoutMeter
extends RefCounted

## Tells a shout from talk in the player's own voice (interrogatorio.md, "Las acciones"): loud enough for long enough.
## Fed with the 16 bit mono samples the player's own microphone sends.

## How loud (RMS, 0 to 1) and for how many seconds in a row it counts as a shout (propuesta).
const SHOUT_LEVEL := 0.3
const SHOUT_SECONDS := 0.3

var _loud := 0.0
var _counted := false


## How loud some 16 bit samples are: their RMS, 0 (silence) to 1.
static func loudness(pcm: PackedByteArray) -> float:
	var count := pcm.size() / 2
	if count == 0:
		return 0.0
	var total := 0.0
	for i in count:
		var sample := pcm.decode_s16(i * 2) / 32768.0
		total += sample * sample
	return sqrt(total / count)


## Adds a chunk of voice; true once per shout, when it has been loud for SHOUT_SECONDS.
func feed(pcm: PackedByteArray, mix_rate: int) -> bool:
	if loudness(pcm) < SHOUT_LEVEL:
		_loud = 0.0
		_counted = false
		return false
	_loud += pcm.size() / 2.0 / mix_rate
	if _counted or _loud < SHOUT_SECONDS:
		return false
	_counted = true
	return true
