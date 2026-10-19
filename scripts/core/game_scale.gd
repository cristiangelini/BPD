class_name GameScale
extends RefCounted

## Base scale, camera and movement values from docs/diseno/escala.md.
## Don't change them without a decision from Cristian. 1 unit = 1 meter.

# Cop body
const COP_HEIGHT := 1.55
const COP_RADIUS := 0.5
const EYE_HEIGHT := 1.35
const CROUCH_HEIGHT := 1.1

# Movement (m/s)
const WALK_SPEED := 4.0
const RUN_SPEED := 6.5
const CROUCH_SPEED := 2.0
const JUMP_HEIGHT := 1.0
const GRAVITY := 9.8

# Running stamina (seconds)
const RUN_STAMINA := 6.0
const STAMINA_RECOVERY := 4.0
## Share of stamina needed to run again after running out
const STAMINA_RESUME := 0.5

# A fall higher than this knocks the cop out (meters)
const KNOCKOUT_FALL := 4.0

# Camera
const FOV := 80.0
const FOV_MIN := 70.0
const FOV_MAX := 100.0

# Grabbing and carrying
const GRAB_REACH := 2.5
const COP_CARRY_KG := 25.0
const HOLD_MIN := 1.0
const HOLD_MAX := 2.5
const THROW_SPEED_1KG := 8.0


static func jump_velocity() -> float:
	return sqrt(2.0 * GRAVITY * JUMP_HEIGHT)
