from entities import Feeder, User, loadUsers, loadFeeders, syncFeeders
from utilities import logsToFile, timeTableToFile
import json
from flask import jsonify, send_from_directory


users = loadUsers()
feeders = loadFeeders()
syncFeeders(users, feeders)

def getUsersListing():
	global users
	result = {"users": [user.listingView() for user in users]}
	return jsonify(result)

def getUsersCurrentState():
	global users
	return jsonify({"users" : [user.currentStateToDict() for user in users]})

def addUser(request):
	global users

	if 'name' in request.args:
		name = str(request.args['name'])
	else:
		return "Error: No name field provided. Please specify an name."

	if request.method == 'GET':
   		"""return the information for some user"""
	   	user = User(name)
	   	users.append(user)
	   	user.saveToDB()
	   	return "User created"

def getUser(userId):
	global users
	for user in users:
		if (user.getUserId() == int(userId)):
			result = user.currentStateToDict()
			return jsonify(result)
	return "User not found"


def changeUsername(userId, name):
	global users
	for user in users:
		if (user.getUserId() == userId):
			user.setName(name)
			return 'Username changed'
	return "User not found"

def deleteUser(userId):
	global users
	for user in users:
		if (user.getUserId() == userId):
			users.remove(user)
			user.delete()
			return 'User deleted'
	return 'User not found'

def getUserLogs(userId):
	global users
	for user in users:
		if (user.getUserId() == int(userId)):
			result = user.getAllUserLogs()
			return jsonify(result)
	return "User not found"

def userRoutes(request):
	if 'userId' in request.args:
		userId = int(request.args['userId'])
	else:
		return "Error: No id field provided. Please specify an id."

	if request.method == 'GET':
		return getUser(userId)
	elif request.method == 'POST' and 'name' in request.args:
		return changeUsername(userId, request.args['name'])
	elif request.method == 'DELETE':
		return deleteUser(userId)

def userLogs(request):
	global users
	if 'userId' in request.args:
		userId = int(request.args['userId'])
	else:
		return "Error: No id field provided. Please specify an id."

	if request.method == 'GET':
		return getUserLogs(userId)

def getUserFeeders(userId):
	global users
	for user in users:
		if (user.getUserId()==userId):
			return jsonify({"feeders" : user.feedersCurrentStateToList()})
	return "User not found"

def addFeeder(request):
	global users
	feeder_fields = feeder_fields = {
	    'labels': str(request.args['labels']),
	    'labelsState': str(request.args['labelsState']),
	    'userId': int(request.args['userId']),
	    'feederType': str(request.args['feederType']),
	    'timeTable': str(request.args['timeTable']),
	    'capacity': int(request.args['capacity']),
	    'filledInternally': int(request.args['filledInternally']),
	    'filledExternally': int(request.args['filledExternally'])
    }
	for user in users:
		if (user.getUserId()==int(request.args['userId'])):
			feeder = Feeder(feeder_fields)
			user.addFeeder(feeder)
			feeder.saveToDB()
			return "Feeder added"
	return "User not found"

def changeFeeder(request):
	global users
	feeder_fields = {
	    'labels': str(request.args['labels']),
	    'labelsState': str(request.args['labelsState']),
	    'userId': int(request.args['userId']),
	    'feederType': str(request.args['feederType']),
	    'timeTable': str(request.args['timeTable']),
	    'capacity': int(request.args['capacity']),
	    'filledInternally': int(request.args['filledInternally']),
	    'filledExternally': int(request.args['filledExternally']),
	    'feederId': int(request.args['feederId'])
	}

	for user in users:
		if (user.getUserId()==int(request.args['userId'])):
			feeder = user.getFeederById(int(feeder_fields['feederId']))
			if (int(feeder_fields['userId'])==int(request.args['userId'])):
				feeder.set(feeder_fields)
			#really strange case need to fix it
			else:
				user.removeFeederById(int(feeder_fields['feederId']))
				for user in users:
	  				if (user.getUserId()==int(feeder_fields['feederId'])):
						  feeder = user.getFeederById(int(feeder_fields['feederId']))
			return "Feeder changed"
	return "User not found"

def deleteFeeder(userId, feederId):
	global users
	for user in users:
		if (user.getUserId()==userId):
			user.removeFeederById(feederId)
			return 'feeder deleted'
	return 'User not found'

def feedByFeeder(userId, feederId, amount):
	global users
	for user in users:
		if (user.getUserId()==userId):
			user.getFeederById(feederId).feed(amount)
			return "Feed OK"
	return 'Feeder or user not found'

def postFeederRoutes(request):
	if ('feedingAmount' in request.args and 'feederId' in request.args):
		return feedByFeeder(int(request.args['userId']), int(request.args['feederId']), int(request.args['feedingAmount']))

	elif (int(request.args['feederId']) == -1):
		return addFeeder(request)
	else:
		return changeFeeder(request)

def feederRoutes(request):
	if 'userId' in request.args:
		userId = int(request.args['userId'])
	else:
		return "Error: No id field provided. Please specify an id."

	if request.method == 'GET':
		return getUserFeeders(userId)
	elif request.method == 'POST':
		return postFeederRoutes(request)
	elif request.method == 'DELETE' and 'feederId' in request.args:
		return deleteFeeder(userId, int(request.args['feederId']))

def exportUserLogs(userId):
	global users
	for user in users:
		if (userId==user.getUserId()):
			logsToFile(user.getAllUserLogs())
			return send_from_directory('', 'exportFile.txt', as_attachment=True)
	return "User or feeder not found"

def exportFeederLogs(userId, feederId):
	global users
	for user in users:
		if (userId==user.getUserId()):
			logsToFile(user.getFeederById(feederId).getAllFeederLogs())
			return send_from_directory('', 'exportFile.txt', as_attachment=True)
	return "User or feeder not found"

def getFeederLogs(userId, feederId):
	global users
	for user in users:
		if (user.getUserId() == int(userId)):
			result = {'logs' : user.getFeederById(feederId).getAllFeederLogs()}
			return jsonify(result)
	return "User or feeder not found"

def feederLogs(request):
	if 'userId' in request.args and 'feederId' in request.args:
		userId = int(request.args['userId'])
		feederId = int(request.args['feederId'])
	else:
		return "Error: No id field provided. Please specify an id."
	
	if request.method == 'GET':
		return getFeederLogs(userId, feederId)

def exportLogs(request):
	if 'userId' in request.args and 'feederId' in request.args:
		userId = int(request.args['userId'])
		feederId = int(request.args['feederId'])
	else:
		return "Error: No id field provided. Please specify an id."

	if feederId == -1:
		return exportUserLogs(userId)
	else:
		return exportFeederLogs(userId,feederId)

def getTimeTable(request):
	global users
	if 'userId' in request.args and 'feederId' in request.args:
		userId = int(request.args['userId'])
		feederId = int(request.args['feederId'])
	else:
		return "Error: No id field provided. Please specify an id."

	for user in users:
		if (userId == user.getUserId()):
			timeTable = user.getFeederById(feederId).getTimeTable()
			timeTableToFile(timeTable)
			return send_from_directory('', 'exportFile.txt', as_attachment=True)
	return 'User or feeder not found'