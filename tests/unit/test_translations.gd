extends GutTest

## Every game text needs Spanish, English and Portuguese (decision 43).

const CSV_PATH := "res://translations/texts.csv"
const LOCALES: Array[String] = ["es", "en", "pt"]


func _rows() -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	assert_not_null(file, "texts.csv should exist")
	while file and not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() > 1:
			rows.append(row)
	return rows


func test_header_has_every_locale() -> void:
	var header := _rows()[0]
	assert_eq(header[0], "keys")
	for locale in LOCALES:
		assert_has(header, locale, "missing column %s" % locale)


func test_every_key_is_translated() -> void:
	var rows := _rows()
	var header := rows[0]
	for i in range(1, rows.size()):
		var row := rows[i]
		assert_eq(row.size(), header.size(), "%s has the wrong number of columns" % row[0])
		for col in range(1, row.size()):
			assert_ne(row[col].strip_edges(), "", "%s has no %s text" % [row[0], header[col]])


func test_keys_are_unique() -> void:
	var seen := {}
	for row in _rows().slice(1):
		assert_false(seen.has(row[0]), "duplicated key %s" % row[0])
		seen[row[0]] = true


func test_translation_server_uses_the_csv() -> void:
	TranslationServer.set_locale("en")
	assert_eq(tr("MENU_PLAY"), "Play")
	TranslationServer.set_locale("es")
	assert_eq(tr("MENU_PLAY"), "Jugar")
