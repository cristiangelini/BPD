class_name LuckyShakesRig
extends GymRaidRig

## The lucky shakes (allanamiento-gimnasio.md, "Los batidos de la suerte"): el profe's "champion" shake makes whoever
## drinks it say what they think, and he uses it to get the members' lottery numbers out of them. A cup of it waits on
## the reception with a four-leaf clover on it; a cop who drinks it says their thoughts out loud for a while, and the
## first sip is the story's own clue. The jar of the shake, the list of members who won the lottery and the golden
## blender are hidden. Every number here is (propuesta).

## The cup on the reception's counter, between the till and the stereo.
const SHAKE_AT := Vector3(-2.85, GymHall.FLOOR_TOP + GymHall.RECEPTION_SIZE.y, 6.15)

var shake: GymShake


func setup(place: GymRaid) -> void:
	super.setup(place)
	shake = GymShake.new()
	shake.name = "Shake"
	shake.position = SHAKE_AT
	place.add_child(shake)
	shake.drunk.connect(func(_cop: Cop) -> void:
		if shake.sips == 1:
			place.raid.add_clue(tr("CLUE_SHAKE_CLOVER")))
