class_name SongMeter
extends RefCounted

## Tells singing from a few words in the player's own voice (fuga.md, "Distraerlo"): the microphone can't tell a song
## from talk, so voice that goes on with no pause longer than GAP for SING_SECONDS counts as singing (propuesta).
## Fed with the 16 bit mono samples the player's own microphone sends.

const SING_LEVEL := 0.03
const SING_SECONDS := 2.0
const GAP := 0.4

var _sung := 0.0
var _last := -INF


## Adds a chunk of voice heard at `now` (seconds).
func feed(pcm: PackedByteArray, mix_rate: int, now: float) -> void:
	if ShoutMeter.loudness(pcm) < SING_LEVEL:
		return
	if now - _last > GAP:
		_sung = 0.0
	_sung += pcm.size() / 2.0 / mix_rate
	_last = now


## Whether the player is singing at `now`.
func is_singing(now: float) -> bool:
	return now - _last <= GAP and _sung >= SING_SECONDS
