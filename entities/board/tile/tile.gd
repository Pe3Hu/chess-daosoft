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
			modulate = Color.DIM_GRAY
		FrameworkSettings.TileState.NEXT:
			modulate = Color.SEA_GREEN
		FrameworkSettings.TileState.CAPTURE:
			modulate = Color.BLUE_VIOLET
		FrameworkSettings.TileState.PIN:
			modulate = Color.DEEP_PINK
		FrameworkSettings.TileState.CHECK:
			modulate = Color.ROYAL_BLUE
		FrameworkSettings.TileState.AlTAR:
			modulate = Color.BLACK
	
func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if _event.is_action_pressed("click"):
		fox_piece_swap()
		if board.game.on_pause: return
		if board.game.referee.resource.winner_player != null: return
		var is_free = resource.piece == null
		
		if is_free:
			if board.resource.focus_tile != null:
				#put СhessPiece in its legal Tile
				#if board.resource.focus_tile.piece.is_valid_tile(resource):
				if resource.current_state == FrameworkSettings.TileState.CURRENT or resource.current_state == FrameworkSettings.TileState.NEXT:
					var piece = board.get_piece(board.resource.focus_tile.piece)
					piece.place_on_tile(self)
				#return Piece to its original Tile if move is illegal
				else:
					var origin_tile = board.get_tile(board.resource.focus_tile)
					var origin_piece = board.get_piece(board.resource.focus_tile.piece)
					origin_piece.place_on_tile(origin_tile)
		else:
			#take Piece if focus_tile is free
			if board.resource.focus_tile == null:# and resource.piece:
				#check active player piece color
				if board.resource.game.referee.active_player.color == resource.piece.template.color:
					board.hold_piece_on_tile(self)
				return
			
			var target_piece = board.get_piece(resource.piece)
			
			if target_piece != null:
				#capturing an opponent Piece
				if board.resource.focus_tile.piece.is_valid_tile(resource):
					if !target_piece.resource.is_same_color(board.resource.focus_tile.piece):
						var origin_piece = board.get_piece(board.resource.focus_tile.piece)
						origin_piece.place_on_tile(self)
						return
			
			#return Piece to its original Tile
			if board.resource.focus_tile == resource:
				var origin_piece = board.get_piece(resource.piece)
				origin_piece.place_on_tile(self)
	
func fox_piece_swap() -> void:
	if !board.game.on_pause or board.game.resource.referee.winner_player != null: return
	if !(resource.current_state == FrameworkSettings.TileState.CURRENT or resource.current_state == FrameworkSettings.TileState.NEXT): return
	
	if board.resource.focus_tile == null:
		match resource.current_state:
			FrameworkSettings.TileState.NEXT:
				board.hold_piece_on_tile(self)
				resource.current_state = FrameworkSettings.TileState.CURRENT
				update_state()
	else:
		var origin_piece = board.get_piece(resource.piece)
		
		match resource.current_state:
			FrameworkSettings.TileState.CURRENT:
				origin_piece.place_on_tile(self)
				resource.current_state = FrameworkSettings.TileState.NEXT
				update_state()
			FrameworkSettings.TileState.NEXT:
				board.fox_swap(origin_piece)
