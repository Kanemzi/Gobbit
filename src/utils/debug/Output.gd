extends TextEdit

func print(data) -> void:
	text += str(data)
#	scroll_vertical = 1000000

func println(data) -> void:
	self.print(data)
	text += "\n"
	
