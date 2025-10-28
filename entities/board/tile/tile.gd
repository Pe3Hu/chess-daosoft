class_name Tile
extends Sprite2D


var board: Board
var resource: TileResource:
	set(value_):
		resource = value_
		position = FrameworkSettings.TILE_SIZE * Vector2(resource.coord)
		is_light = (resource.coord.x + resource.coord.y) % 2 != 1
		$IndexLabel.text = str(int(resource.coord.y * FrameworkSettings.BOARD_SIZE.x + resource.coord.x))

var is_light: bool:
	set(value_):
		is_light = value_
		
		if is_light:
			frame_coords.x = 1
		else:
			frame_coords.x = 0


func update_state() -> void:
	var state = resource.current_state
	update_modulate(state)
	
func update_modulate(state_: FrameworkSettings.TileState) -> void:
	match state_:
		FrameworkSettings.TileState.NONE:
			modulate = Color.WHITE
		FrameworkSettings.TileState.CURRENT:
			modulate = Color.FIREBRICK
		FrameworkSettings.TileState.NEXT:
			modulate = Color.SEA_GREEN
	
func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("click"):
		var is_free = resource.piece == null
		
		if is_free:
			if board.resource.focus_tile != null:
				#put СhessPiece in its legal Tile
				if board.resource.focus_tile.piece.is_valid_tile(resource):
					var piece = board.resource_to_piece[board.resource.focus_tile.piece]
					piece.place_on_tile(self)
				#return Piece to its original Tile if move is illegal
				else:
					var origin_tile = board.get_tile(board.resource.focus_tile)
					var origin_piece = board.resource_to_piece[board.resource.focus_tile.piece]
					origin_piece.place_on_tile(origin_tile)
		else:
			#take Piece if focus_tile is free
			if board.resource.focus_tile == null:# and resource.piece:
				#check active player piece color
				if board.resource.game.referee.active_player.color == resource.piece.template.color:
					board.hold_piece_on_tile(self)
				
				return
			
			var target_piece = board.resource_to_piece[resource.piece]
			
			#capturing an opponent Piece
			if board.resource.focus_tile.piece.is_valid_tile(resource):
				if !target_piece.resource.is_same_color(board.resource.focus_tile.piece):
					var origin_piece = board.resource_to_piece[board.resource.focus_tile.piece]
					origin_piece.place_on_tile(self)
					return
			
			#return Piece to its original Tile
			if board.resource.focus_tile == resource:
				var origin_piece = board.resource_to_piece[resource.piece]
				origin_piece.place_on_tile(self)
