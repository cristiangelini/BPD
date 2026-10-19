class_name CaseStory
extends Resource

## One story a raid can tell (docs/diseno/historias.md): what the comisario says, the evidence that proves it and
## what goes into the drawers. The place (the house) brings the hiding spots; the story brings what hides in them.

## Short name, also used to pick the story from the debug panel later.
@export var id := ""
## What the comisario says before the raid, one tr() key per line.
@export var briefing: PackedStringArray = []
## Evidence that goes to the hiding spots. The first one is the main evidence: without it the case isn't solved.
@export var evidence: Array[PackedScene] = []
## Whether each evidence needs a hiding spot that fits heavy items, in the same order as evidence.
@export var heavy: Array[bool] = []
## Half the height of each evidence, so it rests on the spot instead of sinking into it.
@export var half_heights: Array[float] = []
## A small evidence that goes into drawers, one per drawer, and how many of them.
@export var drawer_evidence: PackedScene
@export var drawer_count := 0
