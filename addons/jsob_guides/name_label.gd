tool
extends Label


signal stream_recieved(stream)


func can_drop_data(_position, data):
#	return true
	if data is Dictionary:
		return "type" in data and data.type == "files" and "files" in data and data.files is PoolStringArray and data.files.size() == 1
	return false


func drop_data(_position, data):
	var result: Resource = load(data.files[0])
	if result is AudioStream:
		emit_signal("stream_recieved", result)
#	print(data, typeof(data.files) if "files" in data else null)
