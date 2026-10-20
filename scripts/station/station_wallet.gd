class_name StationWallet
extends RefCounted

## The common cash box and what the station bought, until the campaign (docs/diseno/guardado.md) keeps them between
## shifts. Same fields as Campaign, so the armory takes either.

var money := 0
var items: Array[String] = []
