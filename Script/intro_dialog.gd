extends CanvasLayer

signal dialog_finished
@onready var dialog_label = $DialogLabel
@onready var hint_label = $HintLabel

var dialogs = [
	"【嘶啦——对讲机噪音】",
	"指挥官：喂喂喂，狐影狐影，请回答。这边是基地。你没被史莱姆黏住吧？",
	"主角：我？我刚从便利店逃出来，连杯奶茶都没抢到。你说呢？",
	"指挥官：全镇居民已经安全撤离。现在，只剩你在现场。",
	"主角：哇，这听起来像是我中奖了？",
	"指挥官：任务简单——撑住最后一波，等我们下一步指示。",
	"主角：你这话我已经截图存证了。",
	"【对讲机噪音结束】"
]

var current_index = 0
var is_typing = false

func _ready():
	show_next_line()

func show_next_line():
	is_typing = true
	hint_label.visible = false
	dialog_label.visible_characters = 0
	dialog_label.text = dialogs[current_index]
	current_index += 1
	# 打字机效果
	$Timer.start()

func _unhandled_input(event):
	if is_typing:
		return
	if event.is_action_pressed("ui_accept"):
		if current_index < dialogs.size():
			show_next_line()
		else:
			emit_signal("dialog_finished")
			queue_free()


func _on_timer_timeout() -> void:
	var visible = dialog_label.visible_characters
	if visible < dialog_label.get_total_character_count():
		dialog_label.visible_characters += 1
		$Timer.start()
	else:
		is_typing = false
		hint_label.visible = true
