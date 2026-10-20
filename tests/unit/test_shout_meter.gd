extends GutTest

## Telling a shout from talk in the player's own voice (ShoutMeter, interrogatorio.md).

const RATE := 48000


## `seconds` of a square wave at `level` (0 to 1), as 16 bit samples.
func _voice(level: float, seconds: float) -> PackedByteArray:
	var pcm := PackedByteArray()
	var count := int(RATE * seconds)
	pcm.resize(count * 2)
	for i in count:
		pcm.encode_s16(i * 2, int((1 if i % 2 == 0 else -1) * level * 32767))
	return pcm


func test_loudness_is_the_rms() -> void:
	assert_eq(ShoutMeter.loudness(PackedByteArray()), 0.0)
	assert_almost_eq(ShoutMeter.loudness(_voice(0.5, 0.01)), 0.5, 0.01)


func test_talking_is_not_shouting() -> void:
	var meter := ShoutMeter.new()
	for i in 10:
		assert_false(meter.feed(_voice(0.1, 0.1), RATE))


func test_a_long_loud_shout_counts_once() -> void:
	var meter := ShoutMeter.new()
	assert_false(meter.feed(_voice(0.6, 0.1), RATE), "a short bang isn't a shout")
	assert_false(meter.feed(_voice(0.6, 0.1), RATE))
	assert_true(meter.feed(_voice(0.6, 0.15), RATE))
	assert_false(meter.feed(_voice(0.6, 0.5), RATE), "the same shout counts once")
	meter.feed(_voice(0.0, 0.1), RATE)
	meter.feed(_voice(0.6, 0.2), RATE)
	assert_true(meter.feed(_voice(0.6, 0.2), RATE), "a new shout after a breath")
