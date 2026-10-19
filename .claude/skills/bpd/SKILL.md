---
name: bpd
description: Rules Cristian already gave for BPD (tone, words, look, how to work and show results). Read before any change to the game, and add to it whenever Cristian corrects something.
---

# BPD: rules learned so far

Each rule is one or two lines: the rule and why. The source of truth for design is `docs/diseno/decisiones.md`;
the number in brackets is the decision there.

## How this skill grows
- When Cristian corrects something, add the rule here in the section it belongs to, in the same PR as the fix.
- Before closing a PR, ask: "did I learn something the next session needs?" If yes, add it here.
- Replace a rule that changed; never leave two that contradict each other.

## Tone
- Rookie, useless cops; the joke is that everything goes wrong. The world is believable, chaos comes from physics and players. [1, 3]
- Silly non-lethal violence: paint and confetti guns, taser, net, baton, ragdoll. NPCs never die, they faint or get arrested. [4, 5]
- Generic movie city: no reference to any real country, music included. [2, 46] Cristian asked for it explicitly.

## Words in the game
- caso (never misión), sospechoso (never enemigo), comisario (never jefe). [44]
- Neutral Spanish with "tú", always through `tr()`, with English and Portuguese from day one. [42, 43] In Dread Warden the texts were hardcoded and translating later hurt.

## Look
- First person, simple low poly 3D with strong colors and floppy ragdoll characters; a mix of R.E.P.O., PEAK and Dear Passengers. [11, 12, 14]
- Placeholders are not grey boxes: procedural low poly models (flat facets, strong colors, soft sky light) from `tools/modelgen`, so playtests look nice. [71] Cristian asked for it: grey boxes looked too poor, and wgt showed procedural models are cheap.
- Keep BPD's own style (low poly, R.E.P.O. / PEAK), not wgt's comic cel shading with ink outlines. [12, 71] Cristian corrected it when wgt's look was proposed.
- Every character uses the pear body; cops all wear the blue uniform and only the skin color tells players apart; NPCs differ by outfit and props, with softer skins. [72] Cristian wanted non-humanoid PEAK / R.E.P.O. bodies and police in police blue.
- For a new look, show a few variants as images and let Cristian pick before putting it in the game. [72] He asked for 5 body options to approve.
- In first person the player sees blue sleeves and mitten hands in their skin color (variant B). Cristian picked them on 19/10 out of 5 options (ball, mitten, fingers, cartoon, noodle).
- Placeholder art is never final: final art needs Cristian's approval, AI art is never final. [71]

## Cases
- Every case type needs at least 10 variants (own map and twist), picked at random each match; inside each variant the evidence, culprit, suspects, neighbours and escape route also change. [19] Cristian wants no two matches alike.

- Every case needs a story the comisario tells, with the why of each thing to find; never a lone "find the box". Bizarre stories are welcome across the game. Cristian asked for it in the 19/10 playtest: only cookies felt flat.
- Always show on screen what the player can do (key prompts, the Q checklist). In the 19/10 playtest he got stuck holding the ram without knowing how to drop it.

## Working with Cristian
- He works alone and merges himself; no Jira, cards are GitHub issues. [61, 62]
- To check progress he opens the game and gives the OK (cheapest in tokens). Videos only when he asks. [57]
- Lessons from Dread Warden: fix scale and match length early in grey (the map was scaled 5x late); test Steam with two real accounts in the first week (it never was); keep CLAUDE.md short (it grew to 268 KB).
