class_name ChessMove
extends PanelContainer


var resource: ChessMoveResource:
	set(value_):
		resource = value_
		
		var start_str = FrameworkSettings.AXIS_X[resource.start_chess_tile.coord.x]+FrameworkSettings.AXIS_Y[resource.start_chess_tile.coord.y]
		var end_str = FrameworkSettings.AXIS_X[resource.end_chess_tile.coord.x]+FrameworkSettings.AXIS_Y[resource.end_chess_tile.coord.y]
		var action_str = FrameworkSettings.move_to_symbol[resource.type]
		var type_str = resource.chess_piece.get_type()[0].capitalize()
		
		if resource.chess_piece.template.type == FrameworkSettings.PieceType.KNIGHT:
			type_str = "N"
		
		if type_str == "P":
			type_str = ""
		
		%ReversibleAlgebraic.text = type_str + start_str + action_str + end_str
