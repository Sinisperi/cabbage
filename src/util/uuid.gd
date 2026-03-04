class_name UUID


static func gen() -> String:
	var ascii_hex: String = "0123456789abcdef"
	var uuid: String = ""
	for i in range(32):
		if i == 12:
			uuid += "4"
		elif i ==  16:
			uuid += ascii_hex[randi() % 4 + 8]
		else:
			uuid += ascii_hex[randi() % 16]
	
	return "%s-%s-%s-%s-%s" % [
		uuid.substr(0, 8),
		uuid.substr(8, 4),
		uuid.substr(12, 4),
		uuid.substr(16, 4),
		uuid.substr(20, 12)
	]
