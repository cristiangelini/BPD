class_name CookieTin
extends DonutBox

## The cookie tin on Formularios Infinitos' kitchen counter (escena-oficina.md, "Las fichas"): a donut box with company
## cookies. In hand, E eats one like a donut; on an employee, he bites one and his teeth go to his file
## (OfficeEmployee.feed). Every number here is (propuesta).


func _ready() -> void:
	super()
	donuts = 12


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_COOKIE_TIN" if donuts > 0 else "PROMPT_COOKIE_EMPTY"
