class_name CrimeSceneCase
extends Node

## The crime scene's case (escena-del-crimen.md, step 2), the same for every place (CrimeScenePlace): the comisario
## tells it in his office, the seed picks the suspects' traits, the culprit and his 4 clues (CrimePlan), and Q opens the
## planilla with what's left to do. The place puts the clues (the carried ones in `items`); `found` notes one and `ruin`
## loses it. The suspects fill their files (`file_part`); the board sets `accused`, and then the culprit gives up or runs
## off in his getaway (`runs_off`). The place's `variant` picks the texts, the traits and the getaway (VARIANTS).

## How often the open planilla redraws, in seconds.
const REFRESH := 0.5
## A second wrong accusation loses the case (propuesta, like the raid's suspicions).
const MAX_WRONG := 2
## The cooks get tired (Cristian, 21/10): from this many seconds after the tip, one goes home every LEAVE_EVERY.
const LEAVE_FROM := 480.0
const LEAVE_EVERY := 120.0
## Seconds between the verdict and the end of shift screen.
const SHIFT_DELAY := 3.0
## At the circus and the museum, finding what was stolen adds this much to the salary, if the case is solved
## (escena-circo.md, escena-museo.md).
const LOOT_BONUS := 100.0
## Each of the museum's frames broken in the chase is taken off the salary (escena-museo.md, pregunta 3).
const FRAME_FINE := 20
## At the station (escena-comisaria.md), internal affairs comes and takes the case this many seconds after the tip, or
## sooner when the campaign is already under investigation (decision 191); the comisario warns IA_WARN seconds before.
const IA_AT := 600.0
const IA_INVESTIGATING := 360.0
const IA_WARN := 120.0
## Its own quota, like the interrogation and the chase (decision 91).
const QUOTA := ShiftReport.SALARY
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## Accused, half the culprits (by the seed) run off on the delivery bike instead of giving up (Cristian, 21/10:
## "que algunos corran y que otros pasen a interrogatorio"; half and half is a propuesta).
const RUNS_EVERY := 2
## At the circus, the trait each part of a clown's file tells.
const PART_TRAITS := {"photo": "glasses", "prints": "name", "teeth": "teeth", "hair": "hair", "shoe": "shoe",
	"honk": "honk"}
## What changes from one place to the other: the campaign's case id and the interrogation's story, the comisario's
## briefing, the hint to go there, who the culprit is for the chase and what he runs off in, which trait each clue
## tells (CrimePlan) and the parts of a suspect's file.
const VARIANTS := {
	"pastry": {
		"shift": "crime_pastry", "story": "pastry",
		"brief": ["BRIEF_CRIME_A", "BRIEF_CRIME_B", "BRIEF_CRIME_C"], "go": "HINT_GO_CONTEST",
		"go_row": "OBJ_CRIME_GO", "look": "HINT_CRIME_LOOK", "files_row": "OBJ_CRIME_FILES",
		"clue_line": "CLUE_CRIME_", "ruined_hint": "HINT_CRIME_RUINED_", "left": "HINT_COOK_LEFT",
		"who": "cook", "getaway": SuspectCar.BIKE, "clues": CrimePlan.CLUES,
		"parts": ["photo", "prints", "teeth", "hair"],
	},
	# The circus (escena-circo.md, decision 130): six clowns alike; what hides them comes off for the file.
	"circus": {
		"shift": "crime_circus", "story": "circus",
		"brief": ["BRIEF_CIRCUS_A_", "BRIEF_CIRCUS_B", "BRIEF_CIRCUS_C"], "go": "HINT_GO_CIRCUS",
		"go_row": "OBJ_CIRCUS_GO", "look": "HINT_CIRCUS_LOOK", "files_row": "OBJ_CIRCUS_FILES",
		"clue_line": "CLUE_CIRCUS_", "ruined_hint": "HINT_CIRCUS_RUINED_", "left": "HINT_CLOWN_LEFT",
		"who": "clown", "getaway": SuspectCar.CLOWN_CAR, "loot_row": "OBJ_CIRCUS_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recording": "honk",
			"witness": "glasses"},
		"parts": ["photo", "prints", "teeth", "hair", "shoe", "honk"],
	},
	# The museum (escena-museo.md, decision 200): six guards alike who all say they were in the bathroom; a file knows
	# what the cops got from its guard, his alibi included.
	"museum": {
		"shift": "crime_museum", "story": "museum",
		"brief": ["BRIEF_CITY_MUSEUM_A_", "BRIEF_CITY_MUSEUM_B", "BRIEF_CITY_MUSEUM_C"], "go": "HINT_GO_MUSEUM",
		"go_row": "OBJ_MUSEUM_GO", "look": "HINT_MUSEUM_LOOK", "files_row": "OBJ_MUSEUM_FILES",
		"clue_line": "CLUE_MUSEUM_", "ruined_hint": "HINT_MUSEUM_RUINED_", "left": "HINT_GUARD_LEFT",
		"who": "guard", "getaway": SuspectCar.ART_VAN, "loot_row": "OBJ_MUSEUM_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recording": "mustache",
			"witness": "glasses", "alibi": "liar"},
		"parts": ["photo", "prints", "teeth", "hair", "mustache", "alibi"],
	},
	# The train (escena-tren.md, decision 202): six magicians alike who swap seats in every tunnel; a file follows its
	# sticker, like the circus's signs.
	"train": {
		"shift": "crime_train", "story": "train",
		"brief": ["BRIEF_TRAIN_A_", "BRIEF_TRAIN_B", "BRIEF_TRAIN_C"], "go": "HINT_GO_TRAIN",
		"go_row": "OBJ_TRAIN_GO", "look": "HINT_TRAIN_LOOK", "files_row": "OBJ_TRAIN_FILES",
		"clue_line": "CLUE_TRAIN_", "ruined_hint": "HINT_TRAIN_RUINED_", "left": "HINT_MAGICIAN_LEFT",
		"who": "magician", "getaway": SuspectCar.BIKE, "clues": MagicianTraits.CLUES, "loot_row": "OBJ_TRAIN_LOOT_",
		"parts": ["photo", "prints", "teeth", "hair", "knot"],
		# Nobody goes home on a moving train: the hurry is the last station (Train, end_of_line).
		"tire": false,
	},
	# The Candelabro mansion (escena-mansion.md, decision 270): six Mystery Club members alike as Detective Pipa; a file
	# knows what the cops got from its member, the room of their alibi included.
	"mansion": {
		"shift": "crime_mansion", "story": "mansion",
		"brief": ["BRIEF_MANSION_A_", "BRIEF_MANSION_B", "BRIEF_MANSION_C"], "go": "HINT_GO_MANSION",
		"go_row": "OBJ_MANSION_GO", "look": "HINT_MANSION_LOOK", "files_row": "OBJ_MANSION_FILES",
		"clue_line": "CLUE_MANSION_", "ruined_hint": "HINT_MANSION_RUINED_", "left": "HINT_MEMBER_LEFT",
		"who": "member", "getaway": SuspectCar.BIKE, "loot_row": "OBJ_MANSION_LOOT_", "catch_row": "OBJ_MANSION_CATCH",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "bells": "room",
			"witness": "glasses"},
		"parts": ["photo", "prints", "teeth", "hair", "midnight"],
	},
	# The wedding (escena-boda.md, decision 290): Tito and five groomsmen in the same tuxedo; a file knows what the
	# cops got from each, his cologne included. The texts come with the case (step 4).
	"wedding": {
		"shift": "crime_wedding", "story": "wedding",
		"brief": ["BRIEF_CRIME_WEDDING_A_", "BRIEF_CRIME_WEDDING_B", "BRIEF_CRIME_WEDDING_C"], "go": "HINT_GO_WEDDING",
		"go_row": "OBJ_WEDDING_GO", "look": "HINT_WEDDING_LOOK", "files_row": "OBJ_WEDDING_FILES",
		"clue_line": "CLUE_CRIME_WEDDING_", "ruined_hint": "HINT_CRIME_WEDDING_RUINED_", "left": "HINT_TUXEDO_LEFT",
		"who": "tuxedo", "getaway": WeddingHall.GETAWAY, "loot_row": "OBJ_WEDDING_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recording": "glasses",
			"witness": "cologne"},
		"parts": ["photo", "prints", "teeth", "hair", "cologne"],
	},
	# The hotel (escena-hotel.md, decision 201): six guests alike in bathrobes; their rooms tell what doesn't show on
	# them, and the concierge swapped two rooms.
	"hotel": {
		"shift": "crime_hotel", "story": "hotel",
		"brief": ["BRIEF_HOTEL_A_", "BRIEF_HOTEL_B", "BRIEF_HOTEL_C"], "go": "HINT_GO_HOTEL",
		"go_row": "OBJ_HOTEL_GO", "look": "HINT_HOTEL_LOOK", "files_row": "OBJ_HOTEL_FILES",
		"clue_line": "CLUE_HOTEL_", "ruined_hint": "HINT_HOTEL_RUINED_", "left": "HINT_GUEST_LEFT",
		"who": "guest", "getaway": SuspectCar.HOTEL_SHUTTLE, "loot_row": "OBJ_HOTEL_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "witness": "glasses",
			"signature": "left"},
		"parts": ["prints", "teeth", "sign", "shoe", "hair", "glasses"],
	},
	# The Monedero mansion (escena-gato.md, decision 260): six nephews alike in the sweater their aunt knitted; a file
	# knows what the cops got from its nephew, his scratch and his catchphrase included.
	"cat": {
		"shift": "crime_cat", "story": "cat",
		"brief": ["BRIEF_CAT_A_", "BRIEF_CAT_B", "BRIEF_CAT_C"], "go": "HINT_GO_CAT_MANSION",
		"go_row": "OBJ_CAT_GO", "look": "HINT_CAT_LOOK", "files_row": "OBJ_CAT_FILES",
		"clue_line": "CLUE_CAT_", "ruined_hint": "HINT_CAT_RUINED_", "left": "HINT_NEPHEW_LEFT",
		"who": "nephew", "getaway": SuspectCar.LIMO, "loot_row": "OBJ_CAT_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "necklace": "scratch",
			"witness": "tic"},
		"parts": ["photo", "prints", "teeth", "hair", "scratch", "tic"],
	},
	# The office (escena-oficina.md, decision 280): six employees alike in the same suit who change desks; three clues
	# come from the thief's cup, and "¿Un cafecito?" shows how each one takes it.
	"office": {
		"shift": "crime_office", "story": "office",
		"brief": ["BRIEF_OFFICE_A_", "BRIEF_OFFICE_B", "BRIEF_OFFICE_C"], "go": "HINT_GO_OFFICE",
		"go_row": "OBJ_OFFICE_GO", "look": "HINT_OFFICE_LOOK", "files_row": "OBJ_OFFICE_FILES",
		"clue_line": "CLUE_OFFICE_", "ruined_hint": "HINT_OFFICE_RUINED_", "left": "HINT_EMPLOYEE_LEFT",
		"who": "employee", "getaway": SuspectCar.WATER_TRUCK, "loot_row": "OBJ_OFFICE_LOOT_",
		"clues": {"prints": "name", "coffee": "coffee", "handle": "left", "footprint": "shoe", "bite": "teeth",
			"witness": "glasses"},
		"parts": ["photo", "prints", "teeth", "coffee"],
	},
	# The station itself (escena-comisaria.md, decision 300): six coworkers in the cops' own uniform; their files take
	# their prints, a bite, a signature, a photo and doña Fritanga's list of sugars. Nobody gets tired: internal affairs
	# comes and takes the case (IA_AT), and half the culprits run off in the station's old patrol car, which loses pieces.
	"station": {
		"shift": "crime_station", "story": "station",
		"brief": ["BRIEF_STATION_A_", "BRIEF_STATION_B", "BRIEF_STATION_C"], "go": "HINT_GO_EVIDENCE",
		"go_row": "OBJ_STATION_GO", "look": "HINT_STATION_LOOK", "files_row": "OBJ_STATION_FILES",
		"clue_line": "CLUE_STATION_", "ruined_hint": "HINT_STATION_RUINED_", "left": "HINT_STAFF_LEFT",
		"who": "staff", "getaway": SuspectCar.OLD_PATROL, "loot_row": "OBJ_STATION_LOOT_", "tire": false,
		"internal_affairs": true,
		"clues": {"prints": "name", "tape": "silhouette", "book": "left", "cup": "sugar", "bite": "teeth",
			"witness": "shoe"},
		"parts": ["prints", "teeth", "sign", "photo", "sugar"],
	},
	# The Municipal Library (escena-biblioteca.md, decision 360): six readers alike in the club's pajamas; a file knows
	# what the cops got from its reader, the gold dust on their hands and the kind of book they read included.
	"library": {
		"shift": "crime_library", "story": "library",
		"brief": ["BRIEF_LIBRARY_A_", "BRIEF_LIBRARY_B", "BRIEF_LIBRARY_C"], "go": "HINT_GO_LIBRARY",
		"go_row": "OBJ_LIBRARY_GO", "look": "HINT_LIBRARY_LOOK", "files_row": "OBJ_LIBRARY_FILES",
		"clue_line": "CLUE_LIBRARY_", "ruined_hint": "HINT_LIBRARY_RUINED_", "left": "HINT_READER_LEFT",
		"who": "reader", "getaway": SuspectCar.BOOKMOBILE, "loot_row": "OBJ_LIBRARY_LOOT_",
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "dust": "dust",
			"bookmark": "genre", "witness": "genre"},
		"parts": ["photo", "prints", "teeth", "hair", "dust", "genre"],
	},
}
## On the train, the traits each part of a magician's file tells.
const MAGICIAN_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"knot": ["left"]}
## At the museum, the traits each part of a guard's file tells.
const GUARD_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"mustache": ["mustache"], "alibi": ["liar", "detail"]}
## At the Monedero mansion, the traits each part of a nephew's file tells.
const NEPHEW_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"scratch": ["scratch"], "tic": ["tic"]}
## At the mansion, the traits each part of a member's file tells.
const MEMBER_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"midnight": ["room"]}
## At the wedding, the traits each part of a tuxedo's file tells.
const TUXEDO_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"cologne": ["cologne"]}
## At the library, the traits each part of a reader's file tells.
const READER_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"], "hair": ["hair"],
	"dust": ["dust"], "genre": ["genre"]}
## At the hotel, the trait each part of a guest's file tells, and the parts that come from their room.
const GUEST_PART_TRAITS := {"prints": "name", "teeth": "teeth", "sign": "left", "shoe": "shoe", "hair": "hair",
	"glasses": "glasses"}
const ROOM_PARTS: Array[String] = ["shoe", "hair", "glasses"]
## At the office, the traits each part of an employee's file tells.
const EMPLOYEE_PART_TRAITS := {"photo": ["glasses", "shoe"], "prints": ["name"], "teeth": ["teeth"],
	"coffee": ["coffee", "left"]}
## At the station, the traits each part of a coworker's file tells.
const STAFF_PART_TRAITS := {"prints": ["name"], "teeth": ["teeth"], "sign": ["left"], "photo": ["silhouette", "shoe"],
	"sugar": ["sugar"]}

## The comisario's verdict at the board: right, or wrong (and whether that lost the case).
signal verdict(right: bool, lost: bool)

var case_seed := 0
## The scene where it happened (null in some tests: then it plays the pastry case without a place).
var place: CrimeScenePlace
var plan: CrimePlan
## The suspects' traits, in the place's order (CookTraits.draw for the cooks).
var cooks: Array[Dictionary] = []
var briefing: CaseBriefing
var checklist: CaseChecklist
var tip_given := false
## A cop got to the tent.
var at_tent := false
var clues_found: Array[String] = []
## The museum's empty frames the patrol car broke in the chase (ChaseFrame), and the library's piles of books it ran
## over (ChaseBooks), each one off the salary.
var frames_broken := 0
## What the cops paid out of their salary during the case (on the train: señor Mostaza's sandwiches).
var spent := 0
## Other fines off the salary (the Monedero mansion's: the comisario's scared calls, the vases).
var fines := 0
## The family's complaint, off the salary too: at the wedding, when the cops call it off (WeddingHall.accused).
var complaint := 0
## Clues the cops spoiled before finding them.
var ruined: Array[String] = []
var flour_print: FlourPrint
## The clues the cops carry and bag (CrimeClueItem), by kind.
var items := {}
## The files whose parts are all done (the pastry's: photo, prints, teeth and hair). A file's id is the cook's index,
## or at the circus the number of the sign on a clown's back.
var files: Array[int] = []
## What each file has so far: id -> {part: bool}, with the variant's parts.
var file_parts := {}
## At the circus, what each file says about whoever gave each part: id -> {trait: value}. A file follows its sign,
## so a sign that changed backs mixes two clowns in one file.
var captured := {}
## At the hotel: what the cops looked at in each room (room: [parts]) and the rooms whose suitcase they opened.
var room_seen := {}
var opened := {}
var accused := false
## At the circus or the museum, the cops found what was stolen.
var loot_found := false
var wrong_guesses := 0
var lost := false
## The station's board (CrimeBoard), where the files show up and the cops accuse.
var board: CrimeBoard
var shift_screen: ShiftScreen
var shift_over := false
## Seconds since the tip, while the case is on.
var elapsed := 0.0
## Indexes of the cooks who went home, in the order they left.
var gone: Array[int] = []
## The culprit, caught, for the next shift's interrogation (decision 93), like the raid's owner.
var custody := {}
## At the station: the comisario warned that internal affairs is coming, and it came (the case is lost).
var ia_warned := false
var ia_arrived := false
## The culprit runs off on his bike (runs_off), and the chase once he did; whether he got away.
var chase: ChaseCase
## Or, at the mansion, the culprit running off on foot through the maze (MazeGetaway).
var runner: MazeGetaway
var escaped := false
## Online (docs/diseno/online.md): the host's case decides and a guest's follows it (CaseSync); `online` is that sync.
var follower := false
var online: CaseSync
## The end of shift numbers, once it's over (sent to the guests).
var _result := {}
var _refresh_left := 0.0


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("crime_scene")
	cooks = _draw_suspects()
	plan = CrimePlan.draw(cooks, case_seed, texts().clues)
	if place:
		place.set_up_case(self)
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind(texts().go))
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(_play_again)
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(briefing_lines())
			break
	checklist.show_rows(rows())


## The texts, the traits and the getaway of the place's variant (the pastry's without a place, as in the tests).
func texts() -> Dictionary:
	return VARIANTS[place.variant if place and VARIANTS.has(place.variant) else "pastry"]


## The suspects' traits for this seed, by variant.
func _draw_suspects() -> Array[Dictionary]:
	if texts() == VARIANTS.museum:
		return GuardTraits.draw(case_seed)
	if texts() == VARIANTS.train:
		return MagicianTraits.draw(case_seed)
	if texts() == VARIANTS.mansion:
		return MemberTraits.draw(case_seed)
	if texts() == VARIANTS.wedding:
		return WeddingTraits.draw(case_seed)
	if texts() == VARIANTS.hotel:
		return GuestTraits.draw(case_seed)
	if texts() == VARIANTS.cat:
		return NephewTraits.draw(case_seed)
	if texts() == VARIANTS.office:
		return OfficeTraits.draw(case_seed)
	if texts() == VARIANTS.station:
		# Their names as the cops read them on the plates.
		var staff := StaffTraits.draw(case_seed)
		for person in staff:
			person.name = tr(person.name)
		return staff
	if texts() == VARIANTS.library:
		return ReaderTraits.draw(case_seed)
	return ClownTraits.draw(case_seed) if texts() == VARIANTS.circus else CookTraits.draw(case_seed)


## One part of a cook's file is done; with the four, his file is.
func file_part(index: int, part: String) -> void:
	if follower:
		return
	var blank := {}
	for name: String in texts().parts:
		blank[name] = false
	var parts: Dictionary = file_parts.get_or_add(index, blank)
	if parts.get(part, true):
		return
	parts[part] = true
	_hint_all(tr("HINT_FILE_" + part) % file_name(index))
	if parts.values().all(func(done: bool) -> bool: return done) and not files.has(index):
		files.append(index)
		_hint_all(tr("HINT_FILE_DONE") % file_name(index))
	if board:
		board.refresh()
	checklist.show_rows(rows())


## A clown gave a part of his file (escena-circo.md): it goes to the file of the sign on his back, with what it says
## about him. Without a sign it goes nowhere. Returns whether it went to a file.
func clown_part(clown_index: int, part: String) -> bool:
	if follower or not place:
		return false
	var id: int = place.sign_of(clown_index)
	if id < 0:
		_hint_all("HINT_CLOWN_NO_SIGN")
		return false
	var trait_name: String = PART_TRAITS[part]
	(captured.get_or_add(id, {}) as Dictionary)[trait_name] = cooks[clown_index][trait_name]
	file_part(id, part)
	return true


## A magician gave a part of his file (escena-tren.md): it goes to the file of the sticker on his cape, with what it
## says about him. Without a sticker it goes nowhere. Returns whether it went to a file.
func magician_part(magician_index: int, part: String) -> bool:
	if follower or not place:
		return false
	var id: int = place.sticker_of(magician_index)
	if id < 0:
		_hint_all("HINT_MAGICIAN_NO_STICKER")
		return false
	var known: Dictionary = captured.get_or_add(id, {})
	for trait_name: String in MAGICIAN_PART_TRAITS[part]:
		known[trait_name] = cooks[magician_index][trait_name]
	file_part(id, part)
	return true


## A guard gave a part of his file (escena-museo.md), a nephew (escena-gato.md), a club member (escena-mansion.md), a
## tuxedo (escena-boda.md) or a reader (escena-biblioteca.md): it goes to their file with what it says about them.
func guard_part(index: int, part: String) -> void:
	if follower:
		return
	var known: Dictionary = captured.get_or_add(index, {})
	var table := GUARD_PART_TRAITS
	if texts() == VARIANTS.cat:
		table = NEPHEW_PART_TRAITS
	elif texts() == VARIANTS.mansion:
		table = MEMBER_PART_TRAITS
	elif texts() == VARIANTS.wedding:
		table = TUXEDO_PART_TRAITS
	elif texts() == VARIANTS.library:
		table = READER_PART_TRAITS
	for trait_name: String in table[part]:
		known[trait_name] = cooks[index][trait_name]
	file_part(index, part)


## An employee gave a part of his file (escena-oficina.md): his photo, prints, teeth, or his coffee as a cop saw it.
func employee_part(index: int, part: String) -> void:
	if follower:
		return
	var known: Dictionary = captured.get_or_add(index, {})
	for trait_name: String in EMPLOYEE_PART_TRAITS[part]:
		known[trait_name] = cooks[index][trait_name]
	file_part(index, part)


## A coworker gave a part of their file (escena-comisaria.md): it goes to their file with what it says about them.
func staff_part(index: int, part: String) -> void:
	if follower:
		return
	var known: Dictionary = captured.get_or_add(index, {})
	for trait_name: String in STAFF_PART_TRAITS[part]:
		known[trait_name] = cooks[index][trait_name]
	file_part(index, part)


## A guest gave a part of their file themselves (escena-hotel.md): their prints, their teeth or their signature.
func guest_part(index: int, part: String) -> void:
	if follower:
		return
	(captured.get_or_add(index, {}) as Dictionary)[GUEST_PART_TRAITS[part]] = cooks[index][GUEST_PART_TRAITS[part]]
	file_part(index, part)


## The room a guest's file says they sleep in: the one whose suitcase says so, or else the one the concierge said
## (0 if a suitcase showed that room is someone else's).
func guest_room(index: int) -> int:
	for room: int in opened:
		if GuestTraits.sleeper(cooks, room) == index:
			return room
	var said: int = cooks[index].said
	return 0 if opened.has(said) else said


## Whose file a room's things go to: the sleeper's if its suitcase was opened, or else whom the concierge said.
func room_file(room: int) -> int:
	for i in cooks.size():
		if guest_room(i) == room:
			return i
	return -1


## A cop looked at a thing in a room (RoomThing): it goes to the file of whoever the file says sleeps there, with
## what it says about whoever really does.
func room_part(room: int, part: String) -> void:
	if follower:
		return
	var seen: Array = room_seen.get_or_add(room, [])
	if not seen.has(part):
		seen.append(part)
	var index := room_file(room)
	if index >= 0:
		_hint_all(tr("HINT_FILE_" + part) % file_name(index))
	_refresh_rooms()


## A cop opened a room's suitcase: its tag says whose room it is, and the files take it.
func open_suitcase(room: int) -> void:
	if follower or opened.has(room):
		return
	var said := room_file(room)
	opened[room] = true
	var sleeper := GuestTraits.sleeper(cooks, room)
	_hint_all(tr("HINT_SUITCASE_LIE" if said != sleeper else "HINT_SUITCASE") % [room, file_name(sleeper)])
	_refresh_rooms()


## The room parts of every guest's file, again from what was seen and whose room each one is now.
func _refresh_rooms() -> void:
	for i in cooks.size():
		var room := guest_room(i)
		var seen: Array = room_seen.get(room, [])
		if not file_parts.has(i) and seen.is_empty():
			continue
		var blank := {}
		for name: String in texts().parts:
			blank[name] = false
		var parts: Dictionary = file_parts.get_or_add(i, blank)
		for part in ROOM_PARTS:
			parts[part] = seen.has(part)
		var done := parts.values().all(func(part_done: bool) -> bool: return part_done)
		if done and not files.has(i):
			files.append(i)
			_hint_all(tr("HINT_FILE_DONE") % file_name(i))
		elif not done:
			files.erase(i)
	if board:
		board.refresh()
	checklist.show_rows(rows())


## What a file says about each trait: the cook's own traits, or at the circus what the cops got from whoever wore its
## sign, or at the museum and the wedding what they got from the suspect, or at the hotel that and what their room's
## things say.
func file_traits(id: int) -> Dictionary:
	if texts() == VARIANTS.hotel:
		var known: Dictionary = captured.get(id, {}).duplicate()
		var room := guest_room(id)
		var sleeper := GuestTraits.sleeper(cooks, room)
		for part: String in room_seen.get(room, []):
			known[GUEST_PART_TRAITS[part]] = cooks[sleeper][GUEST_PART_TRAITS[part]]
		return known
	if texts() in [VARIANTS.circus, VARIANTS.museum, VARIANTS.train, VARIANTS.cat, VARIANTS.mansion, VARIANTS.office,
			VARIANTS.wedding, VARIANTS.station, VARIANTS.library]:
		return captured.get(id, {})
	return cooks[id]


## A file's title: the cook's name, or the number of the clown's sign.
func file_name(id: int) -> String:
	if texts() == VARIANTS.circus:
		return tr("FILE_SIGN") % (id + 1)
	if texts() == VARIANTS.train:
		return tr("FILE_STICKER") % (id + 1)
	return cooks[id].name


## Who a file's accusation points at: the cook, or the clown wearing its sign now (or the last one who did).
func accused_index(id: int) -> int:
	if (texts() == VARIANTS.circus or texts() == VARIANTS.train) and place:
		return place.wearer(id)
	return id


## The cops accused a file at the board; the comisario looks.
func accuse(id: int) -> void:
	if accused or lost or follower:
		return
	if accused_index(id) == plan.culprit:
		accused = true
		_comisario_says("BOARD_RIGHT")
	else:
		wrong_guesses += 1
		lost = wrong_guesses >= MAX_WRONG
		_comisario_says("BOARD_WRONG_LOST" if lost else "BOARD_WRONG")
	if place:
		place.accused(accused_index(id), accused)
	checklist.show_rows(rows())
	verdict.emit(accused, lost)
	if accused and runs_off() and _run_off():
		return
	if accused:
		_take_culprit()
	if accused or lost:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The train got to the last station with nobody rightly accused (escena-tren.md): the culprit gets off among the
## crowd and the case is lost.
func end_of_line() -> void:
	if accused or lost or follower:
		return
	lost = true
	_comisario_says("TRAIN_CULPRIT_GOT_OFF")
	checklist.show_rows(rows())
	verdict.emit(false, true)
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Whether this case's culprit runs off when accused, from the seed. One who already went home can't.
func runs_off() -> bool:
	return hash(["crime runs", case_seed]) % RUNS_EVERY == 0 and not gone.has(plan.culprit)


## The culprit gets in his getaway by the scene (the pastry cook's delivery bike) and the chase starts (decision 96).
## Returns false when the level has no place, city or patrol car to chase him with (he gives up instead). A place with
## a foot_getaway (the mansion's maze) runs him off on foot there instead.
func _run_off() -> bool:
	if place and place.has_method("foot_getaway"):
		runner = place.foot_getaway(plan.culprit)
		runner.follower = follower
		runner.ended.connect(_on_chase_ended)
		_hint_all(tr("HINT_ESCAPE_" + texts().who) % culprit().name)
		return true
	if place and place.run_off(plan.culprit):
		_hint_all(tr("HINT_ESCAPE_" + texts().who) % culprit().name)
		return true
	var level := get_parent()
	var city := level.get_node_or_null("City") as Node3D
	var car := level.get_node_or_null("PatrolCar") as PatrolCar
	if not place or not city or not car:
		return false
	_send_off(place.suspect(plan.culprit))
	var getaway := place.getaway(plan.culprit, city)
	chase = ChaseCase.begin(level, texts().getaway, getaway.at, car, city, case_seed)
	chase.who = texts().who
	chase.online = online
	chase.follower = follower
	var via: Array = getaway.via
	for i in via.size():
		chase.truck.points.insert(1 + i, via[i])
	chase.ended.connect(_on_chase_ended)
	place.dress_getaway(chase)
	_hint_all(tr("HINT_ESCAPE_" + texts().who) % culprit().name)
	return true


## A getaway the place ran (Train.run_off) ended.
func end_chase(caught: bool) -> void:
	_on_chase_ended(caught)


## Caught and in the patrol car, he's in custody for the next interrogation; got away, the case is lost.
func _on_chase_ended(caught: bool) -> void:
	escaped = not caught
	if caught:
		custody = _custody()
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Accused, the culprit gives up and goes to a cell: next shift is his interrogation. One who already went home is
## picked up there.
func _take_culprit() -> void:
	custody = _custody()
	_hint_all(tr("HINT_CULPRIT_GIVES_UP") % culprit().name)
	if place and not gone.has(plan.culprit):
		_send_off(place.suspect(plan.culprit))


## The culprit in custody, for the next shift's interrogation.
func _custody() -> Dictionary:
	return {"owner": texts().who, "story": texts().story, "slips": [], "missed": 0}


## Solved: the right cook accused and, if he ran off, caught.
func solved() -> bool:
	return accused and not escaped


## The end of shift screen: the salary if solved, halved by a wrong accusation (ShiftReport). A campaign moves on.
func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(solved(), [LOOT_BONUS] if loot_found else [], frames_broken * FRAME_FINE + spent + fines
		+ complaint, wrong_guesses)
	var result := {"solved": solved(), "report": report, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.add_stats(stats)
		campaign.finish_shift(texts().shift, solved(), report, QUOTA)
		campaign.custody = custody
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	else:
		PlaceDraw.custody = custody
	_show_result(result)


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	if not shift_screen:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, 0, awards)
	var over := false
	if result.has("campaign"):
		shift_screen.show_campaign(result.campaign.shift, Campaign.SHIFTS, result.campaign.money, result.campaign.over,
			result.campaign.promoted)
		over = result.campaign.over
	# Online only the host starts the next case.
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## What every guest's case shows (CaseSync, 5 times a second when it changes).
func snapshot() -> Dictionary:
	# Copies: CaseSync keeps the last one sent to see what changed, and these change in place.
	var state := {"tip": tip_given, "at_tent": at_tent, "found": clues_found.duplicate(), "ruined": ruined.duplicate(),
		"parts": file_parts.duplicate(true), "files": files.duplicate(), "accused": accused, "wrong": wrong_guesses,
		"lost": lost, "gone": gone.duplicate(), "escaped": escaped, "loot": loot_found,
		"offended": place != null and place.witness_offended(), "result": _result, "captured": captured.duplicate(true),
		"frames": frames_broken, "spent": spent, "fines": fines, "complaint": complaint,
		"rooms": room_seen.duplicate(true), "opened": opened.duplicate()}
	# What only the place knows (the circus: the trick, the signs, the camera).
	if place:
		state.place = place.net_state()
	# The culprit who ran off on his bike, and the chase after him.
	if chase:
		state.chase = chase.snapshot()
	# Or the one who ran off on foot (the mansion's maze).
	if runner:
		state.runner = runner.snapshot()
	return state


## A guest's case takes the host's: the planilla, the board's files, who went home, the verdict and the end of shift.
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	at_tent = state.at_tent
	clues_found.assign(state.found)
	frames_broken = state.get("frames", 0)
	spent = state.get("spent", 0)
	fines = state.get("fines", 0)
	complaint = state.get("complaint", 0)
	ruined.assign(state.ruined)
	file_parts = state.parts.duplicate(true)
	files.assign(state.files)
	captured = state.get("captured", {}).duplicate(true)
	room_seen = state.get("rooms", {}).duplicate(true)
	opened = state.get("opened", {}).duplicate()
	if place and state.has("place"):
		place.apply_net_state(state.place)
	# The comisario's verdict at the board, said here too.
	if state.wrong > wrong_guesses:
		_comisario_says("BOARD_WRONG_LOST" if state.lost else "BOARD_WRONG")
	elif state.accused and not accused:
		_comisario_says("BOARD_RIGHT")
	wrong_guesses = state.wrong
	lost = state.lost
	escaped = state.escaped
	for index: int in state.gone:
		if not gone.has(index):
			gone.append(index)
			if place:
				_send_off(place.suspect(index))
	if place and state.get("loot", false) and texts().has("loot_row") and not place.loot_found:
		place.reveal_loot()
	if place and state.offended and not place.witness_offended():
		place.offend_witness()
	if state.accused and not accused:
		accused = true
		if state.has("chase") or state.has("runner"):
			_run_off()
		elif place and runs_off() and place.run_off(plan.culprit):
			# The place runs his getaway itself (the train's roofs) and follows the host's.
			pass
		elif place and not gone.has(plan.culprit):
			_send_off(place.suspect(plan.culprit))
	if chase and state.has("chase"):
		chase.apply_snapshot(state.chase)
	if runner and state.has("runner"):
		runner.apply_snapshot(state.runner)
	if board:
		board.refresh()
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## One more cook is tired and goes home; his file stays as it is. They leave in an order drawn with the seed.
func _tire() -> void:
	if follower:
		return
	var order := range(cooks.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("cooks leave %d" % case_seed)
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for index: int in order:
		if not gone.has(index) and not (place and place.stays(index)):
			gone.append(index)
			_hint_all(tr(texts().left) % cooks[index].name)
			if place:
				_send_off(place.suspect(index))
			checklist.show_rows(rows())
			return


## A suspect leaves the scene: out of sight and out of the way.
func _send_off(suspect: CollisionObject3D) -> void:
	suspect.hide()
	suspect.collision_layer = 0
	suspect.process_mode = Node.PROCESS_MODE_DISABLED


## The comisario says `key` to the cops: on the briefing screen, or as a hint (the Monedero mansion's scared calls).
func comisario_says(key: String) -> void:
	_comisario_says(key)


## A hint for every cop (the Monedero mansion's broken vases).
func hint_all(key: String) -> void:
	_hint_all(key)


## The comisario comes to the board and says it (with a player at the keys).
func _comisario_says(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray([key]))
			return
	_hint_all(key)


## The patrol car broke one of the frames the museum's art van dropped.
func frame_broken() -> void:
	if follower:
		return
	frames_broken += 1
	_hint_all("HINT_FRAME_BROKEN")


## The patrol car ran over a pile of books the library's bookmobile dropped: the library's fine, the same as a
## museum frame (counted with them).
func book_pile_ruined() -> void:
	if follower:
		return
	frames_broken += 1
	_hint_all("HINT_BOOKS_RUINED")


## The cops found one of the case's clues. Returns whether it's new.
func found(kind: String) -> bool:
	if follower:
		return false
	if not plan.clues.has(kind) or clues_found.has(kind) or ruined.has(kind):
		return false
	clues_found.append(kind)
	_hint_all("HINT_CRIME_CLUE")
	checklist.show_rows(rows())
	return true


## The cops spoiled one of the case's clues before finding it.
func ruin(kind: String) -> void:
	if follower:
		return
	if not plan.clues.has(kind) or clues_found.has(kind) or ruined.has(kind):
		return
	ruined.append(kind)
	_hint_all(texts().ruined_hint + kind)
	checklist.show_rows(rows())


## A clue's line on the planilla: what it says about the culprit.
func clue_line(kind: String) -> String:
	if texts() == VARIANTS.circus:
		return _circus_clue_line(kind)
	if texts() == VARIANTS.museum:
		return _museum_clue_line(kind)
	if texts() == VARIANTS.train:
		return _train_clue_line(kind)
	if texts() == VARIANTS.mansion:
		return _mansion_clue_line(kind)
	if texts() == VARIANTS.wedding:
		return _wedding_clue_line(kind)
	if texts() == VARIANTS.hotel:
		return _hotel_clue_line(kind)
	if texts() == VARIANTS.cat:
		return _cat_clue_line(kind)
	if texts() == VARIANTS.office:
		return _office_clue_line(kind)
	if texts() == VARIANTS.station:
		return _station_clue_line(kind)
	if texts() == VARIANTS.library:
		return _library_clue_line(kind)
	match kind:
		"footprint":
			return tr("CLUE_CRIME_footprint") % culprit().shoe
		"witness":
			return tr("CLUE_CRIME_witness") % tr("APRON_" + str(culprit().apron))
		"hair":
			return tr("CLUE_CRIME_hair") % tr("HAIR_" + str(culprit().hair))
		"bite":
			return tr("CLUE_CRIME_bite") % tr("TEETH_" + str(culprit().teeth))
		"recipe":
			return tr("CLUE_CRIME_recipe_left" if culprit().left else "CLUE_CRIME_recipe_right")
	return tr("CLUE_CRIME_" + kind)


## At the Monedero mansion: the footprint in the litter tray, the hair on the armchair, the bitten biscuit, the blood
## on the necklace's clasp and what the parrot repeats.
func _cat_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_CAT_footprint") % who.shoe
		"hair":
			return tr("CLUE_CAT_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_CAT_bite") % tr("TEETH_" + str(who.teeth))
		"necklace":
			return tr("CLUE_CAT_necklace_" + str(who.scratch))
		"witness":
			return tr("CLUE_CAT_witness") % tr("NEPHEW_TIC_%d" % who.tic)
	return tr("CLUE_CAT_" + kind)


## At the circus: the sawdust footprint, the hair in the pool, the bitten fish, the rehearsal's honk and Zulema.
func _circus_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_CIRCUS_footprint") % who.shoe
		"witness":
			return tr("CLUE_CIRCUS_witness_glasses" if who.glasses else "CLUE_CIRCUS_witness_no_glasses")
		"hair":
			return tr("CLUE_CIRCUS_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_CIRCUS_bite") % tr("TEETH_" + str(who.teeth))
		"recording":
			return tr("CLUE_CIRCUS_recording") % tr("HONK_" + str(who.honk))
	return tr("CLUE_CIRCUS_" + kind)


## At the wedding: the footprint in the rice, the hair in the frosting, the bite out of the cake, the video and grandma
## Chola.
func _wedding_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_CRIME_WEDDING_footprint") % who.shoe
		"hair":
			return tr("CLUE_CRIME_WEDDING_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_CRIME_WEDDING_bite") % tr("TEETH_" + str(who.teeth))
		"recording":
			return tr("CLUE_CRIME_WEDDING_recording_glasses" if who.glasses else "CLUE_CRIME_WEDDING_recording_no_glasses")
		"witness":
			return tr("CLUE_CRIME_WEDDING_witness") % tr("COLOGNE_" + str(who.cologne))
	return tr("CLUE_CRIME_WEDDING_" + kind)


## At the museum: the footprint on the waxed floor, the hair on the rope, the bitten sandwich, the recording, the
## statue and the bathroom as it was.
func _museum_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_MUSEUM_footprint") % who.shoe
		"hair":
			return tr("CLUE_MUSEUM_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_MUSEUM_bite") % tr("TEETH_" + str(who.teeth))
		"recording":
			return tr("CLUE_MUSEUM_recording_" + ("real" if who.mustache else "fake"))
		"witness":
			return tr("CLUE_MUSEUM_witness_glasses" if who.glasses else "CLUE_MUSEUM_witness_no_glasses")
		"alibi":
			var museum := place as Museum
			return tr("CLUE_MUSEUM_alibi") % museum.bathroom_details.map(func(detail: String) -> String:
				return tr("ALIBI_SHORT_" + detail))
	return tr("CLUE_MUSEUM_" + kind)


## On the train: the soot footprint, the hair on the broken window's sill, the bitten sandwich, Picadora and the knot.
func _train_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_TRAIN_footprint") % who.shoe
		"hair":
			return tr("CLUE_TRAIN_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_TRAIN_bite") % tr("TEETH_" + str(who.teeth))
		"witness":
			return tr("CLUE_TRAIN_witness_glasses" if who.glasses else "CLUE_TRAIN_witness_no_glasses")
		"knot":
			return tr("CLUE_TRAIN_knot_left" if who.left else "CLUE_TRAIN_knot_right")
	return tr("CLUE_TRAIN_" + kind)


## Money off the salary for something bought during the case.
func spend(amount: int) -> void:
	spent += amount


## At the mansion: the prints on the safe, the footprint in a passage's dust, the hair on the armour, the bitten
## chocolate, the bell that rang at midnight and Lorenzo.
func _mansion_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_MANSION_footprint") % who.shoe
		"hair":
			return tr("CLUE_MANSION_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_MANSION_bite") % tr("TEETH_" + str(who.teeth))
		"bells":
			return tr("CLUE_MANSION_bells") % tr("MANSION_ROOM_" + str(who.room))
		"witness":
			return tr("CLUE_MANSION_witness_glasses" if who.glasses else "CLUE_MANSION_witness_no_glasses")
	return tr("CLUE_MANSION_" + kind)


## At the library: the slipper on the waxed parquet, the hair on the armchair, the cookie in the hollow book, the gold
## dust, the bookmark in the Golden Book and Tomasito.
func _library_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_LIBRARY_footprint") % who.shoe
		"hair":
			return tr("CLUE_LIBRARY_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_LIBRARY_bite") % tr("TEETH_" + str(who.teeth))
		"bookmark", "witness":
			return tr("CLUE_LIBRARY_" + kind) % tr("GENRE_" + str(who.genre))
	return tr("CLUE_LIBRARY_" + kind)


## At the hotel: the bare footprint on the bathroom's mat, the hair and the bonbon on the pillow, Tito and the guest book.
func _hotel_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"footprint":
			return tr("CLUE_HOTEL_footprint") % who.shoe
		"hair":
			return tr("CLUE_HOTEL_hair") % tr("HAIR_" + str(who.hair))
		"bite":
			return tr("CLUE_HOTEL_bite") % tr("TEETH_" + str(who.teeth))
		"witness":
			return tr("CLUE_HOTEL_witness_glasses" if who.glasses else "CLUE_HOTEL_witness_no_glasses")
		"signature":
			return tr("CLUE_HOTEL_signature_left" if who.left else "CLUE_HOTEL_signature_right")
	return tr("CLUE_HOTEL_" + kind)


## At the office: the cup's prints, coffee and handle, the coffee footprint, the bitten cookie and Benja.
func _office_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"coffee":
			return tr("CLUE_OFFICE_coffee") % tr("COFFEE_" + str(who.coffee))
		"handle":
			return tr("CLUE_OFFICE_handle_left" if who.left else "CLUE_OFFICE_handle_right")
		"footprint":
			return tr("CLUE_OFFICE_footprint") % who.shoe
		"bite":
			return tr("CLUE_OFFICE_bite") % tr("TEETH_" + str(who.teeth))
		"witness":
			return tr("CLUE_OFFICE_witness_glasses" if who.glasses else "CLUE_OFFICE_witness_no_glasses")
	return tr("CLUE_OFFICE_" + kind)


## At the station: the shelf's prints, the camera's tape, the sign-out book, the coffee cup, the bitten donut and el
## Chancho.
func _station_clue_line(kind: String) -> String:
	var who := culprit()
	match kind:
		"tape":
			return tr("CLUE_STATION_tape") % tr("SILHOUETTE_" + (who.silhouette as String).replace(" ", "_"))
		"book":
			return tr("CLUE_STATION_book_left" if who.left else "CLUE_STATION_book_right")
		"cup":
			return tr("CLUE_STATION_cup") % who.sugar
		"bite":
			return tr("CLUE_STATION_bite") % tr("TEETH_" + str(who.teeth))
		"witness":
			return tr("CLUE_STATION_witness") % who.shoe
	return tr("CLUE_STATION_" + kind)


## What a file card on the board says: what the photo shows, and the rest as the cops got it.
func file_text(index: int) -> String:
	var who := file_traits(index)
	var parts: Dictionary = file_parts[index]
	if texts() == VARIANTS.circus:
		var lines := PackedStringArray([file_name(index)])
		if who.has("glasses"):
			lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		else:
			lines.append(tr("FILE_GLASSES_UNKNOWN"))
		lines.append(tr("FILE_SHOE") % who.shoe if who.has("shoe") else tr("FILE_SHOE_UNKNOWN"))
		lines.append(tr("FILE_HONK") % (tr("HONK_" + str(who.honk)) if who.has("honk") else "?"))
		lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
		lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
		lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
		return "\n".join(lines)
	if texts() == VARIANTS.museum:
		return _guard_file_text(index, who)
	if texts() == VARIANTS.train:
		return _magician_file_text(index, who)
	if texts() == VARIANTS.mansion:
		return _member_file_text(index, who)
	if texts() == VARIANTS.wedding:
		return _tuxedo_file_text(index, who)
	if texts() == VARIANTS.hotel:
		return _guest_file_text(index, who)
	if texts() == VARIANTS.cat:
		return _nephew_file_text(index, who)
	if texts() == VARIANTS.office:
		return _employee_file_text(index, who)
	if texts() == VARIANTS.station:
		return _staff_file_text(index, who)
	if texts() == VARIANTS.library:
		return _reader_file_text(index, who)
	var lines := PackedStringArray(["%d. %s" % [index + 1, who.name]])
	lines.append(tr("FILE_APRON") % tr("APRON_" + str(who.apron)))
	lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
	lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	lines.append(tr("FILE_SHOE") % who.shoe)
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if parts.hair else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if parts.teeth else "?"))
	lines.append(tr("FILE_PRINTS") if parts.prints else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## A magician's file: its sticker's number and what the cops got from whoever wore it.
func _magician_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray([file_name(index)])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("left"):
		lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	else:
		lines.append(tr("FILE_KNOT_UNKNOWN"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## A nephew's file: his name and number, and what the cops got from him so far.
func _nephew_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	lines.append(tr("FILE_SCRATCH_" + (str(who.scratch).to_upper() if who.scratch != "" else "NONE")) if who.has("scratch")
		else tr("FILE_SCRATCH_UNKNOWN"))
	lines.append(tr("FILE_TIC") % (tr("NEPHEW_TIC_%d" % who.tic) if who.has("tic") else "?"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)



## A club member's file: their name and number, and what the cops got from them so far.
func _member_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	lines.append(tr("FILE_MIDNIGHT") % (tr("MANSION_ROOM_" + str(who.room)) if who.has("room") else "?"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)



## A reader's file: their name and number, and what the cops got from them so far.
func _reader_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SLIPPER") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("dust"):
		lines.append(tr("FILE_DUST") if who.dust else tr("FILE_NO_DUST"))
	else:
		lines.append(tr("FILE_DUST_UNKNOWN"))
	lines.append(tr("FILE_GENRE") % (tr("GENRE_" + str(who.genre)) if who.has("genre") else "?"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)



## A guard's file: his name and number, and what the cops got from him so far.
func _guard_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("mustache"):
		lines.append(tr("FILE_MUSTACHE_REAL") if who.mustache else tr("FILE_MUSTACHE_FAKE"))
	else:
		lines.append(tr("FILE_MUSTACHE_UNKNOWN"))
	lines.append(tr("FILE_ALIBI") % (tr("ALIBI_SHORT_" + str(who.detail)) if who.has("detail") else "?"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## A tuxedo's file: his name and number, and what the cops got from him so far.
func _tuxedo_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	lines.append(tr("FILE_COLOGNE") % (tr("COLOGNE_" + str(who.cologne)) if who.has("cologne") else "?"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## A guest's file: name, the room the file says (and whether only the concierge said it), and what the cops got.
func _guest_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	var room := guest_room(index)
	if room == 0:
		lines.append(tr("FILE_ROOM") % "?")
	else:
		lines.append(tr("FILE_ROOM" if opened.has(room) else "FILE_ROOM_SAID") % room)
	lines.append(tr("FILE_SHOE") % who.shoe if who.has("shoe") else tr("FILE_SHOE_UNKNOWN"))
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
	else:
		lines.append(tr("FILE_GLASSES_UNSEEN"))
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("left"):
		lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	else:
		lines.append(tr("FILE_HAND_UNKNOWN"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## An employee's file: the name on his badge and what the cops got from him so far.
func _employee_file_text(index: int, who: Dictionary) -> String:
	var lines := PackedStringArray(["%d. %s" % [index + 1, cooks[index].name]])
	if who.has("glasses"):
		lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_GLASSES_UNKNOWN"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("coffee"):
		lines.append(tr("FILE_COFFEE") % tr("COFFEE_" + str(who.coffee)))
		lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	else:
		lines.append(tr("FILE_COFFEE") % "?")
		lines.append(tr("FILE_HAND_NO_COFFEE"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## A coworker's file: name and what the cops got: the photo (height, limp and shoes), the sugar, the teeth, the hand
## and the prints, and where and with whom they say they were.
func _staff_file_text(index: int, who: Dictionary) -> String:
	var person := cooks[index]
	var lines := PackedStringArray(["%d. %s" % [index + 1, person.name]])
	if who.has("silhouette"):
		lines.append(tr("SILHOUETTE_" + (who.silhouette as String).replace(" ", "_")))
		lines.append(tr("FILE_SHOE") % who.shoe)
	else:
		lines.append(tr("FILE_PHOTO_UNKNOWN"))
	lines.append(tr("FILE_SUGAR") % (str(who.sugar) if who.has("sugar") else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
	if who.has("left"):
		lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	else:
		lines.append(tr("FILE_HAND_UNKNOWN"))
	lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
	lines.append(tr("FILE_STAFF_ALIBI") % [tr("STAFF_PLACE_" + (person.where as String).to_upper()),
		tr("STAFF_WITH_" + StaffTraits.IDS[person.with].to_upper())])
	return "\n".join(lines)


## The concierge's list of who sleeps where, as he says it (two swapped).
func concierge_list() -> String:
	var said := PackedStringArray()
	for room: int in Hotel.GUEST_ROOMS:
		for guest in cooks:
			if guest.said == room:
				said.append("%d: %s" % [room, guest.name])
	return tr("HOTEL_CONCIERGE_ROOMS") % ", ".join(said)


## The comisario's briefing: at the circus and the museum, the first line says what was stolen (the place drew it).
func briefing_lines() -> PackedStringArray:
	var lines := PackedStringArray(texts().brief)
	if texts().has("loot_row"):
		lines[0] += place.loot
	return lines


## At the circus or the museum, the cops found what was stolen (the place's search).
func found_loot() -> void:
	if loot_found:
		return
	loot_found = true
	_hint_all("HINT_LOOT_FOUND_" + (place.loot as String))
	checklist.show_rows(rows())


## A cop shouted (VoiceChat): the place's witness may take offense.
func shouted_by(cop: Cop) -> void:
	if follower:
		if online:
			online.request_shout()
		return
	if place:
		place.shouted_by(cop)


## The culprit's traits.
func culprit() -> Dictionary:
	return cooks[plan.culprit]


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row(texts().go_row, at_tent))
	list.append(_row(tr("OBJ_CRIME_CLUES") % [clues_found.size(), plan.clues.size()],
		clues_found.size() + ruined.size() >= plan.clues.size()))
	for kind in clues_found:
		list.append({"text": "- " + clue_line(kind), "done": false, "optional": false, "status": true, "clue": true})
	for kind in ruined:
		list.append({"text": "- " + tr(texts().clue_line + "RUINED_" + kind), "done": false, "optional": false, "status": true})
	list.append(_row(tr(texts().files_row) % [files.size(), cooks.size()], files.size() >= cooks.size()))
	for index: int in file_parts:
		if not files.has(index):
			list.append({"text": "- " + _missing(index), "done": false, "optional": false, "status": true})
	list.append(_row("OBJ_CRIME_ACCUSE", accused))
	if texts().get("internal_affairs", false) and not accused:
		var left := maxi(int(ia_arrival() - elapsed), 0)
		list.append({"text": tr("OBJ_IA_CLOCK") % [left / 60, left % 60] if not ia_arrived else "OBJ_IA_ARRIVED",
			"done": false, "optional": false, "status": true})
	if texts().has("loot_row") and place:
		list.append({"text": texts().loot_row + (place.loot as String), "done": loot_found, "optional": true,
			"status": false})
	if chase:
		list.append(_row("OBJ_CRIME_CATCH", chase.case_solved))
	elif runner:
		list.append(_row(texts().catch_row, runner.caught))
	if not gone.is_empty():
		var names := gone.map(func(index: int) -> String: return cooks[index].name)
		list.append({"text": tr("OBJ_CRIME_GONE") % ", ".join(names), "done": false, "optional": false, "status": true})
	if wrong_guesses > 0:
		list.append({"text": tr("OBJ_CRIME_WRONG") % [wrong_guesses, MAX_WRONG], "done": false, "optional": false,
			"status": true})
	if complaint > 0:
		list.append({"text": tr("OBJ_CRIME_COMPLAINT") % complaint, "done": false, "optional": false, "status": true})
	list.append({"text": "OBJ_CRIME_CAREFUL", "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if not tip_given or not place:
		return
	if not accused and not lost:
		elapsed += delta
		if texts().get("tire", true) and gone.size() < cooks.size() and elapsed >= LEAVE_FROM + gone.size() * LEAVE_EVERY:
			_tire()
		if texts().get("internal_affairs", false) and not follower:
			_internal_affairs()
	if not at_tent and not follower:
		for cop in get_tree().get_nodes_in_group("cops"):
			if place.at_scene((cop as Node3D).global_position):
				at_tent = true
				_hint_all(texts().look)
				checklist.show_rows(rows())
				break
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


## When internal affairs gets to the station, in seconds after the tip.
func ia_arrival() -> float:
	return IA_INVESTIGATING if InternalAffairsAgent.investigating() else IA_AT


## The comisario's warning on the radio, and then internal affairs at the door: it takes the case, which is lost.
func _internal_affairs() -> void:
	var at := ia_arrival()
	if not ia_warned and elapsed >= at - IA_WARN:
		ia_warned = true
		_hint_all("HINT_IA_SOON")
	if ia_arrived or elapsed < at:
		return
	ia_arrived = true
	lost = true
	_hint_all("HINT_IA_ARRIVED")
	if place and place.has_method("ia_arrives"):
		place.ia_arrives()
	checklist.show_rows(rows())
	verdict.emit(false, true)
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## "Clara: falta foto, dientes", for a file begun but not done.
func _missing(index: int) -> String:
	var parts: Dictionary = file_parts[index]
	var missing: PackedStringArray = []
	for part: String in parts:
		if not parts[part]:
			missing.append(tr("FILE_PART_" + part))
	return tr("OBJ_FILE_MISSING") % [file_name(index), ", ".join(missing)]


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
