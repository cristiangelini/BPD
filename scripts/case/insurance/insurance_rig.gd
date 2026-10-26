class_name InsuranceRig
extends Node

## What only one of the insurance office's stories adds (seguros.md, "Las historias"), like FactoryRig for the doll
## factory. The office adds the story's rig as a child once its hidden items are placed and calls setup; the rig can
## then set the office's main evidence and run its own mechanic every frame.

var office: InsuranceOffice


func setup(place: InsuranceOffice) -> void:
	office = place
