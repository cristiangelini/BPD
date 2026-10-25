class_name FruitTraits
extends RefCounted

## What sets a fruit seller's pickup apart (control-frutas.md, "Cómo es", step 2), besides its color and the name on
## its sign: the crate of other fruit it carries and the fruit seller's hat. And which of its watermelons sound odd:
## the wanted one's hollow ones hide the gold watches; some innocent ones carry one overripe watermelon that sounds
## just as odd. The keys are the texts that name them. Pure data. Every number here is (propuesta).

const CRATES: Array[String] = ["bananas", "oranges", "pineapples"]
const HATS: Array[String] = ["straw", "cap", "beret"]
## The wanted pickup's hollow watermelons.
const HOLLOW := Vector2i(2, 3)
## An innocent pickup carries one overripe watermelon this often.
const OVERRIPE_CHANCE := 0.35


static func draw(rng: RandomNumberGenerator) -> Dictionary:
	return {"crate": CRATES[rng.randi() % CRATES.size()], "hat": HATS[rng.randi() % HATS.size()]}


## Each watermelon's kind, for `count` of them: `hollow` hollow ones, else maybe one overripe.
static func melon_kinds(rng: RandomNumberGenerator, count: int, hollow: int) -> Array[String]:
	var kinds: Array[String] = []
	kinds.resize(count)
	kinds.fill("normal")
	var spots := range(count)
	if hollow > 0:
		for i in mini(hollow, count):
			kinds[spots.pop_at(rng.randi() % spots.size())] = "hollow"
	elif rng.randf() < OVERRIPE_CHANCE:
		kinds[spots[rng.randi() % spots.size()]] = "overripe"
	return kinds


static func crate_text(crate: String) -> String:
	return "FRUIT_CRATE_" + crate.to_upper()


static func hat_text(hat: String) -> String:
	return "FRUIT_HAT_" + hat.to_upper()
