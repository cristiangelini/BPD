class_name Merchandise
extends Grabbable

## A tool for sale on the hardware store's gondolas (docs/diseno/ferreteria.md, "Vende todo lo que agarras"). Tobías
## charges it to the cops' bill once he has seen it in a cop's hand for SEEN_TO_CHARGE seconds, and takes it off the
## bill when it lies again near its place on the gondola. Every number here is (propuesta).

## What it costs on the bill.
const PRICE := 15
## Seconds Tobías has to see it in a hand before he charges it.
const SEEN_TO_CHARGE := 3.0
## How close to where it lay on the gondola it has to be to count as given back, in meters.
const HOME_RADIUS := 0.5

## Where it lay on the gondola when the store opened.
var home := Vector3.ZERO
## It's on the bill.
var charged := false
## How long Tobías has seen it in a hand, this time.
var seen := 0.0


func is_in_hand() -> bool:
	return not holders.is_empty()


## Lying near its place on the gondola, and nobody holding it.
func is_home() -> bool:
	return not is_in_hand() and global_position.distance_to(home) <= HOME_RADIUS
