extends Node

#region signals
signal _initGame
signal _showFullscreenAdv(success: bool, ad_name: String)
signal _showRewardedVideo(success: bool, ad_name: String)
signal _getData(data: Dictionary)
signal _getPlayer(player: JavaScriptObject)
signal _getPayments(payments: JavaScriptObject)
signal _purchase_then(purchase) # purchase:YandexGames.Purchase
signal _purchase_catch(purchase_id: int)
signal _getPurchases(purchases) # purchases: catch-Null/then-Array [YandexGames.Purchase]
signal _getLeaderboards
signal _isAvailableMethod(availible: bool, method_name: String)
signal _canReview(canReview: bool)
signal _requestReview(requestReview: bool)
signal _canShowPrompt(canShowPrompt: bool)
signal _showPrompt(accepted: bool)
# https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#description
# description:{appID:String, default:bool, invert_sort_order:bool, decimal_offset:int, type:String, name:String, title:{en:String, ru:String ..}}
signal _getLeaderboardDescription(description: Dictionary)

# https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#response-format1
signal _getLeaderboardPlayerEntry_then(response: Dictionary) ## response:{score:int, extraData:String, rank:int, getAvatarSrc:JavaScriptObject, getAvatarSrcSet:JavaScriptObject, lang:String, publicName:String, uniqueID:String, scopePermissions_avatar:String, scopePermissions_public_name:String, formattedScore:String}

signal _getLeaderboardPlayerEntry_catch(err_code) ##err_code

# https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#response-format2
# leaderboard:{ getLeaderboardDescription response }, entries:[{ getLeaderboardPlayerEntry response }]
signal _getLeaderboardEntries(response: Dictionary) ##response:{leaderboard:Dictionary, userRank:int, entries:[Dictionary]}

# Remote Config https://yandex.ru/dev/games/doc/en/sdk/sdk-config
signal _getFlags(response) # response: Dictionary OR js error
#endregion

#region callbacks
# Game start - initGame()
var js_callback_initGame = JavaScriptBridge.create_callback(_callback_init)
# Managing ads - showFullscreenAdv()
var js_callback_showFullscreenAdv_onClose = JavaScriptBridge.create_callback(_callback_fullscreenAdv_close)
var js_callback_showFullscreenAdv_onError = JavaScriptBridge.create_callback(_callback_fullscreenAdv_error)
# Managing ads - showRewardedVideo()
var js_callback_showRewardedVideo_onClose = JavaScriptBridge.create_callback(_callback_rewarded_close)
var js_callback_showRewardedVideo_onError = JavaScriptBridge.create_callback(_callback_rewarded_error)
var js_callback_showRewardedVideo_onRewarded = JavaScriptBridge.create_callback(_callback_rewarded_rewarded)
# Player details - getPlayer()
var js_callback_getPlayer = JavaScriptBridge.create_callback(_callback_getPlayer)
# Player details - getData()
var js_callback_getData = JavaScriptBridge.create_callback(_callback_getData)
# In-game purchases - getPayments()
var js_callback_getPayments_then = JavaScriptBridge.create_callback(_callback_getPayments_then)
var js_callback_getPayments_catch = JavaScriptBridge.create_callback(_callback_getPayments_catch)
# In-game purchases - purchase()
var js_callback_purchase_then = JavaScriptBridge.create_callback(_callback_purchase_then)
var js_callback_purchase_catch = JavaScriptBridge.create_callback(_callback_purchase_catch)
# In-game purchases - getPurchases()
var js_callback_getPurchases_then = JavaScriptBridge.create_callback(_callback_getPurchases_then)
var js_callback_getPurchases_catch = JavaScriptBridge.create_callback(_callback_getPurchases_catch)
# Leaderboards - getLeaderboards()
var js_callback_getLeaderboards = JavaScriptBridge.create_callback(_callback_getLeaderboards)
# Leaderboards - getLeaderboardDescription()
var js_callback_getLeaderboardDescription = JavaScriptBridge.create_callback(_callback_getLeaderboardDescription)
# Leaderboards - getLeaderboardPlayerEntry()
var js_callback_getLeaderboardPlayerEntry_then = JavaScriptBridge.create_callback(_callback_getLeaderboardPlayerEntry_then)
var js_callback_getLeaderboardPlayerEntry_catch = JavaScriptBridge.create_callback(_callback_getLeaderboardPlayerEntry_catch)
# Leaderboards - getLeaderboardEntries()
var js_callback_getLeaderboardEntries_then = JavaScriptBridge.create_callback(_callback_getLeaderboardEntries_then)
var js_callback_getLeaderboardEntries_catch = JavaScriptBridge.create_callback(_callback_getLeaderboardEntries_catch)
# Game rating
var js_callback_canReview = JavaScriptBridge.create_callback(_callback_canReview)
var js_callback_requestReview = JavaScriptBridge.create_callback(_callback_requestReview)
# Desktop shortcut
var js_callback_canShowPrompt = JavaScriptBridge.create_callback(_callback_canShowPrompt)
var js_callback_showPrompt = JavaScriptBridge.create_callback(_callback_showPrompt)
# Remote Config  https://yandex.ru/dev/games/doc/en/sdk/sdk-config
var js_callback_getFlags_catch = JavaScriptBridge.create_callback(_callback_getFlags_catch)
var js_callback_getFlags_then = JavaScriptBridge.create_callback(_callback_getFlags_then)

var js_callback_isAvailableMethod = JavaScriptBridge.create_callback(_callback_isAvailableMethod)
#endregion
#region public variables
const _print:String = "Addon:YandexGamesSDK, YandexGames.gd"
var _print_debug:bool = true

var now_fullscreen:bool = false
var now_rewarded:bool = false
var now_purchase:bool = false
var now_review:bool = false

var is_initGame: bool = false
var js_ysdk: JavaScriptObject
var js_ysdk_player
var js_ysdk_payments
var js_ysdk_lb
var js_console
#endregion
#region private variables
var _saved_data_json:String = "" ## DO NOT USE! PRIVATE VARIABLE
var _get_data:Dictionary ## DO NOT USE! PRIVATE VARIABLE
var _current_purchase_product_id:String = "" ## DO NOT USE! PRIVATE VARIABLE
var _current_isAvailableMethod:String = "" ## DO NOT USE! PRIVATE VARIABLE
var _current_isAvailableMethod_result:bool ## DO NOT USE! PRIVATE VARIABLE
var _current_canReview:bool ## DO NOT USE! PRIVATE VARIABLE
var _current_canShowPrompt:bool ## DO NOT USE! PRIVATE VARIABLE
var _current_rewarded_success:bool ## DO NOT USE! PRIVATE VARIABLE
var _current_get_purchases_then ## DO NOT USE! PRIVATE VARIABLE
var _current_getFlags ## DO NOT USE! PRIVATE VARIABLE

var current_rewarded_ad_name = "" ## READONLY
var current_fullscreen_ad_name = "" ## READONLY
#endregion

class Purchase:
	var product_id:String ## product_id from Yandex Console (You specify it yourself)
	var _js_purchase:JavaScriptObject
	func _init(__js_purchase:JavaScriptObject):
		product_id = __js_purchase.productID
		_js_purchase = __js_purchase
	func consume(): ## consume() for to remove from array YandexGames.getPurchases() (on the Yandex side)
		Yandex.js_ysdk_payments.consumePurchase(_js_purchase.purchaseToken)

func on_ready():
	assert(js_ysdk != null, "%s, js_ysdk == null, before calling ready(), call initGame() and wait for on_initGame(), then you can call ready()"%[_print])
	js_ysdk.features.LoadingAPI.ready()


func _ready():
	var js_window = JavaScriptBridge.get_interface("window")
	js_console = JavaScriptBridge.get_interface("console")
	initGame()
	await _initGame
	getPlayer(false)
	await _getPlayer
	getPayments()
	getLeaderboards()

#region initGame
# https://yandex.ru/dev/games/doc/en/sdk/sdk-gameready
func initGame(): ##auto-call from _ready() on game start
	var js_window:JavaScriptObject = JavaScriptBridge.get_interface("window")
	js_window.YaGames.init().then(js_callback_initGame)


func _callback_init(args):
	if _print_debug: print("%s js_callback_initGame(args:%s)"%[_print, args])
	js_ysdk = args[0]
	var js_window = JavaScriptBridge.get_interface("window")
	js_window.ysdk = js_ysdk
	is_initGame = true
	_initGame.emit()
	if _print_debug: print("%s js_callback_initGame(args:%s) is_initGame = true"%[_print, args])
#endregion


#region Managing ads 
# https://yandex.ru/dev/games/doc/en/sdk/sdk-adv
#region showFullscreenAdv()
func showFullscreenAdv(ad_name:String):
	var js_dictionary:JavaScriptObject = null
	var js_dictionary_2:JavaScriptObject = null
	js_dictionary = JavaScriptBridge.create_object("Object")
	js_dictionary_2 = JavaScriptBridge.create_object("Object")
	#js_callback_showFullscreenAdv_onClose = JavaScriptBridge.create_callback(_callback_fullscreenAdv_close)
	#js_callback_showFullscreenAdv_onError = JavaScriptBridge.create_callback(_callback_fullscreenAdv_error)
	js_dictionary_2["onClose"] = js_callback_showFullscreenAdv_onClose
	js_dictionary_2["onError"] = js_callback_showFullscreenAdv_onError
	js_dictionary["callbacks"] = js_dictionary_2
	if _print_debug: js_console.log(js_dictionary)
	current_fullscreen_ad_name = ad_name
	now_fullscreen = true
	js_ysdk.adv.showFullscreenAdv(js_dictionary)


func _callback_fullscreenAdv_close(args: Array):
	if _print_debug: print("%s js_callback_showFullscreenAdv_onClose(args:%s)"%[_print, args])
	var wasShown:bool = args[0]
	var copy_current_fullscreen_ad_name = current_fullscreen_ad_name
	current_fullscreen_ad_name = ""
	now_fullscreen = false
	_showFullscreenAdv.emit(wasShown, copy_current_fullscreen_ad_name)


func _callback_fullscreenAdv_error(args:Array):
	if _print_debug: print("%s js_callback_showFullscreenAdv_onError(args:%s)"%[_print, args])
	var copy_current_fullscreen_ad_name = current_fullscreen_ad_name
	current_fullscreen_ad_name = ""
	now_fullscreen = false
	_showFullscreenAdv.emit(false, copy_current_fullscreen_ad_name)
#endregion

#region showRewardedVideo()
func showRewardedVideo(new_current_rewarded_ad_name:String):

	_current_rewarded_success = false
	current_rewarded_ad_name = new_current_rewarded_ad_name
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("Object")
	var js_dictionary_2:JavaScriptObject = JavaScriptBridge.create_object("Object")
	js_dictionary_2["onClose"] = js_callback_showRewardedVideo_onClose
	js_dictionary_2["onError"] = js_callback_showRewardedVideo_onError
	js_dictionary_2["onRewarded"] = js_callback_showRewardedVideo_onRewarded
	js_dictionary["callbacks"] = js_dictionary_2
	if _print_debug: js_console.log(js_dictionary)
	now_rewarded = true
	js_ysdk.adv.showRewardedVideo(js_dictionary)


func _callback_rewarded_close(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onClose(args:%s)"%[_print, args])
	var ad_name = current_rewarded_ad_name
	current_rewarded_ad_name = ""
	now_rewarded = false
	_showRewardedVideo.emit(_current_rewarded_success, ad_name)


func _callback_rewarded_error(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onError(args:%s)"%[_print, args])
	var ad_name = current_rewarded_ad_name
	_current_rewarded_success = false
	now_rewarded = false
	_showRewardedVideo.emit(_current_rewarded_success, ad_name)


func _callback_rewarded_rewarded(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onRewarded(args:%s)"%[_print, args])
	_current_rewarded_success = true
#endregion
#endregion


#region Player details
# https://yandex.ru/dev/games/doc/en/sdk/sdk-player#auth
#region getPlayer()
func getPlayer(scopes:bool):
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("Object")
	js_dictionary["scopes"] = scopes
	js_ysdk.getPlayer(js_dictionary).then(js_callback_getPlayer)

func getPlayer_await(scopes:bool):
	getPlayer(scopes)
	await _getPlayer

func _callback_getPlayer(args:Array):
	if _print_debug: 
		print("%s js_callback_getPlayer(args:%s)"%[_print, args])
		js_console.log(args[0])
	js_ysdk_player = args[0]
	_getPlayer.emit(js_ysdk_player)
#endregion
# https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data
#region setData()
func setData(data:Dictionary):
	if js_ysdk_player == null: 
		if _print_debug: print("%s setData(data) js_ysdk_player == null"%[_print])
		return
	var json_data:String = JSON.stringify(data)
	if _saved_data_json == json_data: return
	else: _saved_data_json = json_data
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("Object")
	js_dictionary["json_data"] = json_data
	js_ysdk_player.setData(js_dictionary).then(js_console.log("YandexGamesSDK setData success"))
#endregion
#region getData()
func getData():
	if js_ysdk_player == null: 
		if _print_debug: print("%s getData() js_ysdk_player == null"%[_print])
		return
	js_ysdk_player.getData().then(js_callback_getData)
	return

func getData_await() -> Dictionary:
	if js_ysdk_player == null: 
		if _print_debug: print("%s getData_yield() js_ysdk_player == null"%[_print])
		return {}
	var result:Dictionary
	getData()
	await _getData
	result = _get_data
	_get_data = {}
	return result

func _callback_getData(args:Array):
	if _print_debug: 
		print("js_callback_getData(args:%s)"%[args])
		js_console.log(args[0])
	var data:Dictionary
	var json:= JSON.new()
	if args[0].hasOwnProperty('json_data'):
		json.parse(args[0]["json_data"])
		data = json.data
	if _print_debug: print("js_callback_getData data: ", data)
	_get_data = data
	_getData.emit(data)
#endregion
#endregion


#region In-game purchases
# https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#install
#region getPayments()
func getPayments():
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("Object")
	js_dictionary["signed"] = true
	js_ysdk.getPayments(js_dictionary).then(js_callback_getPayments_then).catch(js_callback_getPayments_catch)

func _callback_getPayments_then(args:Array):
	if _print_debug: 
		print("js_callback_getPayments_then args: ", args)
		js_console.log(args[0])
	js_ysdk_payments = args[0]
	_getPayments.emit(js_ysdk_payments)

func _callback_getPayments_catch(args:Array):
	if _print_debug: 
		print("js_callback_getPayments_catch args: ", args)
		js_console.log(args[0])
#endregion

#region purchase()
# https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#payments-purchase
func purchase(id:String):
	if js_ysdk_payments == null:
		if _print_debug: print("%s purchase(id:%s) js_ysdk_payments == null"%[_print, id])
		return
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("Object")
	js_dictionary["id"] = id
	_current_purchase_product_id = id
	now_purchase = true
	js_ysdk_payments.purchase(js_dictionary).then(js_callback_purchase_then).catch(js_callback_purchase_catch)

func _callback_purchase_then(args:Array):
	if _print_debug: 
		print("js_callback_purchase_then args: ", args)
		js_console.log(args[0])
	var _purchase = args[0]
	var purchase_result = Purchase.new(_purchase)
	now_purchase = false
	_purchase_then.emit(purchase_result)

func _callback_purchase_catch(args:Array):
	if _print_debug: 
		print("js_callback_purchase_catch args: ", args)
		js_console.log(args[0])
	var copy_current_purchase_product_id = _current_purchase_product_id
	_current_purchase_product_id = ""
	now_purchase = false
	_purchase_catch.emit(copy_current_purchase_product_id)

# return [Purchase]
func getPurchases_yield() -> Array:
	if js_ysdk_payments == null:
		if _print_debug: printerr("%s getPurchases js_ysdk_payments == null"%[_print])
	getPurchases()
	await _getPurchases
	return _current_get_purchases_then

func getPurchases():
	if js_ysdk_payments == null:
		if _print_debug: print("%s getPurchases js_ysdk_payments == null"%[_print])
		return
	js_ysdk_payments.getPurchases().then(js_callback_getPurchases_then).catch(js_callback_getPurchases_catch)

func _callback_getPurchases_then(args:Array):
	if _print_debug:
		js_console.log(_print, " js_callback_getPurchases_then(args: ", args[0], ")")
	var result:Array = []
	for id in args[0].length:
		result.append(Purchase.new(args[0][id]))
	_current_get_purchases_then = result
	_getPurchases.emit(result)

func _callback_getPurchases_catch(args:Array):
	if _print_debug:
		js_console.log(_print, " js_callback_getPurchases_catch(args: ", args[0], ")")
	_current_get_purchases_then = null
	_getPurchases.emit(null)
#endregion

#endregion


#region Leaderboards
#https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard
#region getLeaderboards()
func getLeaderboards():
	js_ysdk_lb = js_ysdk.getLeaderboards().then(js_callback_getLeaderboards)

func _callback_getLeaderboards(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboards(args:%s)"%[_print, args])
		js_console.log(args[0])
	js_ysdk_lb = args[0]
	_getLeaderboards.emit()
#endregion

#region getLeaderboardDescription()
#https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#description
func getLeaderboardDescription(leaderboardName:String):
	if js_ysdk_lb == null:
		if _print_debug: print("%s getLeaderboardDescription(leaderboardName:%s) js_ysdk_lb == null"%[_print, leaderboardName])
		return
	js_ysdk_lb.getLeaderboardDescription(leaderboardName).then(js_callback_getLeaderboardDescription)

func js_LeaderboardDescription_to_Dictionary(object:JavaScriptObject) -> Dictionary:
	var description:Dictionary = {'appID':'null', 'default':false, 'invert_sort_order':false, 'decimal_offset':-1, 'type':'null', 'name':'null', 'title':{}}
	description['appID'] = object['appID']
	description['default'] = object['default']
	description['invert_sort_order'] = object['description']['invert_sort_order']
	description['decimal_offset'] = object['description']['score_format']['options']['decimal_offset']
	description['type'] = object['description']['score_format']['type']
	description['name'] = object['name']
	var js_Object = JavaScriptBridge.get_interface("Object") as JavaScriptObject
	var js_ArrayKeys = js_Object.keys(object['title'])
	for key_id in js_ArrayKeys.length:
		var key = js_ArrayKeys[key_id]
		description['title'][key] = object['title'][key]
	return description



func _callback_getLeaderboardDescription(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboardDescription(args:%s)"%[_print, args])
		js_console.log(args[0])
	var js_desc:JavaScriptObject = args[0]
	var description:Dictionary = js_LeaderboardDescription_to_Dictionary(js_desc)
	if _print_debug: print("%s, js_callback_getLeaderboardDescription() description:%s"%[_print, description])
	_getLeaderboardDescription.emit(description)
#endregion

#region setLeaderboardScore()
#https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#set-score
func setLeaderboardScore(leaderboardName:String, score:int):
	if js_ysdk_lb == null:
		if _print_debug: print("%s setLeaderboardScore(leaderboardName:%s, score:%s) js_ysdk_lb == null"%[_print, leaderboardName, score])
		return
	_current_isAvailableMethod = 'leaderboards.setLeaderboardScore'
	js_ysdk.isAvailableMethod('leaderboards.setLeaderboardScore').then(js_callback_isAvailableMethod)
	await _isAvailableMethod
	if _current_isAvailableMethod_result == true:
		js_ysdk_lb.setLeaderboardScore(leaderboardName, score)
		if _print_debug: print("%s setLeaderboardScore() js_ysdk_lb.setLeaderboardScore(leaderboardName:%s, score:%s) request"%[_print, leaderboardName, score])
	elif _print_debug: print("%s setLeaderboardScore() js_ysdk_lb.setLeaderboardScore(leaderboardName:%s, score:%s) isAvailableMethod('leaderboards.setLeaderboardScore') == false"%[_print, leaderboardName, score])

func _callback_isAvailableMethod(args:Array):
	if _print_debug: print("%s js_callback_isAvailableMethod(args:%s)"%[_print, args])
	_current_isAvailableMethod_result = args[0]
	_isAvailableMethod.emit(_current_isAvailableMethod_result, _current_isAvailableMethod)
#endregion

#region getLeaderboardPlayerEntry()
#https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#get-entry 
func js_LeaderboardPlayerEntry_to_Dictionary(object:JavaScriptObject) -> Dictionary:
	var response:Dictionary = {'score':-1, 'extraData':'null', 'rank':-1, 'getAvatarSrc':'null', 'getAvatarSrcSet':'null', 'lang':'null', 'publicName':'null', 'uniqueID':'null', 'scopePermissions_avatar':'null', 'scopePermissions_public_name':'null', 'formattedScore':'null'}
	response['score'] = object['score']
	response['extraData'] = object['player']
	response['rank'] = object['rank']
	response['getAvatarSrc'] = object['player']['getAvatarSrc']
	response['getAvatarSrcSet'] = object['player']['getAvatarSrcSet']
	response['lang'] = object['player']['lang']
	response['publicName'] = object['player']['publicName']
	response['scopePermissions_avatar'] = object['player']['scopePermissions']['avatar']
	response['scopePermissions_public_name'] = object['player']['scopePermissions']['public_name']
	response['uniqueID'] = object['player']['uniqueID']
	response['formattedScore'] = object['formattedScore']
	return response


func getLeaderboardPlayerEntry(leaderboardName:String):
	if js_ysdk_lb == null:
		if _print_debug: print("%s getLeaderboardDescription(leaderboardName:%s) js_ysdk_lb == null"%[_print, leaderboardName])
		return
	_current_isAvailableMethod = 'leaderboards.getLeaderboardPlayerEntry'
	js_ysdk.isAvailableMethod('leaderboards.getLeaderboardPlayerEntry').then(js_callback_isAvailableMethod)
	await _isAvailableMethod
	if _current_isAvailableMethod_result:
		js_ysdk_lb.getLeaderboardPlayerEntry(leaderboardName).then(js_callback_getLeaderboardPlayerEntry_then).catch(js_callback_getLeaderboardPlayerEntry_catch)

func _callback_getLeaderboardPlayerEntry_then(args:Array):
	if _print_debug:
		print("%s js_callback_getLeaderboardPlayerEntry_then(args:%s)"%[_print, args])
		js_console.log(args[0])
	var js_response:JavaScriptObject = args[0]
	var response:Dictionary = js_LeaderboardPlayerEntry_to_Dictionary(js_response)
	if _print_debug: print("%s js_callback_getLeaderboardPlayerEntry_then() response:%s"%[_print, response])
	_getLeaderboardPlayerEntry_then.emit(response)

func _callback_getLeaderboardPlayerEntry_catch(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboardPlayerEntry_catch(args:%s)"%[_print, args])
		js_console.log(args[0])
	_getLeaderboardPlayerEntry_catch.emit(args[0].code)
#endregion

#region getLeaderboardEntries()
#https://yandex.ru/dev/games/doc/ru/sdk/sdk-leaderboard#get-entries
func getLeaderboardEntries(leaderboardName:String):
	if js_ysdk_lb == null:
		if _print_debug: print("%s getLeaderboardEntries(leaderboardName:%s) js_ysdk_lb == null"%[_print, leaderboardName])
		return
	var js_dictionary:JavaScriptObject = JavaScriptBridge.create_object("object")
	js_dictionary["quantityTop"] = 20
	js_dictionary["quantityAround"] = 10
	js_dictionary["includeUser"] = true
	js_ysdk_lb.getLeaderboardEntries(leaderboardName, js_dictionary).then(js_callback_getLeaderboardEntries_then)

func _callback_getLeaderboardEntries_then(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboardEntries_then(args:%s)"%[_print, args])
		js_console.log(args[0])
	var response:Dictionary = {'leaderboard': {}, 'userRank':-1, 'entries':[]}
	response['leaderboard'] = js_LeaderboardDescription_to_Dictionary(args[0]['leaderboard'])
	response['userRank'] = args[0]['userRank']
	for js_Object_id in args[0]['entries'].length:
		response['entries'].append(js_LeaderboardPlayerEntry_to_Dictionary(args[0]['entries'][js_Object_id]))
	if _print_debug: print("%s js_callback_getLeaderboardEntries_then() response:%s"%[_print, response])
	_getLeaderboardEntries.emit(response)

func _callback_getLeaderboardEntries_catch(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboardEntries_catch(args:%s)"%[_print, args])
		js_console.log(args[0])

#endregion

#endregion


#region Game rating
# https://yandex.ru/dev/games/doc/en/sdk/sdk-review
#region canReview()
func canReview():
	js_ysdk.feedback.canReview().then(js_callback_canReview)

func _canReview_await():
	var result:bool 
	canReview()
	await _canReview
	result = _current_canReview
	return result

func _callback_canReview(args:Array):
	if _print_debug: 
		print("%s js_callback_canReview(args:%s)"%[_print, args])
		js_console.log(args[0])
	if args[0]["value"]:
		if _print_debug: 
			print("%s js_callback_canReview(args:%s) canReview == true"%[_print, args])
		_current_canReview = true
		_canReview.emit(true)
	else:
		if _print_debug: 
			print("%s js_callback_canReview(args:%s) canReview == false"%[_print, args])
			js_console.log(args[0]["reason"])
		_current_canReview = false
		_canReview.emit(false)
#endregion

#region requestReview()
func requestReview():
	canReview()
	await _canReview
	if _current_canReview:
		now_review = true
		js_ysdk.feedback.requestReview().then(js_callback_requestReview)
	elif _print_debug: print("%s requestReview() _current_canReview = false"%[_print])

func _callback_requestReview(args:Array):
	if _print_debug: 
		print("%s js_callback_requestReview(args:%s)"%[_print, args])
		js_console.log(args[0])
	now_review = false
	_requestReview.emit(args[0])
#endregion

#endregion


#region Desktop shortcut
# https://yandex.ru/dev/games/doc/en/sdk/sdk-shortcut
#region canShowPrompt()
func canShowPrompt():
	js_ysdk.shortcut.canShowPrompt().then(js_callback_canShowPrompt)

func _callback_canShowPrompt(args:Array):
	if _print_debug: 
		print("%s js_callback_canShowPrompt(args:%s)"%[_print, args])
		js_console.log(args[0].canShow)
	_current_canShowPrompt = args[0].canShow
	_canShowPrompt.emit(_current_canShowPrompt)

func canShowPrompt_await():
	var result:bool
	canShowPrompt()
	await _canShowPrompt
	result = _current_canShowPrompt
	return result
#endregion

#region showPrompt()
func showPrompt():
	canShowPrompt()
	await _canShowPrompt
	if _current_canShowPrompt:
		js_ysdk.shortcut.showPrompt().then(js_callback_showPrompt)
	elif _print_debug: print("%s showPrompt() _current_canShowPrompt = false"%[_print])

func _callback_showPrompt(args:Array):
	if _print_debug: 
		print("%s js_callback_showPrompt(args:%s)"%[_print, args])
		js_console.log(args[0].outcome)
	_showPrompt.emit(args[0].outcome == 'accepted')
#endregion

#endregion


#region clientFeatures
#clientFeatures = [{"name":String, value:String}]
func getFlags(clientFeatures:Array = []):
	if clientFeatures.size() == 0:
		js_ysdk.getFlags().then(js_callback_getFlags_then).catch(js_callback_getFlags_catch)
	else:
		var js_array:JavaScriptObject = JavaScriptBridge.create_object("Array")
		for dictionary in clientFeatures:
			if dictionary is Dictionary:
				var js_object = JavaScriptBridge.create_object("Object")
				js_object["name"] = str(dictionary["name"])
				js_object["value"] = str(dictionary["value"])
				js_array.push(js_object)
		if _print_debug: js_console.log("YandexGames, getFlags(), js_array:", js_array)
		if js_array.length == 0: 
			js_ysdk.getFlags().then(js_callback_getFlags_then).catch(js_callback_getFlags_catch)
		else:
			var js_object = JavaScriptBridge.create_object("Object")
			js_object["clientFeatures"] = js_array
			js_ysdk.getFlags(js_object).then(js_callback_getFlags_then).catch(js_callback_getFlags_catch)

func _callback_getFlags_catch(args:Array):
	if _print_debug:
		print("%s js_callback_getFlags_catch(args:%s)"%[_print, args])
		js_console.log(args[0])
	_current_getFlags = args[0]
	_getFlags.emit(args[0])

func _callback_getFlags_then(args:Array):
	if _print_debug:
		print("%s js_callback_getFlags_then(args:%s)"%[_print, args])
		js_console.log(args[0])
	var js_Object = JavaScriptBridge.get_interface("Object")
	var js_ArrayKeys = js_Object.keys(args[0])
	_current_getFlags = {}
	for key_id in js_ArrayKeys.length:
		var key = js_ArrayKeys[key_id]
		_current_getFlags[key] = args[0][key]
	_getFlags.emit(_current_getFlags)

# clientFeatures = [{"name":String, value:String}]
# return Dictionary OR js error
func getFlags_await(clientFeatures:Array = []):
	getFlags(clientFeatures)
	await _getFlags
	return _current_getFlags

#endregion


# return user lang - en/ru/tr/...
func getLang() -> String:
	var result:String
	if js_ysdk_player == null:
		result = js_ysdk.environment.i18n.lang
		if _print_debug: print("%s getLang() js_ysdk_player == null, result: %s"%[_print, result])
		return result
	else:
		result = js_ysdk_player._personalInfo.lang
		if _print_debug: print("%s getLang() result: %s"%[_print, result])
	return result
