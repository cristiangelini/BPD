class_name TrainRide
extends RefCounted

## The train's clock (escena-tren.md, step 1): five legs of LEG seconds, each ending at a station where the train
## stands STOP seconds with its doors open, and a TUNNEL seconds long tunnel in the middle of each leg. The train
## speeds up and slows down for RAMP seconds at each end of a leg. The last station is the end of the line: arriving
## there is the end of the case (step 4). Everything goes by the ride's time, so the same time is the same place on
## every PC. Every number here is (propuesta).

const STATIONS := 5
const LEG := 120.0
const STOP := 20.0
const RAMP := 6.0
const TUNNEL := 8.0
## Meters per second at cruising speed.
const SPEED := 15.0
## The station names, as text keys (TRAIN_STATION_1 … TRAIN_STATION_5).
const NAMES: Array[String] = [
	"TRAIN_STATION_1", "TRAIN_STATION_2", "TRAIN_STATION_3", "TRAIN_STATION_4", "TRAIN_STATION_5",
]

## Seconds since the train left.
var time := 0.0


func advance(delta: float) -> void:
	time = minf(time + delta, end_time())


## When the train stands at the last station.
static func end_time() -> float:
	return STATIONS * LEG + (STATIONS - 1) * STOP


## The leg the train is on (0 to STATIONS - 1); while standing at a station, the leg that ended there.
func leg() -> int:
	return mini(int(time / (LEG + STOP)), STATIONS - 1)


## Seconds into the current leg (LEG or more while standing at its station).
func leg_time() -> float:
	return time - leg() * (LEG + STOP)


## The next station (0 to STATIONS - 1), or the one the train stands at.
func next_station() -> int:
	return leg()


func stopped() -> bool:
	return leg_time() >= LEG


func arrived() -> bool:
	return time >= end_time()


## Seconds until the next station (0 while standing at it).
func time_to_station() -> float:
	return maxf(LEG - leg_time(), 0.0)


func tunnel_start() -> float:
	return (LEG - TUNNEL) / 2


func in_tunnel() -> bool:
	var t := leg_time()
	return t >= tunnel_start() and t < tunnel_start() + TUNNEL


## Meters per second now.
func speed() -> float:
	var t := leg_time()
	if t >= LEG:
		return 0.0
	return SPEED * clampf(minf(t, LEG - t) / RAMP, 0.0, 1.0)


## Meters the train went in one whole leg.
static func leg_length() -> float:
	return SPEED * (LEG - RAMP)


## Meters from the start to `t` seconds into a leg.
static func _into_leg(t: float) -> float:
	t = clampf(t, 0.0, LEG)
	var ramp_in := minf(t, RAMP)
	var gone := SPEED * ramp_in * ramp_in / (2 * RAMP)
	gone += SPEED * clampf(t - RAMP, 0.0, LEG - 2 * RAMP)
	if t > LEG - RAMP:
		var left := LEG - t
		gone += SPEED * RAMP / 2 - SPEED * left * left / (2 * RAMP)
	return gone


## Meters the train went since it left: the scenery is this far behind.
func distance() -> float:
	return leg() * leg_length() + _into_leg(leg_time())


## Where (in meters from the start) the train stands at a station.
static func station_at(station: int) -> float:
	return (station + 1) * leg_length()


## Where the train's middle goes into a leg's tunnel.
static func tunnel_at(leg_index: int) -> float:
	return leg_index * leg_length() + _into_leg((LEG - TUNNEL) / 2)
