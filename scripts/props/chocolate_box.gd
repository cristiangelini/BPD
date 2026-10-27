class_name ChocolateBox
extends DonutBox

## Doña Clotilde's box of chocolates on the mansion's dining table (escena-mansion.md, step 4): a DonutBox with eight
## chocolates. A cop can eat one too; held in front of a club member, they bite one (their teeth for the file).


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CHOCOLATE_BOX" if donuts > 0 else "PROMPT_CHOCOLATE_EMPTY"
