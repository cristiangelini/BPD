class_name SuspectCar
extends CharacterBody3D

## The chase suspect's vehicle (persecucion.md): it drives itself along its ChaseRoute, in its lane, slowing down to
## turn at the corners, and stops when something is in the way (the patrol car cutting it off). It counts how long it
## has been stuck, which is how the cops stop it. Forward is +Z, like the patrol car. Every number here is (propuesta).

## 40 km/h on the straight, slower than the patrol car's 60, and this share of it through a sharp turn.
const SPEED := 40.0 / 3.6
const TURN_SPEED := 0.45
## How fast it turns (radians a second) and how close to a corner counts as through it.
const TURN_RATE := 1.6
const REACH := 3.0
## Moving slower than this (or than STUCK_SHARE of his own speed) while it wants to drive counts as stuck.
const STUCK_SPEED := 1.0
const STUCK_SHARE := 0.2
## Nervous (the megaphone), he drives at this share of his speed.
const NERVOUS_SPEED := 0.6
## Packed with people (control-auto-lleno.md), he drives at this share of his speed.
const HEAVY_SPEED := 0.8
## With his tires punctured (the spikes) he rolls to a halt in this many seconds.
const FLAT_STOP := 2.0
## The street race's El Turbo (control-carrera.md, "Cómo es" 8): this much faster than anyone in his racer, but at
## every corner he spins round once to show off, standing there SPIN_SECONDS.
const RACER_SPEED := 1.3
const SPIN_SECONDS := 2.0
const WHEELS: Array[Vector3] = [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
	Vector3(1.1, 0.38, -1.7)]
## Each suspect's vehicle (ChaseCase.SUSPECTS); the trucks share one size and wheels.
const MODELS := {
	"ice_cream": preload("res://assets/models/ice_cream_truck.glb"),
	"moving_truck": preload("res://assets/models/moving_truck.glb"),
	"school_bus": preload("res://assets/models/school_bus.glb"),
	"rain": preload("res://assets/models/getaway_car.glb"),
	"night": preload("res://assets/models/getaway_car.glb"),
	"moto": preload("res://assets/models/delivery_scooter.glb"),
	"wheelchair": preload("res://assets/models/wheelchair.glb"),
	"highway": preload("res://assets/models/sports_car.glb"),
	"tow_truck": preload("res://assets/models/tow_truck.glb"),
	"golf_cart": preload("res://assets/models/golf_cart.glb"),
	# The dangerous suspect takes the old patrol car from behind the station (persecucion-final.md).
	"old_patrol": preload("res://assets/models/old_patrol_car.glb"),
	# The pastry contest's culprit runs off on his delivery bike (escena-del-crimen.md).
	"bike": preload("res://assets/models/delivery_bike.glb"),
	# Doña Chela found out runs off on her motorized walker (infiltracion.md).
	"walker": preload("res://assets/models/motor_walker.glb"),
	# Maestro Ernesto found out runs off in the choir's van, with the choir inside singing (infiltracion-coro.md).
	"choir_van": preload("res://assets/models/choir_van.glb"),
	# El Oso gets away from the bank in the robbers' van, or on foot with a sack of money if it's boxed in
	# (robo-banco.md): on foot the "vehicle" is the sack he carries, and he's its rider.
	"robbers_van": preload("res://assets/models/robbers_van.glb"),
	"bear_on_foot": preload("res://assets/models/money_bag.glb"),
	# The bank's manager who was the boss drives off in his own car with the sacks in its trunk (robo-banco-gerente.md).
	"manager_car": preload("res://assets/models/manager_car.glb"),
	# The last heckler of the rally runs off on a kick scooter (proteccion-politico.md); set_rider puts them on it.
	"kick_scooter": preload("res://assets/models/kick_scooter.glb"),
	# The prison's last ringleader rolls off downhill on the kitchen's food cart (carcel-motin.md), behind it.
	"food_cart": preload("res://assets/models/food_cart.glb"),
	"inmate_on_foot": preload("res://assets/models/ball_and_chain.glb"),
	# The market's spiteful vendor pedals off on his vegetable tricycle (politico-mercado.md), losing veggies in curves.
	"veggie_trike": preload("res://assets/models/veggie_trike.glb"),
	# The school's janitor rides off on his floor polisher (politico-escuela.md), waxing the sidewalk behind him.
	"floor_polisher": preload("res://assets/models/floor_polisher.glb"),
	# The circus's culprit runs off in the clown car, dropping inflatable clowns (escena-circo.md).
	"clown_car": preload("res://assets/models/clown_car.glb"),
	# Maestra Pausa found out runs off "driving" an invisible car (infiltracion-mimos.md): only its faint outline shows.
	"invisible_car": preload("res://assets/models/invisible_car.glb"),
	# The Sargento Trucho found out runs off in the party patrol car (infiltracion-fiesta.md): a sky blue sedan with a
	# plastic siren on the roof that wails off key.
	"party_patrol": preload("res://assets/models/party_patrol.glb"),
	# El Toro jogging off (infiltracion-gimnasio.md): only the dust he kicks up, and him.
	"toro_jog": preload("res://assets/models/toro_jog.glb"),
	# The Director of the thieves' school drives off in its learner car (infiltracion-escuela.md), stalling it.
	"learner_car": preload("res://assets/models/learner_car.glb"),
	# The Chef Flambé rides off on the restaurant's delivery scooter (infiltracion-restaurante.md), losing pizzas.
	"pizza_scooter": preload("res://assets/models/pizza_scooter.glb"),
	# The Gran Maestro Alfil rides off on a motorized carousel horse (infiltracion-ajedrez.md), hopping at corners.
	"carousel_horse": preload("res://assets/models/carousel_horse.glb"),
	# El Cromado rides off on his "bike" (infiltracion-motos.md): a moped with chopper handlebars, going "BRRRUM".
	"chopper_moped": preload("res://assets/models/chopper_moped.glb"),
	# Don Martillo drives off in the gallery's electric cart (infiltracion-subasta.md), a giant painting tied behind.
	"gallery_cart": preload("res://assets/models/gallery_cart.glb"),
	# The traffic control's wanted car, in its paint (control-transito.md): the traffic car it was in the queue.
	"traffic_0": preload("res://assets/models/traffic_car_0.glb"),
	"traffic_1": preload("res://assets/models/traffic_car_1.glb"),
	"traffic_2": preload("res://assets/models/traffic_car_2.glb"),
	"traffic_3": preload("res://assets/models/traffic_car_3.glb"),
	# The fruit truck control's wanted pickup (control-frutas.md), dropping watermelons at the corners.
	"fruit_truck": preload("res://assets/models/fruit_truck.glb"),
	# The circus move's El Peludo (control-circo.md) runs off in his circus truck, dropping banana peels at the corners.
	"circus_truck": preload("res://assets/models/circus_truck.glb"),
	# The parade's El Antifaz (control-desfile.md) runs off on his float, shooting confetti at the corners.
	"parade_float": preload("res://assets/models/parade_float.glb"),
	# The roof robbery's El Oso gets away hanging from the giant toy helicopter's rope, low over the street
	# (robo-banco-techo.md): it flies AIR_AT up, over everything, and he hangs under it.
	"toy_helicopter": preload("res://assets/models/toy_helicopter.glb"),
	# Engineer Remache gets away from the bridge in Pegote Hermanos' cement mixer (politico-puente.md), dropping
	# cement blobs in the curves.
	"cement_mixer": preload("res://assets/models/cement_mixer.glb"),
	# The bought referee gets away from the charity match on concejal Barullo's scooter (politico-futbol.md).
	"barullo_moto": preload("res://assets/models/barullo_scooter.glb"),
	# The museum's culprit runs off in the art transport van, dropping empty frames (escena-museo.md).
	"art_van": preload("res://assets/models/art_van.glb"),
	"tv_van": preload("res://assets/models/tv_van.glb"),
	# The hotel's culprit runs off in its shuttle, dropping suitcases off the roof (escena-hotel.md).
	"hotel_shuttle": preload("res://assets/models/hotel_shuttle.glb"),
	# The airport's bought porter gets away on the baggage tug (politico-aeropuerto.md), slow, its beacon spinning.
	"baggage_tug": preload("res://assets/models/baggage_tug.glb"),
	# The cat's culprit gets away in his aunt's golden limousine, throwing balls of yarn out the window (escena-gato.md).
	"golden_limo": preload("res://assets/models/golden_limo.glb"),
}
## Who rides on top of it, where you can see them, each as [model, position, scale] (they get off when he gives up).
const RIDERS := {
	"moto": [[preload("res://assets/models/npc_repartidor.glb"), Vector3(0, 0.36, -0.15), 0.85]],
	"barullo_moto": [[preload("res://assets/models/npc_arbitro.glb"), Vector3(0, 0.36, -0.15), 0.85]],
	"wheelchair": [[preload("res://assets/models/npc_abuelo.glb"), Vector3(0, 0.12, 0.02), 0.72]],
	"golf_cart": [[preload("res://assets/models/npc_sospechoso.glb"), Vector3(-0.3, 0.3, -0.2), 0.7],
		[preload("res://assets/models/npc_preso.glb"), Vector3(0.3, 0.3, -0.2), 0.7]],
	"bike": [[preload("res://assets/models/npc_pastelero.glb"), Vector3(0, 0.3, -0.35), 0.85]],
	"walker": [[preload("res://assets/models/npc_chela.glb"), Vector3(0, 0.13, -0.32), 0.85]],
	"choir_van": [[preload("res://assets/models/npc_ernesto.glb"), Vector3(-0.45, 0.4, 1.3), 0.85]],
	"robbers_van": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(-0.5, 0.4, 1.4), 0.85]],
	"bear_on_foot": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(0, 0, -0.35), 1.15]],
	"kick_scooter": [[preload("res://assets/models/npc_vecina.glb"), Vector3(0, 0.15, -0.1), 0.85]],
	"food_cart": [[preload("res://assets/models/npc_preso.glb"), Vector3(0, 0.05, -0.95), 0.9]],
	"inmate_on_foot": [[preload("res://assets/models/npc_preso.glb"), Vector3(0, 0, 0), 0.85]],
	"veggie_trike": [[preload("res://assets/models/npc_puestero.glb"), Vector3(0, 0.25, -0.45), 0.85]],
	"floor_polisher": [[preload("res://assets/models/npc_conserje_escuela.glb"), Vector3(0, 0.0, -0.8), 1.0]],
	"clown_car": [[preload("res://assets/models/npc_payaso.glb"), Vector3(0, 0.45, -0.25), 0.8]],
	"toy_helicopter": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(0, 2.4, 0), 0.85]],
	"invisible_car": [[preload("res://assets/models/npc_pausa.glb"), Vector3(0, 0, 0.1), 0.95]],
	"party_patrol": [[preload("res://assets/models/npc_invitado.glb"), Vector3(-0.45, 0.05, 0.1), 0.8]],
	"toro_jog": [[preload("res://assets/models/npc_toro.glb"), Vector3(0, 0, 0), 1.2]],
	"learner_car": [[preload("res://assets/models/npc_director.glb"), Vector3(-0.45, 0.05, 0.1), 0.8]],
	"pizza_scooter": [[preload("res://assets/models/npc_flambe.glb"), Vector3(0, 0.36, -0.1), 0.85]],
	"carousel_horse": [[preload("res://assets/models/npc_alfil.glb"), Vector3(0, 0.82, -0.22), 0.8]],
	"chopper_moped": [[preload("res://assets/models/npc_cromado.glb"), Vector3(0, 0.32, -0.2), 1.3]],
	"gallery_cart": [[preload("res://assets/models/npc_martillo.glb"), Vector3(0, 0.45, 0.45), 0.85]],
	"cement_mixer": [[preload("res://assets/models/npc_ingeniero.glb"), Vector3(-0.5, 0.75, 2.3), 0.85]],
	"art_van": [[preload("res://assets/models/npc_guardia_museo.glb"), Vector3(-0.5, 0.4, 1.5), 0.85]],
	"tv_van": [[preload("res://assets/models/npc_tecnico.glb"), Vector3(-0.5, 0.4, 1.5), 0.85]],
	"hotel_shuttle": [[preload("res://assets/models/npc_huesped.glb"), Vector3(-0.5, 0.4, 1.7), 0.85]],
	"baggage_tug": [[preload("res://assets/models/npc_mudancero.glb"), Vector3(0, 0.35, 0.2), 0.85]],
	"golden_limo": [[preload("res://assets/models/npc_sobrino_tia.glb"), Vector3(-0.5, 0.4, 1.2), 0.85]],
}
## Who rides inside and stays there when he gives up, the same way: the choristers in the van, seen through its open
## windows, singing all the way.
const PASSENGERS := {
	"choir_van": [[preload("res://assets/models/npc_corista.glb"), Vector3(-0.5, 0.4, -0.1), 0.85],
		[preload("res://assets/models/npc_corista_b.glb"), Vector3(0.5, 0.4, -0.1), 0.85],
		[preload("res://assets/models/npc_corista_b.glb"), Vector3(-0.5, 0.4, -1.4), 0.85],
		[preload("res://assets/models/npc_corista.glb"), Vector3(0.5, 0.4, -1.4), 0.85]],
}
## The scooter and the wheelchair ride the sidewalk, not the street.
const LANES := {"moto": ChaseRoute.SIDEWALK_LANE, "wheelchair": ChaseRoute.SIDEWALK_LANE,
	"walker": ChaseRoute.SIDEWALK_LANE, "bear_on_foot": ChaseRoute.SIDEWALK_LANE, "kick_scooter": ChaseRoute.SIDEWALK_LANE,
	"food_cart": ChaseRoute.SIDEWALK_LANE, "veggie_trike": ChaseRoute.SIDEWALK_LANE, "floor_polisher": ChaseRoute.SIDEWALK_LANE, "inmate_on_foot": ChaseRoute.SIDEWALK_LANE,
	"toro_jog": ChaseRoute.SIDEWALK_LANE}
## The electric wheelchair goes at 8 km/h (persecucion.md).
## The delivery bike pedals at 25 km/h and turns tight. Doña Chela's walker's motor does 10 km/h. The choir's old van,
## full, does 35. El Oso running with his sack does 12, the heckler's kick scooter 15 and the food cart, downhill, 14
## (propuesta). The loaded vegetable trike, 16, and an inmate off the transfer bus, dragging the ball and chain, 11.
## The clown car does 30, honking all the way, and a parade float 28, wide and slow. The loaded cement mixer does 28 and nearly stops in the curves.
const SPEEDS := {"bear_on_foot": 12.0 / 3.6, "wheelchair": 8.0 / 3.6, "tow_truck": 30.0 / 3.6, "golf_cart": 25.0 / 3.6, "bike": 25.0 / 3.6,
	"walker": 10.0 / 3.6, "choir_van": 35.0 / 3.6, "kick_scooter": 15.0 / 3.6,
	"food_cart": 14.0 / 3.6, "veggie_trike": 16.0 / 3.6, "floor_polisher": 14.0 / 3.6, "inmate_on_foot": 11.0 / 3.6, "clown_car": 30.0 / 3.6,
	"parade_float": 28.0 / 3.6,
	"toy_helicopter": 20.0 / 3.6, "invisible_car": 14.0 / 3.6,
	"toro_jog": 13.0 / 3.6, "learner_car": 35.0 / 3.6, "pizza_scooter": 40.0 / 3.6,
	"carousel_horse": 25.0 / 3.6, "chopper_moped": 30.0 / 3.6, "gallery_cart": 20.0 / 3.6,
	"cement_mixer": 28.0 / 3.6, "barullo_moto": 45.0 / 3.6, "baggage_tug": 22.0 / 3.6}
## The tow truck turns slowly and nearly stops to do it (persecucion-lugares.md): a cop cutting a corner on foot
## catches up with him.
## The golf cart turns very tight and hardly slows down to do it.
## The golden limousine is long and slow to turn: it swings wide at every corner (propuesta).
const TURN_RATES := {"golden_limo": 0.9, "tow_truck": 1.0, "golf_cart": 3.2, "bike": 3.2, "clown_car": 3.0, "cement_mixer": 1.1,
	"barullo_moto": 3.0, "baggage_tug": 2.6}
const TURN_SPEEDS := {"golden_limo": 0.35, "tow_truck": 0.3, "golf_cart": 0.75, "bike": 0.75, "clown_car": 0.75, "cement_mixer": 0.35,
	"barullo_moto": 0.7, "baggage_tug": 0.6}
const GOLF := "golf_cart"
const TOW := "tow_truck"
const OLD_PATROL := "old_patrol"
const BIKE := "bike"
const WALKER := "walker"
const CHOIR_VAN := "choir_van"
const ROBBERS_VAN := "robbers_van"
const BEAR_ON_FOOT := "bear_on_foot"
const MANAGER_CAR := "manager_car"
const KICK_SCOOTER := "kick_scooter"
const FOOD_CART := "food_cart"
const INMATE_ON_FOOT := "inmate_on_foot"
const VEGGIE_TRIKE := "veggie_trike"
const FLOOR_POLISHER := "floor_polisher"
const CLOWN_CAR := "clown_car"
const FRUIT_TRUCK := "fruit_truck"
const CIRCUS_TRUCK := "circus_truck"
const PARADE_FLOAT := "parade_float"
const TOY_HELICOPTER := "toy_helicopter"
## The toy helicopter flies this high (its skids), with the rope down to El Oso's hands; he hangs with his feet over a
## patrol car's roof, so it can pass right under him. Nothing gets in its way, and it doesn't fall.
const AIR_AT := 5.2
const ROPE_FROM := 3.9
const INVISIBLE_CAR := "invisible_car"
const PARTY_PATROL := "party_patrol"
const TORO_JOG := "toro_jog"
const LEARNER_CAR := "learner_car"
const PIZZA_SCOOTER := "pizza_scooter"
const CAROUSEL_HORSE := "carousel_horse"
## The carousel horse jumps up this fast (m/s) at every corner it turns, like a knight's L (propuesta).
const HORSE_HOP := 4.5
const CHOPPER_MOPED := "chopper_moped"
const GALLERY_CART := "gallery_cart"
const CART_PAINTING := preload("res://assets/models/cart_painting.glb")
## The giant painting tied behind the cart: where it stands on the deck, and how it sways at every corner it turns: it
## leans out of the curve this fast (rad/s), springs back and settles, never more than SWAY_MAX (propuesta).
const CART_PAINTING_AT := Vector3(0, 0.42, -0.6)
const SWAY_KICK := 2.2
const SWAY_SPRING := 14.0
const SWAY_DAMP := 2.5
const SWAY_MAX := 0.45
## The learner car stalls after this many seconds of driving and stays stopped this long (propuesta).
const STALL_EVERY := 6.0
const STALL_TIME := 2.0
## The toy siren's two notes, a little off key from each other, and how long each lasts (propuesta).
const TOY_SIREN_NOTES: Array[float] = [610.0, 790.0]
const TOY_SIREN_NOTE := 0.45
const CEMENT_MIXER := "cement_mixer"
const BARULLO_MOTO := "barullo_moto"
const ART_VAN := "art_van"
## The channel's TV van, the bought technician's getaway (politico-debate.md).
const TV_VAN := "tv_van"
const HOTEL_SHUTTLE := "hotel_shuttle"
const BAGGAGE_TUG := "baggage_tug"
const LIMO := "golden_limo"
## Where the towed patrol car hangs behind the tow truck: its middle, and its nose lifted this much.
const TOWED_AT := Vector3(0, 0.55, -5.6)
const TOWED_TILT := -0.12
## The sports car (persecucion-lugares.md): 90 km/h on the highway, 50 on the way there through the city.
const HIGHWAY := "highway"
const HIGHWAY_SPEED := 90.0 / 3.6
const HIGHWAY_CITY_SPEED := 50.0 / 3.6
## The cops' collision layer: on foot they're in the wheelchair's way (the cars ignore them).
const COPS_LAYER := 2
## Each vehicle's body (width, height, length) and wheels, when not the trucks'.
## The parade float's skirt hides its wheels.
const SIZES := {"school_bus": Vector3(2.5, 2.9, 8.4), "rain": Vector3(2.1, 1.4, 4.6), "night": Vector3(2.1, 1.4, 4.6),
	"highway": Vector3(2.1, 1.1, 4.6), "tow_truck": Vector3(2.3, 2.4, 6.2), "golf_cart": Vector3(1.3, 1.8, 2.4),
	"moto": Vector3(0.8, 1.6, 1.9), "old_patrol": Vector3(2.1, 1.5, 4.6),
	"wheelchair": Vector3(0.8, 1.4, 1.2), "bear_on_foot": Vector3(0.9, 1.8, 0.9), "choir_van": Vector3(2.0, 1.95, 4.6), "walker": Vector3(0.7, 1.6, 1.3), "kick_scooter": Vector3(0.6, 1.6, 1.0), "food_cart": Vector3(0.8, 1.6, 2.2), "veggie_trike": Vector3(1.0, 1.6, 2.0), "floor_polisher": Vector3(0.8, 1.6, 1.8), "inmate_on_foot": Vector3(0.8, 1.6, 0.9), "invisible_car": Vector3(0.9, 1.6, 0.9), "bike": Vector3(0.7, 1.6, 1.9), "clown_car": Vector3(1.3, 1.4, 2.0), "traffic_0": Vector3(2.1, 1.4, 4.6),
	"traffic_1": Vector3(2.1, 1.4, 4.6), "traffic_2": Vector3(2.1, 1.4, 4.6), "traffic_3": Vector3(2.1, 1.4, 4.6),
	"manager_car": Vector3(2.1, 1.4, 4.6), "fruit_truck": Vector3(2.1, 1.75, 4.6),
	"circus_truck": Vector3(2.1, 2.6, 4.6), "parade_float": Vector3(2.3, 1.0, 4.6),
	"toy_helicopter": Vector3(0.6, 0.6, 0.6), "party_patrol": Vector3(2.1, 1.4, 4.6),
	"toro_jog": Vector3(0.9, 1.8, 0.9), "learner_car": Vector3(2.1, 1.4, 4.6),
	"pizza_scooter": Vector3(1.2, 1.6, 2.3), "carousel_horse": Vector3(1.6, 2.0, 1.8),
	"chopper_moped": Vector3(0.8, 1.9, 1.7), "gallery_cart": Vector3(1.3, 1.9, 2.4),
	"cement_mixer": Vector3(2.3, 3.0, 7.0), "barullo_moto": Vector3(0.8, 1.6, 1.9), "art_van": Vector3(2.1, 2.3, 4.8),
	"tv_van": Vector3(2.1, 2.3, 4.8),
	"hotel_shuttle": Vector3(2.1, 2.6, 5.0),
	"baggage_tug": Vector3(1.3, 1.4, 2.4), "golden_limo": Vector3(2.1, 1.5, 7.0)}
const BUS_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.7), Vector3(1.15, 0.38, 2.7), Vector3(-1.15, 0.38, -2.6),
	Vector3(1.15, 0.38, -2.6)]
const SEDAN_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.55), Vector3(1.05, 0.38, 1.55),
	Vector3(-1.05, 0.38, -1.55), Vector3(1.05, 0.38, -1.55)]
const TOW_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.0), Vector3(1.15, 0.38, 2.0), Vector3(-1.15, 0.38, -1.8),
	Vector3(1.15, 0.38, -1.8)]
const MIXER_WHEELS: Array[Vector3] = [Vector3(-1.2, 0.38, 2.4), Vector3(1.2, 0.38, 2.4), Vector3(-1.2, 0.38, -1.5),
	Vector3(1.2, 0.38, -1.5), Vector3(-1.2, 0.38, -2.5), Vector3(1.2, 0.38, -2.5)]
const SHUTTLE_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.75), Vector3(1.05, 0.38, 1.75),
	Vector3(-1.05, 0.38, -1.75), Vector3(1.05, 0.38, -1.75)]
const LIMO_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 2.3), Vector3(1.05, 0.38, 2.3),
	Vector3(-1.05, 0.38, -2.3), Vector3(1.05, 0.38, -2.3)]
## The scooter's wheels are part of its model.
const NO_WHEELS: Array[Vector3] = []
const OTHER_WHEELS := {"school_bus": BUS_WHEELS, "rain": SEDAN_WHEELS, "night": SEDAN_WHEELS, "moto": NO_WHEELS,
	"wheelchair": NO_WHEELS, "walker": NO_WHEELS, "bear_on_foot": NO_WHEELS, "kick_scooter": NO_WHEELS, "food_cart": NO_WHEELS, "veggie_trike": NO_WHEELS, "floor_polisher": NO_WHEELS, "inmate_on_foot": NO_WHEELS, "invisible_car": NO_WHEELS, "highway": SEDAN_WHEELS, "tow_truck": TOW_WHEELS, "golf_cart": NO_WHEELS,
	"old_patrol": SEDAN_WHEELS, "bike": NO_WHEELS, "clown_car": NO_WHEELS, "traffic_0": SEDAN_WHEELS, "traffic_1": SEDAN_WHEELS,
	"traffic_2": SEDAN_WHEELS, "traffic_3": SEDAN_WHEELS, "choir_van": SEDAN_WHEELS, "manager_car": SEDAN_WHEELS, "fruit_truck": SEDAN_WHEELS,
	"circus_truck": SEDAN_WHEELS, "parade_float": NO_WHEELS,
	"toy_helicopter": NO_WHEELS,
	"party_patrol": SEDAN_WHEELS, "toro_jog": NO_WHEELS, "learner_car": SEDAN_WHEELS,
	"pizza_scooter": NO_WHEELS, "carousel_horse": NO_WHEELS, "chopper_moped": NO_WHEELS,
	"gallery_cart": NO_WHEELS,
	"cement_mixer": MIXER_WHEELS, "barullo_moto": NO_WHEELS,
	"art_van": SEDAN_WHEELS, "tv_van": SEDAN_WHEELS, "hotel_shuttle": SHUTTLE_WHEELS, "baggage_tug": NO_WHEELS,
	"golden_limo": LIMO_WHEELS}

## He drove through a corner: `turned` if he changed direction there (where the moving truck loses furniture).
signal corner_passed(turned: bool)

## The crowded car control's runaway, packed with the gang: slower (HEAVY_SPEED).
var heavy := false
## El Turbo's racer (set before the chase starts): faster, and it spins at the corners (spin()).
var racer := false
## Seconds left of a spin, and where its nose pointed before it.
var spin_left := 0.0
var _spin_from := 0.0
## Whose vehicle it is (set before it's added).
var kind := "ice_cream"
const WHEEL := preload("res://assets/models/car_wheel.glb")

## Where it drives through, in the world (set before it's added, or with follow()).
var points: Array[Vector3] = []
## The next point it heads for; past the last one it stops.
var next := 0
## Seconds it has been stuck in a row, and whether it's driving at all.
var stuck_for := 0.0
var driving := true
## Seconds he's still nervous for.
var nervous_left := 0.0
## His tires got punctured; how much of his speed he still has; seconds the net still holds him.
var punctured := false
var _rolling := 1.0
var tangled_left := 0.0
## The learner car: seconds it stays stalled, and seconds of driving until it stalls again.
var stalled_left := 0.0
var stall_in := STALL_EVERY
## How many times the carousel horse has hopped.
var hops := 0
## The cart's painting: how far it leans (rad, + to the cart's right), how fast, and how many times it swayed.
var sway := 0.0
var _sway_speed := 0.0
var sways := 0
var _highway: Highway
var _rotor: Node3D


func _ready() -> void:
	add_to_group("suspect_car")
	if kind == "wheelchair" or kind == WALKER or kind == TOW or kind == BEAR_ON_FOOT or kind == KICK_SCOOTER \
			or kind == FOOD_CART or kind == VEGGIE_TRIKE or kind == FLOOR_POLISHER or kind == INMATE_ON_FOOT or kind == INVISIBLE_CAR or kind == TORO_JOG:
		set_collision_mask_value(COPS_LAYER, true)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = SIZES.get(kind, Vector3(2.2, 2.3, 5.2))
	shape.shape = body
	shape.position.y = body.size.y / 2 + 0.2
	add_child(shape)
	var model: Node3D = (MODELS[kind] as PackedScene).instantiate()
	add_child(model)
	if kind == TOY_HELICOPTER:
		_fly(model)
	var riders: Array = RIDERS.get(kind, [])
	for k in riders.size():
		var rider: Node3D = (riders[k][0] as PackedScene).instantiate()
		rider.name = "Rider" if k == 0 else "Rider%d" % (k + 1)
		rider.position = riders[k][1]
		rider.scale = Vector3.ONE * float(riders[k][2])
		add_child(rider)
	var passengers: Array = PASSENGERS.get(kind, [])
	for k in passengers.size():
		var passenger: Node3D = (passengers[k][0] as PackedScene).instantiate()
		passenger.name = "Passenger%d" % (k + 1)
		passenger.position = passengers[k][1]
		passenger.scale = Vector3.ONE * float(passengers[k][2])
		add_child(passenger)
	if kind == CHOIR_VAN:
		var song := AudioStreamPlayer3D.new()
		song.name = "Song"
		song.stream = ChoirSinging.choir_stream()
		song.max_distance = 40.0
		song.autoplay = true
		add_child(song)
	if kind == PARTY_PATROL:
		var siren := AudioStreamPlayer3D.new()
		siren.name = "Siren"
		siren.stream = toy_siren_stream()
		siren.max_distance = 50.0
		siren.autoplay = true
		add_child(siren)
	if kind == LEARNER_CAR:
		_add_learner_labels()
	if kind == CHOPPER_MOPED:
		_add_brrrum()
	if kind == GALLERY_CART:
		var painting: Node3D = CART_PAINTING.instantiate()
		painting.name = "Painting"
		painting.position = CART_PAINTING_AT
		add_child(painting)
	if kind == TOW:
		var hook := TowHook.new()
		hook.name = "Hook"
		hook.position = Vector3(0, 1.2, -3.3)
		add_child(hook)
		add_collision_exception_with(hook)
	var wheels: Array[Vector3] = OTHER_WHEELS.get(kind, WHEELS)
	for at in wheels:
		var wheel: Node3D = WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)


## The toy helicopter: up in the air with its rope hanging, out of everyone's way.
func _fly(model: Node3D) -> void:
	model.position.y = AIR_AT
	_rotor = model.find_child("rotor", true, false) as Node3D
	collision_layer = 0
	collision_mask = 0
	var rope := MeshInstance3D.new()
	rope.name = "Rope"
	var line := CylinderMesh.new()
	line.top_radius = 0.025
	line.bottom_radius = 0.025
	line.height = AIR_AT - ROPE_FROM
	rope.mesh = line
	rope.position.y = (AIR_AT + ROPE_FROM) / 2
	add_child(rope)


func _process(delta: float) -> void:
	if _rotor:
		_rotor.rotate_y(ToyHelicopter.FLY_SPIN * delta)


## El Cromado's moped: its little engine and the "BRRRUM!" he makes with his mouth over it all the way (stopped with
## the song when he gets off).
func _add_brrrum() -> void:
	var song := AudioStreamPlayer3D.new()
	song.name = "Song"
	song.stream = DareCharge.engine_stream()
	song.pitch_scale = 1.6
	song.max_distance = 40.0
	song.autoplay = true
	add_child(song)
	var brrrum := Label3D.new()
	brrrum.name = "Brrrum"
	brrrum.text = "MOPED_BRRRUM"
	brrrum.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	brrrum.font_size = 48
	brrrum.pixel_size = 0.008
	brrrum.outline_size = 12
	brrrum.modulate = Color(1.0, 0.75, 0.2)
	brrrum.position = Vector3(0, 3.0, 0)
	add_child(brrrum)


## The learner car's roof sign, on both faces, and the "it stalled" mark over it.
func _add_learner_labels() -> void:
	for side: float in [1.0, -1.0]:
		var sign_label := Label3D.new()
		sign_label.text = "LEARNER_SIGN"
		sign_label.font_size = 40
		sign_label.pixel_size = 0.0028
		sign_label.double_sided = false
		sign_label.modulate = Color(0.1, 0.1, 0.15)
		sign_label.outline_size = 0
		sign_label.position = Vector3(0, 1.78, -0.15 + side * 0.045)
		sign_label.rotation.y = 0.0 if side > 0.0 else PI
		add_child(sign_label)
	var stalled := Label3D.new()
	stalled.name = "Stalled"
	stalled.text = "LEARNER_STALLED"
	stalled.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stalled.font_size = 48
	stalled.pixel_size = 0.008
	stalled.outline_size = 12
	stalled.position = Vector3(0, 2.6, 0)
	stalled.hide()
	add_child(stalled)


## Whether it's the learner car, stalled right now.
func is_stalled() -> bool:
	return stalled_left > 0.0


## Puts it at the start of `route` (in the city's space, which `city` places in the world), facing the way it goes.
func follow(route: ChaseRoute, city: Transform3D) -> void:
	retake(route, city)
	next = 1
	global_position = points[0]
	var ahead := points[1] - points[0]
	rotation.y = atan2(ahead.x, ahead.z)


## Drives off from where he's parked (`at`, in the world) and on along `route`: a chase in the middle of another case
## (persecucion-final.md).
func drive_from(at: Transform3D, route: ChaseRoute, city: Transform3D) -> void:
	retake(route, city)
	points.insert(0, at.origin)
	next = 1
	global_transform = at


## Puts it at the start of `path` (points in the city's space, like HighwayRoute's), facing the way it goes.
func follow_path(path: Array[Vector3], city: Transform3D) -> void:
	points.clear()
	for point in path:
		points.append(city * point)
	next = 1
	global_position = points[0]
	var ahead := points[1] - points[0]
	rotation.y = atan2(ahead.x, ahead.z)


## Where the patrol car he tows hangs, in the world.
func towed_transform() -> Transform3D:
	return global_transform * Transform3D(Basis(Vector3.RIGHT, TOWED_TILT), TOWED_AT)


## His speed on the straight here: the sports car's depends on whether he's on the highway; a packed car's is less.
func top_speed() -> float:
	if kind != HIGHWAY:
		return SPEEDS.get(kind, SPEED) * (HEAVY_SPEED if heavy else 1.0) * (RACER_SPEED if racer else 1.0)
	if not is_instance_valid(_highway):
		_highway = get_tree().get_first_node_in_group("highway") as Highway
	return HIGHWAY_SPEED if _highway and _highway.covers(global_position) else HIGHWAY_CITY_SPEED


## Drives `route` from here on (he changed his mind at a corner), heading for the same next point.
func retake(route: ChaseRoute, city: Transform3D) -> void:
	points.clear()
	for point in route.waypoints(LANES.get(kind, ChaseRoute.LANE)):
		points.append(city * point)


## The spikes: his tires go flat and he rolls to a halt, for good.
func puncture() -> void:
	punctured = true


## He gives up and gets off: whoever rode on top isn't there anymore, and the choir in the van stops singing.
## Puts `model` on it in place of its first rider, where they ride (the rally's heckler, with their own look).
func set_rider(model: PackedScene) -> void:
	var old := get_node_or_null("Rider") as Node3D
	if not old:
		return
	var rider: Node3D = model.instantiate()
	rider.transform = old.transform
	rider.visible = old.visible
	old.free()
	rider.name = "Rider"
	add_child(rider)


func get_off() -> void:
	for rider in [get_node_or_null("Rider"), get_node_or_null("Rider2"), get_node_or_null("Rope")]:
		if rider:
			(rider as Node3D).hide()
	var song := get_node_or_null("Song") as AudioStreamPlayer3D
	if song:
		song.stop()
	var brrrum := get_node_or_null("Brrrum") as Node3D
	if brrrum:
		brrrum.hide()


## Online (NpcSync): what a guest's copy needs before it's added (one that drives off in the middle of a case).
func net_setup() -> Dictionary:
	return {"kind": kind}


## Online (NpcSync): whether he got off, so a guest's copy hides its riders too.
## The cart also sends how far its painting leans.
func net_state() -> Variant:
	var rider := get_node_or_null("Rider") as Node3D
	var off := rider != null and not rider.visible
	if kind == GALLERY_CART:
		return [off, sway]
	return off


func apply_net_state(state: Variant) -> void:
	if state is Array:
		_lean(state[1])
		state = state[0]
	if state:
		get_off()


## The net: he can't drive for `seconds`.
func tangle(seconds: float) -> void:
	tangled_left = maxf(tangled_left, seconds)


## A spin on the spot for `seconds`: one whole turn, going nowhere, then on his way pointing where he did.
func spin(seconds := SPIN_SECONDS) -> void:
	if spin_left <= 0.0:
		_spin_from = rotation.y
	spin_left = maxf(spin_left, seconds)


## Nervous for `seconds`: he slows down.
func scare(seconds: float) -> void:
	nervous_left = maxf(nervous_left, seconds)


## Whether the route changes direction at point `k`.
func _turns_at(k: int) -> bool:
	if k < 1 or k + 1 >= points.size():
		return false
	var into := points[k] - points[k - 1]
	var out := points[k + 1] - points[k]
	return absf(Vector2(into.x, into.z).angle_to(Vector2(out.x, out.z))) > PI / 4


func finished() -> bool:
	return next >= points.size()


func _physics_process(delta: float) -> void:
	# In the air it neither falls nor touches anything.
	# On the floor it stays there, unless it's just hopped (the carousel horse).
	velocity.y = 0.0 if is_on_floor() or kind == TOY_HELICOPTER and velocity.y <= 0.0 else velocity.y - GameScale.GRAVITY * delta
	nervous_left = maxf(nervous_left - delta, 0.0)
	tangled_left = maxf(tangled_left - delta, 0.0)
	if kind == GALLERY_CART:
		_sway(delta)
	if punctured:
		_rolling = maxf(_rolling - delta / FLAT_STOP, 0.0)
	# Spinning, he turns round on the spot; on its last frame he's back where he pointed, still standing.
	var spinning := spin_left > 0.0
	if spinning:
		spin_left -= delta
		rotation.y = _spin_from if spin_left <= 0.0 else rotation.y + TAU / SPIN_SECONDS * delta
	if not driving or finished() or spinning:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	if kind == LEARNER_CAR:
		_stall(delta)
	var to := points[next] - global_position
	to.y = 0.0
	if to.length() < REACH:
		next += 1
		var turned := _turns_at(next - 1)
		if turned and kind == CAROUSEL_HORSE:
			velocity.y = HORSE_HOP
			hops += 1
		if turned and kind == GALLERY_CART:
			var into := points[next - 1] - points[next - 2]
			var out := points[next] - points[next - 1]
			# Turning left (+ angle from above), it leans right, out of the curve.
			_sway_speed = SWAY_KICK * signf(Vector2(into.x, -into.z).angle_to(Vector2(out.x, -out.z)))
			sways += 1
		corner_passed.emit(turned)
		return
	var forward := global_basis.z
	var turn := forward.signed_angle_to(to, Vector3.UP)
	# Flat or tangled, he can't get anywhere (and doesn't turn on the spot).
	var can_go := 0.0 if tangled_left > 0.0 or is_stalled() else _rolling
	var rate: float = TURN_RATES.get(kind, TURN_RATE)
	rotation.y += clampf(turn, -rate * delta, rate * delta) * can_go
	# Slows down while its nose isn't on the next point yet: through the corners.
	var speed: float = top_speed() * lerpf(1.0, TURN_SPEEDS.get(kind, TURN_SPEED), clampf(absf(turn) / (PI / 2), 0.0, 1.0))
	if nervous_left > 0.0:
		speed *= NERVOUS_SPEED
	speed *= can_go
	var wish := global_basis.z * speed
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()
	climb_curbs(self)
	var moved := Vector2(get_real_velocity().x, get_real_velocity().z).length()
	# The wheelchair is slow anyway: stuck is slower than a share of his own speed.
	var stuck_below := minf(STUCK_SPEED, top_speed() * STUCK_SHARE)
	stuck_for = stuck_for + delta if moved < stuck_below else 0.0


## Up the living city's curbs (CityLife): whatever rides the sidewalks has a body that starts on the street, and a
## 15 cm step stops it otherwise.
static func climb_curbs(body: CharacterBody3D) -> void:
	for k in body.get_slide_collision_count():
		var hit := body.get_slide_collision(k)
		var other := hit.get_collider() as Node
		if absf(hit.get_normal().y) < 0.5 and other and other.is_in_group(CityLife.SIDEWALKS):
			body.global_position.y += CityLife.CURB + 0.05
			return


## The cart's painting springs back after each kick and settles.
func _sway(delta: float) -> void:
	_sway_speed += (-SWAY_SPRING * sway - SWAY_DAMP * _sway_speed) * delta
	_lean(sway + _sway_speed * delta)


func _lean(angle: float) -> void:
	sway = clampf(angle, -SWAY_MAX, SWAY_MAX)
	var painting := get_node_or_null("Painting") as Node3D
	if painting:
		painting.rotation.z = sway


## The learner car stalls every STALL_EVERY seconds of driving, for STALL_TIME.
func _stall(delta: float) -> void:
	if is_stalled():
		stalled_left = maxf(stalled_left - delta, 0.0)
	else:
		stall_in -= delta
		if stall_in <= 0.0:
			stall_in = STALL_EVERY
			stalled_left = STALL_TIME
	var mark := get_node_or_null("Stalled") as Node3D
	if mark:
		mark.visible = is_stalled()


## The party patrol car's plastic siren: two notes in turns, each wobbling as it goes, never quite in tune.
static func toy_siren_stream() -> AudioStreamWAV:
	var rate := 22050
	var samples := int(rate * TOY_SIREN_NOTE * TOY_SIREN_NOTES.size())
	var data := PackedByteArray()
	data.resize(samples * 2)
	var phase := 0.0
	for i in samples:
		var t := float(i) / rate
		var note := TOY_SIREN_NOTES[int(t / TOY_SIREN_NOTE) % TOY_SIREN_NOTES.size()]
		phase += TAU * note * (1.0 + 0.03 * sin(TAU * 3.0 * t)) / rate
		data.encode_s16(i * 2, int((0.6 * sin(phase) + 0.2 * signf(sin(phase))) * 20000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream
