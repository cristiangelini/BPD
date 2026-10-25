class_name PoodleHairRig
extends FactoryRig

## The poodle hair (fabrica.md, "Pelo de caniche"): Fermín steals poodle hair from the groomer's and passes it off as
## doll hair. The bag of it is the main evidence, hidden with the groomer's golden comb and the fake invoice. Pink
## tufts lie on the floor from the hair machine toward where the bag is: a cop near one sneezes (and drops what they
## hold), and the first sneeze is the story's own clue. The hair machine sticks pink hair on cops walking by, and the
## belt's dolls come out hairy. Every number here is (propuesta).

const TUFTS := 8
## A cop this close to a tuft sneezes, at most every SNEEZE_EVERY seconds.
const TUFT_RANGE := 1.0
const SNEEZE_EVERY := 4.0
## Cops this close to the hair machine get pink hair, even off the belt.
const MACHINE_RANGE := 1.6
const PINK := Color(0.95, 0.63, 0.78)

var tufts: Array[Vector3] = []
var was_sneezed := false
var _sneeze_wait := {}


func setup(place: DollFactory) -> void:
	super.setup(place)
	var from: Vector3 = DollFactory.MACHINES[1].stand
	var to: Vector3 = DollFactory.SPOTS[place.hidden_spots[0]].at
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 13 + 5
	var look := StandardMaterial3D.new()
	look.albedo_color = PINK
	var fluff := SphereMesh.new()
	fluff.radius = 0.1
	fluff.height = 0.07
	fluff.radial_segments = 6
	fluff.rings = 3
	for i in TUFTS:
		var at := from.lerp(to, (i + 0.5) / TUFTS) + Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4))
		at.y = DollFactory.FLOOR_TOP + 0.02
		var tuft := MeshInstance3D.new()
		tuft.name = "Tuft%d" % i
		tuft.mesh = fluff
		tuft.material_override = look
		tuft.position = at
		place.add_child(tuft)
		tufts.append(at)
	place.fed_doll.connect(func(doll: Node3D) -> void: place.belt.mark(doll, "hair"))


func _physics_process(delta: float) -> void:
	for cop in _sneeze_wait.keys():
		_sneeze_wait[cop] = maxf(_sneeze_wait[cop] - delta, 0.0)
	var machine := factory.to_global(factory.belt.machine_at("hair"))
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.vehicle:
			continue
		var at := factory.to_local(cop.global_position)
		if _sneeze_wait.get(cop, 0.0) <= 0.0 and tufts.any(func(tuft: Vector3) -> bool:
				return Vector2(tuft.x, tuft.z).distance_to(Vector2(at.x, at.z)) <= TUFT_RANGE):
			sneeze(cop)
		if Vector2(machine.x, machine.z).distance_to(Vector2(cop.global_position.x, cop.global_position.z)) <= MACHINE_RANGE:
			factory.belt.mark_cop("hair", cop)


## A cop sneezes on the poodle hair: drops what's in their hands, and the first time it's the clue.
func sneeze(cop: Cop) -> void:
	_sneeze_wait[cop] = SNEEZE_EVERY
	cop.get_node("Grabber").release()
	cop.show_hint("HINT_SNEEZE")
	if not was_sneezed:
		was_sneezed = true
		factory.raid.add_clue(tr("CLUE_POODLE_HAIR"))
