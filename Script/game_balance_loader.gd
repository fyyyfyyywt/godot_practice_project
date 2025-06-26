## GameBalanceLoader.gd
## 用于加载节奏数据，并按时间查询对应参数

extends Node

var balance_data: Array = []

func load_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("❌ 找不到文件: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("❌ 无法打开文件: %s" % path)
		return

	var content := file.get_as_text()
	var result :Array= JSON.parse_string(content)

	if typeof(result) == TYPE_ARRAY:
		balance_data = result
	else:
		push_error("❌ JSON 格式错误，应为数组")

func get_row_by_time(t: float) -> Dictionary:
	if balance_data.is_empty():
		return {}

	var index := int(t / 10.0)
	index = clamp(index, 0, balance_data.size() - 1)
	return balance_data[index]
