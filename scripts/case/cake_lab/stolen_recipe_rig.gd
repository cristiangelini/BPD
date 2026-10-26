class_name StolenRecipeRig
extends CakeLabRig

## The stolen recipe (laboratorio.md, "La receta robada"): the chef dressed up as a delivery man and stole the secret
## recipe book of the bakery across the street. The book is the main evidence (0.5 kg), baked inside one of the six
## order cakes on the cold room's table: the only way to find it is opening them, and every cake opened is squashed (a
## fine, and the chef minds it). The photo of the chef in disguise and the delivery cap are hidden. The story's own
## clue: a copied recipe on the flavor lab's formula board, with the other bakery's logo. Pocha's sample tastes just
## like the other bakery's cake. Every number here is (propuesta).

## The stuffed cake was opened and the book is out.
signal found(at: Vector3)

const CAKE_SCENE := preload("res://scenes/props/bakery_cake.tscn")
const BOOK_SCENE := preload("res://scenes/props/recipe_book.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")
## The order cakes' table in the cold room, along z, and its cakes in two columns.
const TABLE_AT := Vector3(7.2, CakeLab.FLOOR_TOP, -7.5)
const TABLE_SIZE := Vector3(0.8, 0.8, 2.4)
const CAKES := 6
## The copied recipe pinned on the formula board.
const RECIPE_AT := Vector3(-2.9, 1.6, -CakeLab.HALF_Z + 0.13)
const RECIPE_SIZE := Vector3(0.6, 0.01, 0.45)
const BOOK_LAYER := 4

var cakes: Array[Ornament] = []
## Which of the cakes has the book inside (drawn with the seed).
var stuffed := 0
var book: Evidence
var recipe: ClueNote


func setup(place: CakeLab) -> void:
	super.setup(place)
	place.pocha.sample_hint = "HINT_SAMPLE_RECIPE"
	place._table(TABLE_AT, TABLE_SIZE, CakeLab.STEEL, CakeLab.STEEL)
	stuffed = place.case_seed % CAKES
	for i in CAKES:
		var cake: Ornament = CAKE_SCENE.instantiate()
		var x := TABLE_AT.x + (-0.2 if i % 2 == 0 else 0.2)
		var z := TABLE_AT.z - 0.8 + int(i / 2) * 0.8
		cake.position = Vector3(x, TABLE_AT.y + TABLE_SIZE.y + CakeLab.CAKE_HALF_HEIGHT + 0.005, z)
		place.add_child(cake)
		cake.broken.connect(place._on_cake_broken)
		cake.broken.connect(func(at: Vector3) -> void: _opened(i, at))
		cakes.append(cake)
	book = BOOK_SCENE.instantiate()
	book.position = cakes[stuffed].position
	book.freeze = true
	book.visible = false
	book.collision_layer = 0
	place.add_child(book)
	place.main = book
	recipe = NOTE_SCENE.instantiate()
	recipe.text = tr("CLUE_COPIED_RECIPE")
	recipe.prompt = "PROMPT_COPIED_RECIPE"
	recipe.freeze = true
	recipe.position = RECIPE_AT
	recipe.rotation.x = PI / 2
	place.add_child(recipe)
	_dress_recipe()
	recipe.read.connect(place.raid.add_clue)


func is_found() -> bool:
	return book.visible


## A cake was opened (squashed): if it's the stuffed one, the book comes out where it was.
func _opened(i: int, at: Vector3) -> void:
	if i != stuffed or is_found():
		return
	book.global_position = at + Vector3.UP * 0.1
	book.visible = true
	book.collision_layer = BOOK_LAYER
	# Online only the host simulates it; a guest's copy stays frozen and follows (PropSync).
	book.freeze = not multiplayer.is_server()
	found.emit(at)


## The note as a big sheet pinned on the board: lines of handwriting and the other bakery's logo crossed out.
func _dress_recipe() -> void:
	var box := BoxShape3D.new()
	box.size = RECIPE_SIZE
	(recipe.get_node("Shape") as CollisionShape3D).shape = box
	var sheet := BoxMesh.new()
	sheet.size = RECIPE_SIZE
	(recipe.get_node("Mesh") as MeshInstance3D).mesh = sheet
	(recipe.get_node("Mesh") as MeshInstance3D).material_override = _color(Color(0.98, 0.97, 0.93))
	for i in 5:
		_part(Vector3(-0.05, 0.007, -0.12 + i * 0.065), Vector3(0.36, 0.002, 0.012), Color(0.25, 0.3, 0.6))
	_part(Vector3(0.21, 0.007, -0.14), Vector3(0.1, 0.002, 0.1), Color(0.95, 0.82, 0.3))
	_part(Vector3(0.21, 0.009, -0.14), Vector3(0.14, 0.002, 0.015), Color(0.85, 0.15, 0.12)).rotation.y = PI / 4


func _part(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	part.material_override = _color(color)
	recipe.add_child(part)
	return part


func _color(color: Color) -> StandardMaterial3D:
	var look := StandardMaterial3D.new()
	look.albedo_color = color
	return look
