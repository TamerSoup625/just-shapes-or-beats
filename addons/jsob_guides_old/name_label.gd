tool
extends Label


func can_drop_data(_position, data):
	return data is Dictionary


func drop_data(_position, data):
	print(data)
