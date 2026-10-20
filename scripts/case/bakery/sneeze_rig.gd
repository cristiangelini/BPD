class_name SneezeRig
extends BakeryRig

## The sneezing flour (panaderia.md, "Polvo para estornudar"): one of the storeroom's flour sacks is the pepper sack
## marked with an X. Cops near it sneeze every so often and drop what they hold. Every number here is (propuesta).

const PEPPER_SCENE := preload("res://scenes/props/pepper_sack.tscn")
## Cops this close to the pepper sack sneeze every SNEEZE_EVERY seconds, give or take SNEEZE_JITTER.
const SNEEZE_RANGE := 3.0
const SNEEZE_EVERY := 5.0
const SNEEZE_JITTER := 2.0

## Seconds until each cop near the pepper sack sneezes, by cop.
var _sneeze_left := {}
var _rng := RandomNumberGenerator.new()


func setup(place: Bakery) -> void:
	super.setup(place)
	_rng.seed = place.case_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 31 + 7
	place.pepper_sack = rng.randi_range(0, place.sacks.size() - 1)
	var plain := place.sacks[place.pepper_sack]
	var sack: Evidence = PEPPER_SCENE.instantiate()
	sack.position = plain.position
	place.add_child(sack)
	plain.queue_free()
	place.sacks[place.pepper_sack] = sack
	place.main = sack


func _physics_process(delta: float) -> void:
	sneezes(delta)


## Cops near the pepper sack count down to their next sneeze.
func sneezes(delta: float) -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.vehicle or cop.global_position.distance_to(bakery.main.global_position) > SNEEZE_RANGE:
			_sneeze_left.erase(cop)
			continue
		var left: float = _sneeze_left.get(cop, _next_sneeze()) - delta
		if left <= 0.0:
			sneeze(cop)
			left = _next_sneeze()
		_sneeze_left[cop] = left


func _next_sneeze() -> float:
	return SNEEZE_EVERY + _rng.randf_range(-SNEEZE_JITTER, SNEEZE_JITTER)


## A cop sneezes: drops what's in their hands.
func sneeze(cop: Cop) -> void:
	cop.get_node("Grabber").release()
	cop.show_hint("HINT_SNEEZE")
