class_name OfficeClues
extends Node

## The office case's clues upstairs (escena-oficina.md, "Las pistas"), put by FormsOffice when the case comes: the
## thief's cup on the manager's desk (ThiefCup: prints, coffee and handle), the bitten cookie on its saucer and the
## coffee footprint on the carpet, where the thief stepped in what he spilled. And Pelusa: once a cop walks into the
## office it starts its round, and if it gets to the footprint it vacuums it away, unless a cop flipped it over first.
## Every number here is (propuesta).

const CUP_AT := Vector3(-0.5, 0, 0.15)
const COOKIE_AT := Vector3(-0.3, 0, 0.25)
## On Pelusa's round, between the manager's office's door and the copier's corner.
const FOOTPRINT_AT := Vector3(5.8, 0, -3.0)
const COFFEE := Color(0.45, 0.3, 0.18)

var office: FormsOffice
var case: CrimeSceneCase
var cup: ThiefCup
var footprint: FlourPrint


func _ready() -> void:
	var culprit := case.culprit()
	var desk_top := FormsOffice.MANAGER_DESK_AT + Vector3(0, FormsOffice.MANAGER_DESK_SIZE.y, 0)
	cup = ThiefCup.new()
	cup.name = "ThiefCup"
	cup.case = case
	cup.has_prints = case.plan.clues.has("prints")
	cup.coffee = culprit.coffee
	cup.left = culprit.left
	cup.position = desk_top + CUP_AT
	office.add_child(cup)
	if case.plan.clues.has("bite"):
		var cookie := CrimeClueItem.new()
		cookie.name = "Clue_bite"
		cookie.kind = "bite"
		cookie.look = "office"
		cookie.case = case
		cookie.position = desk_top + COOKIE_AT
		office.add_child(cookie)
		case.items.bite = cookie
	if case.plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "CoffeePrint"
		footprint.case = case
		footprint.shoe = culprit.shoe
		footprint.dust = COFFEE
		footprint.position = FOOTPRINT_AT + Vector3(0, FormsOffice.UP, 0)
		office.add_child(footprint)
		case.flour_print = footprint
		office.vacuum.footprint = footprint
	office.vacuum.running = false


func _physics_process(_delta: float) -> void:
	# Online the host's office runs Pelusa.
	if case.follower or office.vacuum.running or office.vacuum.flipped:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if office.inside((cop as Node3D).global_position):
			office.vacuum.running = true
			return
