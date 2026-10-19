# Changelog

## 0.1.0 (unreleased)
- Project base: Godot 4.7.2 project, placeholder main menu, translations (es, en, pt), GUT tests and CI.
- First person cop (walk, run with stamina, crouch, jump) in a grey test room; Play opens it.
- Grab, carry together and throw physics props; crates (3 kg) and a safe (40 kg, needs two cops) in the grey room.
- Low poly placeholder look: procedural cops, crate and safe from tools/modelgen; colored test room with sky and shadows.
- Pear body for every character: four cops in blue with player skin colors, and ten NPC models (comisario, abuelo, sospechoso, vecina, periodista, asuntos internos, carcelero, preso, abogado, político).
- Fragile evidence: the cookie tin (3 kg, worth 1000) loses value on hits above 3 m/s and breaks at 0.
- Grandpa's house (case 1.1): two floors, 8 rooms, stairs and 10 hiding spots; the tin and the safe hide in a seeded random spot each match. Play opens it; the grey room moved to "Sala de pruebas".
- Locked front door: E searches the pots for the key and opens the door with it; three battering ram hits knock it down (the ram itself comes next). Short hints at the bottom of the screen.
- Battering ram: E picks it up in front of the house; hold left click to charge, let go to hit. Three charged hits knock the door down, a miss staggers the cop, and carrying it slows the walk.
- 147 fragile ornaments (figurines, plates and vases) on shelves, the dining table and the kitchen counter; any real hit shatters one and costs a fine of 20.
- Design docs: decisions, case catalog and working rules.
