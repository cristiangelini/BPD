class_name Campaign
extends RefCounted

## A whole match of 5 shifts, saved between shifts (docs/diseno/guardado.md): the next shift, the group's money, the
## items, and the cases that follow, which all come from the campaign's own seed. Only the host saves it online.
## Each shift has a quota that rises shift by shift. Missing it the first time locks the cops up in their own cells for
## the jailbreak (decision 99, fuga.md); missing it again, or not escaping, ends the campaign (decision 88).

const SHIFTS := 5
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
## The place's owner the cops brought in at the end of the last raid (RaidCase.custody), to be interrogated next
## shift (decision 93); empty if nobody.
var custody := {}


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


## Closes the shift with its end of shift numbers (ShiftReport.pay) and moves on to the next one. The report's quota
## and verdict become this shift's (quota(), or `shift_quota` for a shift with its own), so the end of shift screen
## shows them.
func finish_shift(story: String, solved: bool, report: Dictionary, shift_quota := -1) -> void:
	report.quota = quota() if shift_quota < 0 else shift_quota
	report.approved = report.total >= report.quota
	history.append({"shift": shift, "story": story, "solved": solved, "total": report.total,
		"approved": report.approved})
	shift += 1
	if report.approved:
		money += report.total
	elif not jailbreak_used:
		# The failed shift adds nothing to the money: escaping is a second chance, not a prize (fuga.md).
		jailed = true
		jailbreak_used = true
	else:
		money += report.total
		suspended = true


## The jailbreak is over: escaped, the next shift goes on as usual; caught, the campaign is lost (decision 99).
func finish_jailbreak(escaped: bool) -> void:
	jailed = false
	jail_catches = 0
	suspended = not escaped


func to_dict() -> Dictionary:
	return {"version": VERSION, "seed": campaign_seed, "shift": shift, "money": money, "items": items,
		"history": history, "suspended": suspended, "custody": custody, "jailed": jailed,
		"jailbreak_used": jailbreak_used, "jail_catches": jail_catches}


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
