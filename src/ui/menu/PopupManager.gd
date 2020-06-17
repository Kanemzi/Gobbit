extends Node2D
class_name MenuPopupManager

onready var popup := $Popup

func _ready() -> void:
	popup.connect("closed", self, "_on_Popup_Closed")


func show_message(message: String) -> void:
	$GrayOverlay.visible = true
	popup.message = message
	popup.open()


func _on_Popup_Closed() -> void:
	$GrayOverlay.visible = false
