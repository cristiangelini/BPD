class_name CaseObjectives
extends RefCounted

## The checklist (planilla) that Q opens during the raid (allanamiento.md, "Charla del comisario y planilla").
## Built from plain facts about the case so the house only reports what happened.


## Facts: door_open, found, delivered, all_in_car, cage_delivered, safe_delivered (bools), cards_delivered, cards_total,
## broken, fines, complaint (numbers), clues (lines of found clues).
## Returns rows {text: tr() key or formatted text, done: bool, optional: bool, status: bool}, in play order.
static func rows(facts: Dictionary) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_ENTER", facts.door_open))
	list.append(_row("OBJ_FIND", facts.found or facts.delivered))
	list.append(_row("OBJ_TRUNK", facts.delivered))
	list.append(_row("OBJ_LEAVE", facts.delivered and facts.all_in_car))
	list.append(_extra("OBJ_EXTRA_CAGE", facts.cage_delivered))
	list.append(_extra("OBJ_EXTRA_SAFE", facts.safe_delivered))
	list.append(_extra(TranslationServer.translate("OBJ_EXTRA_CARDS") % [facts.cards_delivered, facts.cards_total],
		facts.cards_total > 0 and facts.cards_delivered == facts.cards_total))
	var clues: Array = facts.get("clues", [])
	if not clues.is_empty():
		list.append({"text": "OBJ_CLUES", "done": false, "optional": false, "status": true, "clue": true})
	for clue: String in clues:
		list.append({"text": "- " + clue, "done": false, "optional": false, "status": true, "clue": true})
	list.append({"text": TranslationServer.translate("OBJ_BROKEN") % [facts.broken, facts.fines],
		"done": false, "optional": false, "status": true})
	list.append({"text": TranslationServer.translate("OBJ_COMPLAINT") % roundi(facts.complaint),
		"done": false, "optional": false, "status": true})
	return list


## The first required row not done yet, or -1 when the case is solved.
static func next_step(list: Array[Dictionary]) -> int:
	for i in list.size():
		if not list[i].optional and not list[i].status and not list[i].done:
			return i
	return -1


static func _extra(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": true, "status": false}


static func _row(key: String, done: bool) -> Dictionary:
	return {"text": key, "done": done, "optional": false, "status": false}
