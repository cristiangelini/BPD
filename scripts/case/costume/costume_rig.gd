class_name CostumeRig
extends Node

## What only one of the costume shop's stories adds (allanamiento-disfraces.md, "Las historias"), like InsuranceRig for
## the insurance office. The shop adds the story's rig as a child once its hidden items are placed and calls setup; the
## rig can then set the shop's main evidence and run its own mechanic every frame.

var shop: CostumeShop


func setup(place: CostumeShop) -> void:
	shop = place
