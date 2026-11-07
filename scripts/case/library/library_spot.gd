class_name LibrarySpot
extends LootSpot

## Where the Golden Book could be hidden at the library (escena-biblioteca.md): one of the eight sections of the stacks
## ("section_A" to "section_H"), the returns cart ("cart") or the big cushion's cover ("cushion"). E searches it, which
## takes a while (Library.search).


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LIBRARY_SEARCH_" + ("shelf" if spot.begins_with("section_") else spot)
