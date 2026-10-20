# BPD · Buddies Police Department

Absurd online co-op for 1 to 4 friends playing clumsy rookie cops in a police station (PC / Steam), first person,
physics-driven, in the vein of R.E.P.O., PEAK and Dear Passengers. Godot 4.7.2, GDScript with static typing, Forward+.

Design lives in `docs/diseno/`: `decisiones.md` (numbered decisions, the source of truth), `casos.md` (case catalog)
and `reglas-de-trabajo.md` (how we work; it wins over any old habit). Read them, don't copy them here.
Rules Cristian already gave are in the skill `.claude/skills/bpd/`: read it first, and add every new correction of his
to it (rule + why) in the same PR.

## Rules
- Branches: `main` (releases) and `develop` (integration). Branch from an up-to-date `develop`
  (`git fetch origin develop` before branching and before every push), one small PR per GitHub issue to `develop`
  (about 400 changed lines at most, assets not counted). Claude opens PRs and never merges them: Cristian merges.
- No frozen weekly goal: each week moves as far as it can (decision 78). Ideas not done now go to the "Para después" issue.
- No big system gets coded without its `docs/diseno/<system>.md` (rules, numbers, how you win and lose).
  Ambiguous ask: ask Cristian, don't invent.
- At most 2 code sessions at a time, each in its own area and worktree.
- Code, commits, branches and PRs in English. Game text in neutral Spanish with "tú", always through `tr()` keys in
  `translations/texts.csv` with `es`, `en` and `pt` columns. Glossary: caso (not misión), sospechoso (not enemigo),
  comisario (not jefe). No references to any real country.
- Every new feature adds at least one GUT test. CI must be green before asking for review; never skip or disable a test.
- Every new feature adds its shortcut to the debug panel (once it exists).
- Never claim something works or looks right without a screenshot or test output.
- Placeholders are procedural low poly models (`tools/modelgen`), not grey boxes; AI art is never final; final art needs Cristian's approval.
- No HTML pages for mechanics, maps, effects or HUD: try it in Godot.
- Don't create repos, push to `main` or make builds unless Cristian asks.
- Files in UTF-8 without BOM. `.ps1` and `.bat` files in ASCII with CRLF (PowerShell 5.1 breaks accents).

## Commands
- Import (after adding assets or translations): `godot --headless --path . --import`
- Tests (GUT 9.7.1 in `addons/gut`, config in `.gutconfig.json`): `godot --headless --path . -s res://addons/gut/gut_cmdln.gd`
- Play: `godot --path .`
- Online by IP on one PC (docs/diseno/online.md): `godot --path . -- --host` and `godot --path . -- --join=127.0.0.1`
- Online by Steam (GodotSteam via `tools/godotsteam.ps1`, Steam open): `godot --path . -- --host-steam`
- Placeholder models (GLBs into `assets/models/`, previews optional): `cd tools/modelgen && npm install && node run.mjs [--shots <dir>]`

## Where things are
- `scenes/` and `scripts/` mirror each other by area (`ui/` for now). `translations/texts.csv` for all game text.
- `tests/unit/` for GUT tests. `.github/workflows/tests.yml` runs them on every PR.
- `docs/diseno/` design, `docs/partidas/<date>.md` notes from the weekly real match, `CHANGELOG.md` history.
