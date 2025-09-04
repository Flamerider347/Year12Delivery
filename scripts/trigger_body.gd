extends Area3D

@onready var tracks = {
	dine_in = $nature,
	lava = $AudioStreamPlayer3D_lava,
	underwater = $AudioStreamPlayer3D_underwater,
	menu = $menu,
	book = $book,
	tundra = $tundra
}

var playing_current = "menu"
var playing_next = "menu"
var menu_open = false
var can_play = true

# Track active tweens per AudioStream
var fade_tweens := {}

func _ready() -> void:
	menu()


func tween_fade(track: AudioStreamPlayer, target_volume: float, duration: float, play_on_start := false, stop_on_end := false):
	if track == null or not is_instance_valid(track):
		return

	# Kill existing tween for this track
	if fade_tweens.has(track):
		fade_tweens[track].kill()
		fade_tweens.erase(track)

	var tween := create_tween()
	fade_tweens[track] = tween

	if play_on_start:
		track.volume_db = -40.0
		track.play()

	tween.tween_property(track, "volume_db", target_volume, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	if stop_on_end:
		tween.tween_callback(track.stop)

	tween.tween_callback(func():
		if fade_tweens.has(track):
			fade_tweens.erase(track)
	)

func _on_body_entered(body):
	if body.name in ["player_single", "player"] and can_play:
		can_play = false
		$Transition_timer.start(2.01)
		playing_next = "menu"

		if playing_current != "<null>" and tracks.has(playing_current):
			tween_fade(tracks[playing_current], -40.0, 1.0, false, true)

		if tracks.has(playing_next):
			tween_fade(tracks[playing_next], 0.0, 1.0, true, false)

		playing_current = playing_next
		playing_next = null
		menu_open = false


func _on_body_exited(body):
	if menu_open:
		return
	if body.name in ["player_single", "player"] and can_play:
		can_play = false
		$Transition_timer.start(2.01)

		if $"../../..".level == 1:
			playing_next = "dine_in"
		elif $"../../..".level == 2:
			playing_next = "lava"
		elif $"../../..".level == 3:
			playing_next = "underwater"
		elif $"../../..".level == 4:
			playing_next = "tundra"

		if tracks.has(playing_current):
			tween_fade(tracks[playing_current], -40.0, 1.0, false, true)

		if tracks.has(playing_next):
			tween_fade(tracks[playing_next], 0.0, 1.0, true, false)

		playing_current = playing_next
		playing_next = null


func menu():
	if playing_current == "book":
		return

	menu_open = true

	if tracks.has(playing_current):
		tween_fade(tracks[playing_current], -40.0, 1.0, false, true)

	# Extra safety: Stop everything after fade
	for child in get_children():
		if child is AudioStreamPlayer and child.playing:
			child.stop()

	if tracks.has("book"):
		tween_fade(tracks["book"], 0.0, 1.0, true, false)
		playing_current = "book"
		playing_next = null


func _on_transition_timer_timeout() -> void:
	can_play = true
