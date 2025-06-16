extends Node

## GameBalanceLoader.gd
## 用于加载和按时间段查找节奏数据

var balance_data: Array = []

func load_json(path: String) -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content := file.get_as_text()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				balance_data = parsed
			else:
				push_error("❌ JSON 数据格式错误: 不是数组")
	else:
		push_error("❌ 文件未找到: " + path)

func get_row_by_time(t: float) -> Dictionary:
	if balance_data.is_empty():
		return {}
	var index := int(t / 10.0)
	index = clamp(index, 0, balance_data.size() - 1)
	return balance_data[index]
