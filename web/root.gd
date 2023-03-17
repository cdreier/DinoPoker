extends Node2D

var client = WebSocketMultiplayerPeer.new()

var playerCount = 0
var activeBaseCount = 0

func getServer():
	var server = "ws://127.0.0.1:5000"
	if OS.has_feature('JavaScript'):
		var tmp = JavaScriptBridge.eval("""
			const urlParams = new URLSearchParams(window.location.search);
			urlParams.get('server');
		""")
		if tmp != "":
			server = tmp
	return server

func _ready():
	var url = getServer() 
	print(url)
	var err = client.create_client(url)
	if err != OK:
		print("ERROR when trying to connect ", err)
	multiplayer.multiplayer_peer = client
	
	multiplayer.connected_to_server.connect(Callable(self, "_connected_ok"))
	multiplayer.connection_failed.connect(Callable(self, "_connected_fail"))
	multiplayer.server_disconnected.connect(Callable(self, "_server_disconnected"))
	
func _connected_ok():
	print("connect OK")
	
func _connected_fail():
	$world/Announcement.text = "ERROR: connection failed"
	
func _server_disconnected():
	$world/Announcement.text = "ERROR: Server disconnected"
	
# BULLET HANDLING
var bulletClass = preload("res://bullet.tscn")

func request_bullet_spawn(pos, flip):
	rpc_id(1, "spawnBullet", pos, flip)
	
	
func _on_JoinButton_pressed():
	var playerName = $JoinPanel/LineEdit.text
	rpc_id(1, "registerClient", playerName)
	$JoinPanel.hide()
	
func _on_declare_king_body_entered(body):
	print("wtf")
	if body is CharacterBody2D && body.has_method("isSelf") && body.isSelf():
		$AnnouncementPanel.show()

func _on_declare_king_body_exited(body):
	if body is CharacterBody2D && body.has_method("isSelf") && body.isSelf():
		$AnnouncementPanel.hide()

func _on_AnnouncementText_text_changed():
	rpc_id(1, "setAnnouncement", $AnnouncementPanel/AnnouncementText.text)


func _on_CollissionButton_toggled(button_pressed):
	rpc_id(1, "setCollision", button_pressed)
	
@rpc("any_peer") 
func setCollision(active):
	$AnnouncementPanel/CollisionButton.button_pressed = active

@rpc("any_peer") 
func playerCountChanged(playerCountChange):
	$AnnouncementPanel/PlayerLabel/players.text = str(playerCountChange)
	
@rpc("any_peer") 
func activeBaseCountChanged(activeOnBase):
	$AnnouncementPanel/PlayerLabel/active.text = str(activeOnBase)
	
@rpc("any_peer") 
func setAnnouncement(txt):
	$world/Announcement.text = txt
#	var id = multiplayer.get_unique_id()
#	var player = get_node("/root/root/network").get_node(str(id))
#	if player != null:
#		player.discussionMode = txt.find(discussionMode_code) >= 0

@rpc("any_peer", "call_local") 
func spawnBullet(pos, flip):
	var b = bulletClass.instantiate()
	b.position = pos
	if flip:
		b.position.x -= 20
	else:
		b.position.x += 20
	b.flipped = flip
	get_tree().get_root().add_child(b)

@rpc("any_peer")
func registerClient(_clientName):
	pass
	
@rpc("any_peer") 
func populate_world(_id):
	pass
	
func _process(_delta):
	if (client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED ||
		client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();



func _on_area_2d_body_entered_DEBUG(body):
	print("WTF1", body)
	pass # Replace with function body.


func _on_area_2d_area_entered_DEBUG(area):
	print("WTF2", area)
	pass # Replace with function body.


func _on_area_2d_area_shape_entered_DEBUG(area_rid, area, area_shape_index, local_shape_index):
	print("WTF3")
	pass # Replace with function body.
