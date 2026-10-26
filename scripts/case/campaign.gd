class_name Campaign
extends RefCounted

## A whole match of SHIFTS shifts, saved between shifts (docs/diseno/guardado.md): the next shift, the group's money, the
## items, and the cases that follow, which all come from the campaign's own seed. Only the host saves it online.
## Each shift has a quota that rises shift by shift. Missing it the first time locks the cops up in their own cells for
## the jailbreak (decision 99, fuga.md); missing it again, or not escaping, ends the campaign (decision 88).
## It also keeps the cops' record of bribes and the internal affairs investigation (sobornos.md, decisions 190 to 192).

## Ten shifts to save the station (decision 106, Cristian 26/10: more than five).
const SHIFTS := 10
const SAVE_PATH := "user://partidas/partida.json"
const VERSION := 1
## The first shift's quota and how much it rises each shift after (decision 88). A target, not money paid.
const QUOTA_START := 800
const QUOTA_STEP := 100

## The campaign being played, if any (solo, or hosting a room).
static var current: Campaign
## Where campaigns are saved (tests point it elsewhere).
static var save_path := SAVE_PATH

var campaign_seed := 0
## The next shift to play, 1 to SHIFTS; above SHIFTS the campaign is over.
var shift := 1
var money := 0
var items: Array[String] = []
## One entry per shift played: {"shift", "story", "solved", "total", "approved"}.
var history: Array[Dictionary] = []
## A shift missed its quota: the cops are suspended and the campaign is lost.
var suspended := false
## A shift missed its quota and the cops are locked up in their cells: the jailbreak comes before the next shift.
var jailed := false
## The campaign's one jailbreak already happened (decision 99): the next missed quota ends it.
var jailbreak_used := false
## How many times the night guard caught them in this jailbreak (fuga.md): the third one loses the campaign.
var jail_catches := 0
## The inspector's report while the last shift is on (inspeccion.md, InspectionReport.summary()); empty without her.
var inspection := {}
## How the last shift's inspection ended (InspectionReport.final()), for the end of shift screen; empty if none.
var last_inspection := {}
## The place's owner the cops brought in at the end of the last raid (RaidCase.custody), to be interrogated next
## shift (decision 93); empty if nobody.
var custody := {}
## Money of the bribes taken in the campaign, less the agent's fines and what went to the bribe jailbreak's guard:
## what the cops keep in their socks (fuga-soborno.md).
var bribe_money := 0
## Bribes taken since the record was last clean; Bribes.INVESTIGATION_AT of them open an investigation.
var bribes_taken := 0
## Internal affairs is investigating the cops: its agent follows them in every case.
var investigation := false
## Shifts of this investigation with no bribe taken; Bribes.CLEAN_SHIFTS of them close it.
var clean_shifts := 0
## Times the agent saw a bribe taken in this campaign; Bribes.CATCHES_TO_SUSPEND of them suspend the cops.
var agent_catches := 0
## The shift being played: money of the bribes taken, how many, and how many the agent saw. Never saved: a shift is
## never saved halfway.
var shift_bribes := 0
var shift_bribe_count := 0
var shift_caught := 0


## A new campaign at shift 1 with a fresh seed.
static func start_new() -> Campaign:
	var campaign := Campaign.new()
	campaign.campaign_seed = randi_range(1, 0x7fffffff)
	current = campaign
	return campaign


func is_over() -> bool:
	return suspended or (shift > SHIFTS and not jailed)


## All 5 shifts made their quota: "¡Ascendidos!".
func is_promoted() -> bool:
	return shift > SHIFTS and not suspended and not jailed


## The quota of the shift being played.
func quota() -> int:
	return QUOTA_START + QUOTA_STEP * (shift - 1)


## The case seed of the shift being played: the same for this campaign and shift every time, never 0.
func case_seed() -> int:
	return hash("campaign %d shift %d" % [campaign_seed, shift]) % 0x7fffffff + 1


## A cop took a bribe of `amount`; `seen` says the internal affairs agent saw it (only while investigating). Returns
## true if he caught them: the bribe doesn't count and the shift is fined.
func take_bribe(amount: int, seen := false) -> bool:
	if investigation and seen:
		agent_catches += 1
		shift_caught += 1
		return true
	shift_bribes += amount
	bribe_money += amount
	shift_bribe_count += 1
	bribes_taken += 1
	return false


## Closes the shift with its end of shift numbers (ShiftReport.pay) and moves on to the next one. The report's quota
## and verdict become this shift's (quota(), or `shift_quota` for a shift with its own), so the end of shift screen
## shows them. The shift's bribes and the agent's fines go into the report too, as "bribes", "agent_fine" and, when the
## investigation changes, "investigation" ("opened", "closed" or "suspended").
func finish_shift(story: String, solved: bool, report: Dictionary, shift_quota := -1) -> void:
	_add_bribes(report)
	# What the street paid on the way (ciudad-viva.md) counts with the case's pay.
	CityEvents.add_to(report)
	report.quota = quota() if shift_quota < 0 else shift_quota
	report.approved = report.total >= report.quota
	# On the inspection's shift only her report decides, and failing it closes the station: no jailbreak.
	var inspected := not inspection.is_empty()
	if inspected:
		last_inspection = InspectionReport.final(inspection, solved)
		inspection = {}
		report.inspection = last_inspection.score
		report.inspection_best = last_inspection.best
		report.inspection_worst = last_inspection.worst
		report.approved = last_inspection.approved
	history.append({"shift": shift, "story": story, "solved": solved, "total": report.total,
		"approved": report.approved})
	shift += 1
	if report.approved:
		money += report.total
	elif not jailbreak_used and not inspected:
		# The failed shift adds nothing to the money: escaping is a second chance, not a prize (fuga.md).
		jailed = true
		jailbreak_used = true
	else:
		money += report.total
		suspended = true
	if report.get("investigation", "") == "suspended":
		jailed = false
		suspended = true


## The shift's bribes into its report, and where the investigation goes after this shift.
func _add_bribes(report: Dictionary) -> void:
	report.bribes = shift_bribes
	report.agent_fine = Bribes.CAUGHT_FINE * shift_caught
	report.total += shift_bribes - report.agent_fine
	bribe_money = maxi(bribe_money - report.agent_fine, 0)
	if agent_catches >= Bribes.CATCHES_TO_SUSPEND:
		report.investigation = "suspended"
	elif investigation and shift_bribe_count == 0 and shift_caught == 0:
		clean_shifts += 1
		if clean_shifts >= Bribes.CLEAN_SHIFTS:
			investigation = false
			clean_shifts = 0
			bribes_taken = 0
			report.investigation = "closed"
	elif investigation:
		clean_shifts = 0
	elif bribes_taken >= Bribes.INVESTIGATION_AT:
		investigation = true
		report.investigation = "opened"
	shift_bribes = 0
	shift_bribe_count = 0
	shift_caught = 0


## The bribes' money the cops still have for the bribe jailbreak's guard: never more than the group's money ("si les
## queda", fuga-soborno.md).
func bribe_fund() -> int:
	return clampi(bribe_money, 0, maxi(money, 0))


## What the bribe jailbreak's guard was paid comes out of the group's money and the bribes' money.
func pay_guard(amount: int) -> void:
	money -= amount
	bribe_money = maxi(bribe_money - amount, 0)


## The jailbreak is over: escaped, the next shift goes on as usual; caught, the campaign is lost (decision 99).
func finish_jailbreak(escaped: bool) -> void:
	jailed = false
	jail_catches = 0
	suspended = not escaped


func to_dict() -> Dictionary:
	return {"version": VERSION, "seed": campaign_seed, "shift": shift, "money": money, "items": items,
		"history": history, "suspended": suspended, "custody": custody, "jailed": jailed,
		"jailbreak_used": jailbreak_used, "jail_catches": jail_catches, "bribes_taken": bribes_taken,
		"investigation": investigation, "clean_shifts": clean_shifts, "agent_catches": agent_catches, "bribe_money": bribe_money}


static func from_dict(data: Dictionary) -> Campaign:
	var campaign := Campaign.new()
	campaign.campaign_seed = int(data.get("seed", 0))
	campaign.shift = int(data.get("shift", 1))
	campaign.money = int(data.get("money", 0))
	campaign.suspended = bool(data.get("suspended", false))
	campaign.jailed = bool(data.get("jailed", false))
	campaign.jailbreak_used = bool(data.get("jailbreak_used", false))
	campaign.jail_catches = int(data.get("jail_catches", 0))
	campaign.custody = data.get("custody", {})
	campaign.bribes_taken = int(data.get("bribes_taken", 0))
	campaign.investigation = bool(data.get("investigation", false))
	campaign.clean_shifts = int(data.get("clean_shifts", 0))
	campaign.agent_catches = int(data.get("agent_catches", 0))
	campaign.bribe_money = int(data.get("bribe_money", 0))
	campaign.items.assign(data.get("items", []))
	# JSON brings every number back as a float.
	for entry: Dictionary in data.get("history", []):
		campaign.history.append({"shift": int(entry.get("shift", 0)), "story": str(entry.get("story", "")),
			"solved": bool(entry.get("solved", false)), "total": int(entry.get("total", 0)),
			"approved": bool(entry.get("approved", false))})
	return campaign


func save(path := save_path) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_dict(), "\t"))
	return OK


## The saved campaign at `path`, or null if there is none or it can't be read.
static func load_saved(path := save_path) -> Campaign:
	if not FileAccess.file_exists(path):
		return null
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return from_dict(data) if data is Dictionary else null


## A saved campaign that still has shifts to play.
static func can_continue(path := save_path) -> bool:
	var saved := load_saved(path)
	return saved != null and not saved.is_over()
