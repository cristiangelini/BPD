class_name GlassesDisplay
extends StaticBody3D

## A wall display of glasses at the optician's (docs/diseno/allanamiento-optica.md): E tries a pair on. The shop
## picks the pair and what it does to the screen (OpticianShop.try_on).

signal tried(cop: Cop)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRY_GLASSES"


func use(cop: Cop) -> void:
	tried.emit(cop)
