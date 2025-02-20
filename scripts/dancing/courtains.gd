class_name Courtains
extends Node2D

signal opened
signal closed


var _tween: Tween


func open() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position:y", -160.0, 3.0)
	_tween.finished.connect(opened.emit)


func close(immediate: bool = false) -> void:
	if immediate:
		position.y = 0.0
		closed.emit.call_deferred()
		return
	
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position:y", 0, 3.0)
	_tween.finished.connect(closed.emit)
