extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var sb = StyleBoxFlat.new()
	add_theme_stylebox_override("fill", sb)
	if self.value < 100:
		sb.bg_color = Color("fff846")  # yellow
	elif self.value == 100:
		sb.bg_color = Color("00f846")  # green
