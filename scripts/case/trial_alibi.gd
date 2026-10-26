class_name TrialAlibi
extends RefCounted

## The fast trial's alibi (docs/diseno/fuga-juicio.md): what the cops say they were doing, where and with whom. Each
## detail is one of GROUPS groups of OPTIONS lookalike answers ("rescuing a cat" / "a dog" / "a parrot"), its text
## keys TRIAL_<DETAIL>_<group>_<option>; the alibi is one group and one right option for each detail, from the case's
## seed and the trial (a new one after each catch). Pure data, so tests can check it without a scene.

const DETAILS: Array[String] = ["WHAT", "WHERE", "WHO"]
const GROUPS := 10
const OPTIONS := 3


## The alibi of trial `trial` (0 the first) in the case with `case_seed`: detail -> [group, right option].
static func draw(case_seed: int, trial: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["trial alibi", case_seed, trial])
	var alibi := {}
	for detail in DETAILS:
		alibi[detail] = [rng.randi_range(0, GROUPS - 1), rng.randi_range(0, OPTIONS - 1)]
	return alibi


## The text key of option `option` of `detail`'s `group`.
static func key(detail: String, group: int, option: int) -> String:
	return "TRIAL_%s_%d_%d" % [detail, group, option]


## The text key of the right answer to `detail` in `alibi`.
static func answer(alibi: Dictionary, detail: String) -> String:
	return key(detail, alibi[detail][0], alibi[detail][1])


## The three answers on the stand for `detail` in `alibi`: its group's options, the right one among them.
static func choices(alibi: Dictionary, detail: String) -> Array[String]:
	var keys: Array[String] = []
	for option in OPTIONS:
		keys.append(key(detail, alibi[detail][0], option))
	return keys


## The lawyer's file, translated: "We were <what>, <where>, <who>."
static func file_text(alibi: Dictionary) -> String:
	return TranslationServer.translate("TRIAL_FILE") % [TranslationServer.translate(answer(alibi, "WHAT")),
		TranslationServer.translate(answer(alibi, "WHERE")), TranslationServer.translate(answer(alibi, "WHO"))]
