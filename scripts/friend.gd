extends CharacterBody3D
var player: Node3D = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("player")):
		player = body
		if Boss.boss_dialog_section != Boss.BossDialogSections.FRIEND_RESCUED:
			Boss.setDialogStage(Boss.BossDialogSections.FRIEND_RESCUED)
			

			
func _physics_process(_delta):
	if player == null:
		return
	var direction = player.global_position - global_position
	#direction = direction.normalized() * 2
	direction.z = 0
	direction = direction * 2
	velocity = direction
	
	if global_position.y >= -5:
		if Boss.boss_node != null:
			Boss.boss_node.queue_free()
		if Boss.boss_dialog_section != Boss.BossDialogSections.WIN:
			Boss.setDialogStage(Boss.BossDialogSections.WIN)
	
	move_and_slide()
	

func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("player")):
		player = null
