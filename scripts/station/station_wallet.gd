class_name StationWallet
extends RefCounted

## The common cash box and what the station bought when there is no campaign (Campaign.current) to keep them between
## shifts (docs/diseno/guardado.md). Same fields as Campaign, so the armory takes either.

var money := 0
var items: Array[String] = []
