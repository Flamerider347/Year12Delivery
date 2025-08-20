extends Area3D

@onready var tracks = {
	dine_in = $AudioStreamPlayer3D_lava,
	lava = $AudioStreamPlayer3D_lava,
	underwater = $AudioStreamPlayer3D_underwater,
	restaurant = $AudioStreamPlayer3D_frozen,
	menu = $menu,
	book = $book
}

var playing_current = "menu"
var playing_next = "menu"
var menu_open = false

func _ready() -> void:
	menu()
# Fade out a track over duration seconds
func fade_out(track: AudioStreamPlayer3D, duration: float = 1.0):
	var steps = 20
	var step_time = duration / steps
	var start_volume = float(track.volume_db)
	for i in range(steps):
		track.volume_db = lerp(start_volume, -40.0, float(i + 1)/steps)
		await get_tree().create_timer(step_time).timeout
	track.stop()

# Fade in a track over duration seconds
func fade_in(track: AudioStreamPlayer3D, duration: float = 1.0):
	track.volume_db = -40.0
	track.play()
	var steps = 20
	var step_time = duration / steps
	for i in range(steps):
		track.volume_db = lerp(-40.0, 0.0, float(i + 1)/steps)
		await get_tree().create_timer(step_time).timeout

func _on_body_entered(body):
	if body.name in ["player_single", "player", "player2"]:
		playing_next = "menu"  # Always switch to menu
		
		# Fade out whatever is currently playing (book or any other track)
		if playing_current != "":
			await fade_out(tracks[playing_current], 1.0)
		
		# Fade in the menu track
		playing_current = playing_next
		await fade_in(tracks[playing_current], 1.0)
		playing_next = null
		menu_open = false

func _on_body_exited(body):
	if menu_open:
		return
	if body.name in ["player_single", "player", "player2"]:
		if $"../../..".level == 1:
			playing_next = "lava"
		elif $"../../..".level == 2:
			playing_next = "lava"
		elif $"../../..".level == 3:
			playing_next = "underwater"
		
		await fade_out(tracks[playing_current], 1.0)
		playing_current = playing_next
		await fade_in(tracks[playing_current], 1.0)

func menu():
	if playing_current == "book":
		return
	menu_open = true
	if tracks.has(playing_current):
		await fade_out(tracks[playing_current], 1.0)
	playing_current = "book"
	await fade_in(tracks[playing_current], 1.0)
	playing_next = null

func close_menu():
	if not menu_open:
		return
	menu_open = false
