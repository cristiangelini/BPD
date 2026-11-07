class_name ItchyCostumesRig
extends CostumeRig

## The costumes that itch (allanamiento-disfraces.md, "Los disfraces que pican"): Don Fantoche sprinkles itching powder
## on his costumes so the customers buy his cousin's "Antipica" cream. The drum of powder (10 kg, the main evidence),
## the cream jars and the pharmacy's flyer are hidden. A costume in the sale basket makes the cop who grabs it scratch
## (ItchyCostume, the story's clue), and the customers come out of the fitting rooms scratching. Every number here is
## (propuesta).

const COSTUME_AT := Vector3(-2.2, CostumeShop.FLOOR_TOP + 0.42, 7.4)

var costume: ItchyCostume
var _heard := false


func setup(place: CostumeShop) -> void:
	super.setup(place)
	costume = ItchyCostume.new()
	costume.position = COSTUME_AT
	costume.rotation.y = 0.3
	place.add_child(costume)
	costume.itched.connect(_on_itched)
	for customer: CostumeCustomer in place.customers:
		customer.came_out.connect(func(who: CostumeCustomer) -> void: who.say("CUSTOMER_ITCHY"))


func _on_itched(_cop: Cop) -> void:
	if not _heard:
		_heard = true
		shop.raid.add_clue(tr("CLUE_ITCHY_COSTUME"))

