class_name CloseLabel
extends Label3D

## A text over someone that only shows to a cop standing within `reach` of it (a pupil's card, the ink on the
## janitor's fingers, politico-escuela.md). It checks on its own, so it works on a guest's puppet too (NpcSync turns
## the person's own processing off there). `shown` false hides it whoever is near.

var reach := 2.0
var shown := true


func _init() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visible = false


func _process(_delta: float) -> void:
	visible = shown and SchoolJanitor.cop_within(get_parent() as Node3D, reach)
