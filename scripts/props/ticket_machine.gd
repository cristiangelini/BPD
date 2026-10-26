class_name TicketMachine
extends StaticBody3D

## The insurance office's take-a-number machine (docs/diseno/seguros.md, "Coca"): a red box on a post by the entrance.
## E gives the cop a number for the receptionist, one at a time. It faces +z.

## The receptionist whose numbers it gives (set by the office).
var receptionist: Receptionist


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, 0.55, 0), Vector3(0.08, 1.1, 0.08), Color(0.45, 0.47, 0.5))
	build.box(Vector3(0, 1.25, 0), Vector3(0.3, 0.3, 0.22), Color(0.85, 0.2, 0.18))
	build.mesh_box(Vector3(0, 1.18, 0.115), Vector3(0.12, 0.02, 0.01), Color(0.95, 0.95, 0.9))
	var sign_label := Label3D.new()
	sign_label.text = "TICKET_SIGN"
	sign_label.position = Vector3(0, 1.32, 0.115)
	sign_label.pixel_size = 0.0018
	sign_label.font_size = 32
	sign_label.outline_size = 6
	add_child(sign_label)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TICKET"


func use(cop: Cop) -> void:
	if not receptionist:
		return
	var had := receptionist.tickets.has(cop)
	var number := receptionist.take_ticket(cop)
	cop.show_hint(tr("HINT_TICKET_HELD" if had else "HINT_TICKET") % number)
