class_name CrimeScenePlace
extends Node3D

## What every crime scene has in common (escena-circo.md, step 1): the pastry contest's tent and the circus are both
## one of these. The place builds itself and its suspects, and CrimeSceneCase plays the case on top of it: the place
## puts the case's clues where they go (`set_up_case`), says where a cop is at the scene (`at_scene`), where the culprit's
## getaway waits (`getaway`) and whether its witness took offense. `variant` picks the case's texts, the suspects'
## traits and the getaway (CrimeSceneCase.VARIANTS).

## Same seed, same suspects.
@export var case_seed := 1
## Which case this place plays: a key of CrimeSceneCase.VARIANTS.
var variant := "pastry"
## Where the cops bag the clues they carry.
var bags: EvidenceBags


## Puts the case's clues in the place and tells the suspects and the witness about the case. Each place does it.
func set_up_case(_case: CrimeSceneCase) -> void:
	pass


## The suspect's body, by index (the order of the case's traits).
func suspect(_index: int) -> CollisionObject3D:
	return null


## Whether a point in the world (ignoring height) is at the scene.
func at_scene(_world: Vector3) -> bool:
	return false


## Where the culprit's getaway waits, in the world ("at"), and the points it rides through before its route ("via").
func getaway(_index: int, _city: Node3D) -> Dictionary:
	return {"at": global_transform, "via": []}


## The witness took offense (cuffed or shouted at) and says nothing more.
func witness_offended() -> bool:
	return false


func offend_witness() -> void:
	pass


## Online: what a guest's place needs from the host's that the case doesn't carry (CrimeSceneCase.snapshot).
func net_state() -> Dictionary:
	return {}


func apply_net_state(_state: Dictionary) -> void:
	pass


## The cops accused a suspect at the board (by index), rightly or not. At the wedding, Rosa reacts.
func accused(_index: int, _right: bool) -> void:
	pass


## A cop shouted (VoiceChat): the witness may take offense.
func shouted_by(_cop: Cop) -> void:
	pass
