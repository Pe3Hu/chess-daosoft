class_name ChessTile
extends Sprite2D


var chess_board: ChessBoard
var resource: ChessTileResource:
	set(value_):
		resource = value_
		position = FrameworkSettings.TILE_SIZE * Vector2(resource.coord)
		is_light = (resource.coord.x + resource.coord.y) % 2 != 1
		$IndexLabel.text = str(int(resource.coord.y * FrameworkSettings.BOARD_SIZE.x + resource.coord.x))
#var coord: Vector2i:
	#set(value_):
		#coord = value_
		#
		#position = FrameworkSettings.TILE_SIZE * Vector2(coord)
		#is_light = (coord.x + coord.y) % 2 != 1
		#text = str(int(coord.y * FrameworkSettings.BOARD_SIZE.x + coord.x))
		#var tile_color = "dark"
		#
		#if is_light:
			#tile_color = "light"
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
		var is_free = resource.chess_piece == null
		
		if is_free:
			#put СhessPiece in its legal ChessTile
			if chess_board.resource.focus_chess_tile != null:
				if chess_board.resource.focus_chess_tile.chess_piece.is_valid_chess_tile(resource):
					var chess_piece = chess_board.resource_to_chess_piece[chess_board.resource.focus_chess_tile.chess_piece]
					chess_piece.place_on_chess_tile(self)
		else:
			#take ChessPiece if focus_chess_tile is free
			if chess_board.resource.focus_chess_tile == null:# and resource.chess_piece:
				chess_board.hold_piece_on_chess_tile(self)
				return
		
			#return ChessPiece to its original ChessTile
			if chess_board.resource.focus_chess_tile == resource:
				var chess_piece = chess_board.resource_to_chess_piece[resource.chess_piece]
				chess_piece.place_on_chess_tile(self)
