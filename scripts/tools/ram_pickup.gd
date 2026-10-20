class_name RamPickup
extends StaticBody3D

## The battering ram lying on the ground, where a cop dropped it (it comes from the armory). E picks it up.


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TAKE_RAM"


func use(cop: Cop) -> void:
	if cop.ram:
		return
	cop.equip_ram()
	queue_free()
