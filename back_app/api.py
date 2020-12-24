import flask
from flask import request, jsonify, send_from_directory
from flask_cors import CORS, cross_origin
from entities import Feeder, User, logsToFile, timeTableToFile #TimeTable
import entities
import json

app = flask.Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

users = entities.loadUsers()
feeders = entities.loadFeeders()
entities.syncFeeders(users, feeders)

@app.route('/', methods=['GET'])
@cross_origin()
def home():
  global users

  result = {"users": [user.listingView() for user in users]}

  return jsonify(result)

@app.route('/users', methods=['GET'])
def api_allUsers():
  global users
  return jsonify({"users" : [user.currentStateToDict() for user in users]})

@app.route('/users/new', methods = ['GET'])
def api_newUser():
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

@app.route('/users/', methods = ['GET', 'POST', 'DELETE'])
def api_userId():
  global users

  if 'userId' in request.args:
    userId = int(request.args['userId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if request.method == 'GET':
    """return the information for some user"""
    for user in users:
      if (user.getUserId() == int(userId)):
        result = user.currentStateToDict()
        return jsonify(result)

    return "User not found"
   
  if request.method == 'POST':
    """modify name for specfied user"""
    
    userId = int(request.args['id'])
    name = request.args['name']

    for user in users:
      if (user.getUserId()==userId):
        user.setName(name)
        return "Username changed"
    return "User not found"
     
  if request.method == 'DELETE':
    """delete user with userId"""
    if 'userId' in request.args:
      userId = int(request.args['userId'])
    else:
      return "Error: No id field provided. Please specify an id."

    for user in users:
      if (user.getUserId()==int(userId)):
        users.remove(user)
        user.delete()
        return "User deleted"
    return "User not found"

@app.route('/users/logs', methods = ['GET'])
def api_userLogs():
  global users

  if 'userId' in request.args:
    userId = int(request.args['userId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if request.method == 'GET':
    """return the information for some user"""
    """TODO: add time option"""
    for user in users:
      if (user.getUserId() == int(userId)):
        result = user.getAllUserLogs()
        return jsonify(result)

    return "User not found"


@app.route('/feeders/', methods=['GET', 'POST', 'DELETE'])
def api_UserFeeders():
  global users

  if 'userId' in request.args:
    userId = int(request.args['userId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if request.method == 'GET':
    for user in users:
      if (user.getUserId()==userId):
        return jsonify({"feeders" : user.feedersCurrentStateToList()})
    return "User not found"

  if request.method == 'POST':
    """modify fields for specfied feeder"""
    # r = json.loads(str(request.form.to_dict())[2:-6])
    if ('feedingAmount' in request.args and 'feederId' in request.args):
      amount = int(request.args['feedingAmount'])
      for user in users:
        if (user.getUserId()==userId):
          user.getFeederById(int(request.args['feederId'])).feed(amount)
          return "Feed OK"

    if (int(request.args['feederId']) == -1):
      feeder_fields = {
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
        if (user.getUserId()==userId):
          feeder = Feeder(feeder_fields)
          user.addFeeder(feeder)
          feeder.saveToDB()
          return "Feeder added"
      return "User not found"
    else:
      feeder_fields = {
        'labels': str(request.args['labels']),
        'labelsState': str(request.args['labelsState']),
        'userId': int(userId),
        'feederType': str(request.args['feederType']),
        'timeTable': str(request.args['timeTable']),
        'capacity': int(request.args['capacity']),
        'filledInternally': int(request.args['filledInternally']),
        'filledExternally': int(request.args['filledExternally']),
        'feederId': int(request.args['feederId'])
      }

      for user in users:
        if (user.getUserId()==userId):
          feeder = user.getFeederById(int(feeder_fields['feederId']))
          if (int(feeder_fields['userId'])==userId):
            feeder.set(feeder_fields)
          else:
            user.removeFeederById(int(feeder_fields['feederId']))
            for user in users:
              if (user.getUserId()==int(feeder_fields['feederId'])):
                feeder = user.getFeederById(int(feeder_fields['feederId']))
          return "Feeder changed"
      return "User not found"

  if request.method == 'DELETE':
    """delete user with userId"""

    if 'userId' in request.args and 'feederId' in request.args:
      userId = int(request.args['userId'])
      feederId = int(request.args['feederId'])
    else:
      return "Error: No id field provided. Please specify an id."

    for user in users:
      if (user.getUserId()==userId):
        user.removeFeederById(feederId)
        return "feeder deleted"
    return "User not found"

@app.route('/feeders/logs', methods=['GET'])
def api_FeederLogs():
  global users

  if 'userId' in request.args and 'feederId' in request.args:
    userId = int(request.args['userId'])
    feederId = int(request.args['feederId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if request.method == 'GET':
    for user in users:
      if (user.getUserId()==userId):
        return jsonify(user.getFeederById(feederId).getAllFeederLogs())
    return "Feeder or user not found"

@app.route('/exportLogs', methods=['GET'])
def s():
  global users

  if 'userId' in request.args and 'feederId' in request.args:
    userId = int(request.args['userId'])
    feederId = int(request.args['feederId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if feederId == -1:
    for user in users:
      if (userId == user.getUserId()):
        logs = user.getAllUserLogs()
        logsToFile(logs)
        return send_from_directory('', 'exportFile.txt', as_attachment=True)
  else:
    for user in users:
      if (userId == user.getUserId()):
        logs = user.getFeederById(feederId).getAllFeederLogs()
        logsToFile(logs)
        return send_from_directory('', 'exportFile.txt', as_attachment=True)
  
  return "User or feeder not found"

@app.route('/exportTimeTables', methods=['GET'])
def api_getLogs():
  global users

  if 'userId' in request.args and 'feederId' in request.args:
    userId = int(request.args['userId'])
    feederId = int(request.args['feederId'])
  else:
    return "Error: No id field provided. Please specify an id."

  if feederId != -1:
    for user in users:
      if (userId == user.getUserId()):
        timeTable = user.getFeederById(feederId).getTimeTable()
        timeTableToFile(timeTable)
        return send_from_directory('', 'exportFile.txt', as_attachment=True)
  
  return "User or feeder not found"