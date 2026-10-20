class_name CaseObjectives
extends RefCounted

## The checklist (planilla) that Q opens during the raid (allanamiento.md, "Charla del comisario y planilla").
## Built from plain facts about the case so the house only reports what happened.


## Facts: door_open, found, delivered, all_in_car (bools), broken, fines, complaint (numbers), and optionally
## find (the story's tr() key for finding the main evidence), extras (the story's rows: [{text, done}]),
## clues (lines of found clues), tupper_asked, tupper_returned (bools), and suspicions ([{"name": tr() key,
## "state": "open", "right" or "wrong"}]) with story_known (bool) when the cops have to guess the story. A place
## that isn't the grandpa's house names its own rows with enter_key, guess_key, broken_key and complaint_key.
## Returns rows {text: tr() key or formatted text, done: bool, optional: bool, status: bool}, in play order.
static func rows(facts: Dictionary) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row(facts.get("enter_key", "OBJ_ENTER"), facts.door_open))
	var suspicions: Array = facts.get("suspicions", [])
	if not suspicions.is_empty():
		list.append(_row(facts.get("guess_key", "OBJ_GUESS"), facts.get("story_known", false)))
		for i in suspicions.size():
			var mark: String = {"open": "[ ]", "right": "[x]", "wrong": "[-]"}[suspicions[i].state]
			list.append({"text": "   %s %d. %s" % [mark, i + 1, TranslationServer.translate(suspicions[i].name)],
				"done": suspicions[i].state == "right", "optional": false, "status": true})
	list.append(_row(facts.get("find", "OBJ_FIND"), facts.found or facts.delivered))
	list.append(_row("OBJ_TRUNK", facts.delivered))
	list.append(_row("OBJ_LEAVE", facts.delivered and facts.all_in_car and facts.get("at_station", true)))
	for extra: Dictionary in facts.get("extras", []):
		list.append(_extra(extra.text, extra.done))
	if facts.get("tupper_asked", false):
		list.append(_extra("OBJ_EXTRA_TUPPER", facts.get("tupper_returned", false)))
	var clues: Array = facts.get("clues", [])
	if not clues.is_empty():
		list.append({"text": "OBJ_CLUES", "done": false, "optional": false, "status": true, "clue": true})
	for clue: String in clues:
		list.append({"text": "- " + clue, "done": false, "optional": false, "status": true, "clue": true})
	list.append({"text": TranslationServer.translate(facts.get("broken_key", "OBJ_BROKEN")) % [facts.broken, facts.fines],
		"done": false, "optional": false, "status": true})
	list.append({"text": TranslationServer.translate(facts.get("complaint_key", "OBJ_COMPLAINT")) % roundi(facts.complaint),
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
