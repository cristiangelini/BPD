class_name HotelRig
extends Node

## What only one of the hotel raid's stories adds (hotel-allanamiento.md, "Las historias"), like GroomerRig for the pet
## salon. The raid adds the story's rig as a child once its people and hidden items are placed and calls setup; the rig
## can then set the raid's main evidence and run its own mechanic every frame.

var hotel_raid: HotelRaid


func setup(place: HotelRaid) -> void:
	hotel_raid = place
