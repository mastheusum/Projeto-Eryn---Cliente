extends Control

var can_create : bool = true

func _on_visibility_changed():
	$Username.text = ''
	$Password.text = ''
	$Password2.text = ''


func _on_CreateNewAccountButton_pressed():
	var err = "Creating Account.\nPlease Wait..."
	
	var username : String = $Username.text
	var password : String = $Password.text
	var passwordConfimation : String = $Password2.text
	
	var pool_username = username.split(' ')
	var tmp_username = pool_username.join('')
	
	if username != tmp_username:
		can_create = false
		err = "Invalid Username"
	elif username.length() < 6:
		can_create = false
		err = "Invalid Username. Need at least 6 characters."
	elif password.length() < 8 or passwordConfimation.length() < 8:
		can_create = false
		err = "Invalid Password. Need at least 8 characters."
	elif password != passwordConfimation:
		can_create = false
		err = "Invalid Passsword. Password and Confim Password are different."
	
	if can_create:
		configure_panel_wait(err)
		username = username.to_upper()
		password = password.sha256_text()
		
		ConnectionManager.rpc_id(1, 'request_new_account', username, password)
	else:
		configure_panel_wait(err)
	

func _on_CancelNewAccountButton_pressed():
	get_node('/root/Lobby').login_to_create_new_account(false)

func _on_VisiblePassword_pressed():
	var visible = $VisiblePassword.pressed
	$Password.secret = not visible

func _on_Confirm_Create_New_Account_pressed():
	# Enable buttons to allow new requests
	$CancelNewAccountButton.disabled = false
	$CreateNewAccountButton.disabled = false
	
	$PanelResult.visible = false
	if can_create:
		get_node('/root/Lobby').login_to_create_new_account(false)

func configure_panel_wait(message : String):
	# Disable buttons to prevent new requests
	$CancelNewAccountButton.disabled = true
	$CreateNewAccountButton.disabled = true
	
	$PanelResult/Error.text = message
	$PanelResult.visible = true

