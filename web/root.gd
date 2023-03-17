extends Node2D

var client = WebSocketMultiplayerPeer.new()

var playerCount = 0
var activeBaseCount = 0
const discussionMode_code = "idkfa"

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
	print("connect failed")
	
func _server_disconnected():
	print("disconnected")
	
# BULLET HANDLING
var bulletClass = preload("res://bullet.tscn")

func request_bullet_spawn(pos, flip):
	rpc_id(1, "spawnBullet", pos, flip)
	
	
func _on_JoinButton_pressed():
	var playerName = $JoinPanel/LineEdit.text
	rpc_id(1, "registerClient", playerName)
	$JoinPanel.hide()
	
func _on_declare_king_body_entered(body):
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
	var id = multiplayer.get_unique_id()
	var player = get_node("/root/root/network").get_node(str(id))
	if player != null:
		player.discussionMode = txt.find(discussionMode_code) >= 0

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
func connected():
	var selfPeerID = multiplayer.get_unique_id()
	var my_player = preload("res://player.tscn").instantiate()
	my_player.set_name(str(selfPeerID))
	my_player.set_multiplayer_authority(selfPeerID)
	my_player.playerName = $JoinPanel/LineEdit.text
	my_player.discussionMode = $world/Announcement.text.find(discussionMode_code) >= 0
	get_tree().get_root().add_child(my_player)
#	debug
	var gun = my_player.get_node("gun")
	gun.connect("fire_bullet",Callable(self,"request_bullet_spawn"))

		
@rpc("any_peer")
func registerClient(clientName):
	pass
	
@rpc("any_peer") 
func populate_world(id):
	pass
	
func _process(_delta):
	if (client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED ||
		client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();

