class_name MimeSilence
extends Node3D

## No talking at the mimes' theater (infiltracion-mimos.md, step 3, decision 170): while a player sends voice (close or
## radio), their PC tells the host every TALK_EVERY seconds (VoiceChat.spoke), and every mime within HEAR_RANGE of
## that cop hears it, wherever they look: TALKING suspicion per second. Away from the mimes the cops can talk freely.
## This PC shows its own player when a mime is close enough to hear. Without Steam there is no voice, so it never
## counts. Every number here is (propuesta).

## Per second of voice, to each mime this close.
const TALKING := 20.0
const HEAR_RANGE := 8.0
## How often a talking PC tells the host (VoiceChat).
const TALK_EVERY := 0.5

var suspicion: ClubSuspicion
## Whether a world position is inside the theater (MimeTheater sets it).
var inside: Callable = func(_at: Vector3) -> bool: return false
var _hud: CanvasLayer
var _warning: Label


func _ready() -> void:
	add_to_group("mime_silence")
	_hud = CanvasLayer.new()
	_warning = Label.new()
	_warning.text = "HUD_MIME_HEARS_YOU"
	_warning.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_warning.position = Vector2(-160, -110)
	_warning.custom_minimum_size = Vector2(320, 0)
	_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warning.add_theme_font_size_override("font_size", 22)
	_warning.modulate = Color(1, 0.9, 0.5)
	_hud.add_child(_warning)
	_hud.hide()
	add_child(_hud)


## The mimes that would hear `cop` talk.
func hearing(cop: Node3D) -> Array[ClubMember]:
	var near: Array[ClubMember] = []
	if not suspicion or not inside.call(cop.global_position):
		return near
	for member in suspicion.members:
		if member.global_position.distance_to(cop.global_position) <= HEAR_RANGE:
			near.append(member)
	return near


## Host: `cop`'s player talked for the last TALK_EVERY seconds (VoiceChat).
func heard_talking(cop: Node3D) -> void:
	for member in hearing(cop):
		suspicion.raise(member, TALKING * TALK_EVERY)


func _process(_delta: float) -> void:
	var cop := VoiceChat.local_cop(get_tree())
	_hud.visible = cop != null and not suspicion.found_out and not hearing(cop).is_empty()
