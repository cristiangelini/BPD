class_name SpyTelescopeRig
extends ApartmentsRig

## The spy telescope (edificio.md, "El telescopio espía"): Mr. Bellini's telescope by 30B's living room window points
## at the vault of the bank across the street. It is fragile and takes two, but it fits in the elevator. The story's
## clues: E looks through it and sees the vault's code, and a tape mark on the balcony's floor where the tripod stood
## (each goes on the checklist once). Every number here is (propuesta).

const TELESCOPE_SCENE := preload("res://scenes/props/spy_telescope.tscn")
const TELESCOPE_HALF_HEIGHT := 0.775
## In the living room by the window, pointing at the street, on the parquet.
const TELESCOPE_AT := Vector3(0.5, ApartmentTower.TOP_Y + 0.02, 7.0)
## Where the tripod stood on the balcony: three strips of tape around an empty spot.
const TAPE_AT := Vector3(1.5, ApartmentTower.TOP_Y, 8.8)
const TAPE := Color(0.95, 0.85, 0.3)

var telescope: SpyTelescope
var tape: ClueSpot


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	telescope = TELESCOPE_SCENE.instantiate()
	telescope.position = TELESCOPE_AT + Vector3.UP * (TELESCOPE_HALF_HEIGHT + 0.01)
	place.add_child(telescope)
	place.main = telescope
	telescope.looked.connect(func() -> void: tower.raid.add_clue(tr("CLUE_TELESCOPE_VAULT")))
	tape = ClueSpot.new()
	tape.size = Vector3(0.6, 0.03, 0.6)
	tape.prompt = "PROMPT_TAPE_MARK"
	tape.text = "CLUE_TAPE_MARK"
	tape.position = TAPE_AT + Vector3.UP * 0.02
	var material := StandardMaterial3D.new()
	material.albedo_color = TAPE
	for i in 3:
		var angle := i * TAU / 3
		var strip := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.3, 0.005, 0.05)
		mesh.material = material
		strip.mesh = mesh
		strip.position = Vector3(sin(angle), 0, cos(angle)) * 0.25
		strip.rotation.y = angle + PI / 2
		tape.add_child(strip)
	place.add_child(tape)
	tape.read.connect(func(text: String) -> void: tower.raid.add_clue(tr(text)))
