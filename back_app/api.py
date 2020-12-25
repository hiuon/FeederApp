import flask
from flask import request, jsonify, send_from_directory
from flask_cors import CORS, cross_origin
import router

app = flask.Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route('/', methods=['GET'])
@cross_origin()
def home():
  return router.getUsersListing()

@app.route('/users', methods=['GET'])
def api_allUsers():
  return router.getUsersCurrentState()

@app.route('/users/new', methods = ['GET'])
def api_newUser():
  return router.addUser(request)

@app.route('/users/', methods = ['GET', 'POST', 'DELETE'])
def api_userId():
  return router.userRoutes(request)

@app.route('/users/logs', methods = ['GET'])
def api_userLogs():
  return router.userLogs(request)

@app.route('/feeders/', methods=['GET', 'POST', 'DELETE'])
def api_UserFeeders():
  return router.feederRoutes(request)

@app.route('/feeders/logs', methods=['GET'])
def api_FeederLogs():
  return router.feederLogs(request)

@app.route('/exportLogs', methods=['GET'])
def api_getLogs():
  return router.exportLogs(request)

@app.route('/exportTimeTables', methods=['GET'])
def api_getTimeTable():
  return router.getTimeTable(request)
