extends Node

var account_id : int = -1
var token : String = ""

func set_account_logged(account_id : int, token : String):
	self.account_id = account_id
	if self.account_id != -1:
		self.token = token
		get_node("/root/Lobby").prepare_character_list()

func logout():
	account_id = -1
	ConnectionManager.rpc_id(1, 'sign_out', token)
	pass
