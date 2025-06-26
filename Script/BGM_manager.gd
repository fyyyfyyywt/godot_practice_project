# BGMManager.gd
extends Node

var current_music: AudioStreamPlayer = null

func play_music(music_stream: AudioStream, loop := true):
	if current_music:
		current_music.stop()
		current_music.queue_free()

	current_music = AudioStreamPlayer.new()
	add_child(current_music)
	current_music.stream = music_stream
	current_music.autoplay = false
	current_music.bus = "Music"
	current_music.volume_db = -6

	# 正确设置循环
	if music_stream is AudioStreamOggVorbis or music_stream is AudioStreamMP3 or music_stream is AudioStreamWAV:
		music_stream.loop = loop

	current_music.play()
	
func fade_out_music(duration: float = 1.0):
	if current_music:
		var tween = get_tree().create_tween()
		tween.tween_property(current_music, "volume_db", -20, duration).set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(current_music.stop)
		await tween.finished
