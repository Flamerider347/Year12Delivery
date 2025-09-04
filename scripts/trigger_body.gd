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

# Keep references to running fades so we can cancel them
var fade_tasks := {}

func _ready() -> void:
	menu()

# Utility: start a fade safely
func start_fade(track: AudioStreamPlayer, fade_func: Callable, duration: float):
	if track == null or not is_instance_valid(track):
		return
	if fade_tasks.has(track):
		fade_tasks[track].cancelled = true
		fade_tasks.erase(track)
	var task = { "cancelled": false }
	fade_tasks[track] = task
	await fade_func.call(track, duration, task)
	if fade_tasks.has(track):
		fade_tasks.erase(track)

func fade_out(track: AudioStreamPlayer, duration: float, task):
	if track == null or not is_instance_valid(track):
		return
	var steps = 20
	var step_time = duration / steps
	var start_volume = float(track.volume_db)
	for i in range(steps):
		if task.cancelled: return
		track.volume_db = lerp(start_volume, -40.0, float(i + 1) / steps)
		await get_tree().create_timer(step_time).timeout
	if not task.cancelled and is_instance_valid(track):
		track.stop()

func fade_in(track: AudioStreamPlayer, duration: float, task):
	if track == null or not is_instance_valid(track):
		return

	# Stop any other playing tracks just in case
	for child in get_children():
		if child is AudioStreamPlayer and child != track and child.playing:
			child.stop()

	track.volume_db = -40.0
	track.play()
	var steps = 20
	var step_time = duration / steps
	for i in range(steps):
		if task.cancelled: return
		track.volume_db = lerp(-40.0, 0.0, float(i + 1) / steps)
		await get_tree().create_timer(step_time).timeout

func _on_body_entered(body):
	# Only player_single and player control audio
	if body.name in ["player_single", "player"] and can_play:
		can_play = false
		$Transition_timer.start(2.01)
		playing_next = "menu"

		if playing_current != "<null>":
			await start_fade(tracks[playing_current], fade_out, 1.0)

			playing_current = playing_next
			await start_fade(tracks[playing_current], fade_in, 1.0)
			playing_next = null
			menu_open = false

func _on_body_exited(body):
	# Only player_single and player control audio
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

		await start_fade(tracks[playing_current], fade_out, 1.0)
		playing_current = playing_next
		await start_fade(tracks[playing_current], fade_in, 1.0)

func menu():
	if playing_current == "book":
		return
	menu_open = true

	# Fade out safely
	if tracks.has(playing_current):
		await start_fade(tracks[playing_current], fade_out, 1.0)

	# 🔇 Extra safety: once fades are done, mute/stop everything
	for child in get_children():
		if child is AudioStreamPlayer and child.playing:
			child.stop()

	# Switch to book
	playing_current = "book"
	await start_fade(tracks[playing_current], fade_in, 1.0)
	playing_next = null

func _on_transition_timer_timeout() -> void:
	can_play = true
