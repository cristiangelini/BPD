class_name Appraisal
extends OfficePrinter

## Don Regateo's weak spot at the pawn shop (allanamiento-empenos.md, "Su distracción, la tasación"): something a cop
## brings to pawn. He takes it to the appraisal mat at the back of his counter and crouches over it with his loupe,
## his back to the shop, for the floor boss's fix time; then he pays (PawnCounter). After an appraisal he rests REST
## seconds: what comes meanwhile he prices at a glance, not turning away. From the CATCH_ON-th one on he sees through
## it, won't buy and grows suspicious instead (`caught_on`). Every number here is (propuesta).

## He's done: what he was looking at gets its price.
signal appraised
## "¿Usted vino a vender o a mirar?": no appraisal, only a complaint.
signal caught_on

const REST := 45.0
const CATCH_ON := 3
const MAT := Color(0.12, 0.3, 0.2)

## How many appraisals counted, and how long until the next one counts.
var count := 0
var rest_left := 0.0


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.mesh_box(Vector3(0, 0.005, 0), Vector3(0.5, 0.01, 0.4), MAT)


## Something to pawn: "slow" (he turns away to appraise it, `appraised` when done), "quick" (resting: priced at a
## glance), "busy" (he's at another one) or "refused" (he caught on).
func bring() -> String:
	if is_jammed:
		return "busy"
	if rest_left > 0.0:
		return "quick"
	count += 1
	rest_left = REST
	if count >= CATCH_ON:
		caught_on.emit()
		return "refused"
	is_jammed = true
	jobs += 1
	jammed.emit()
	return "slow"


func print_copies(_cop: Cop = null) -> void:
	bring()


## He's done with the loupe.
func fix() -> void:
	is_jammed = false
	appraised.emit()


func _process(delta: float) -> void:
	if not is_jammed:
		rest_left = maxf(rest_left - delta, 0.0)
