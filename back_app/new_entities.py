import flask
from flask import jsonify

class Feeder:
    feederId = 0
    name = "name"
    labels = []
    stateLabels = []
    userId = 0
    feederType = 'normal'
    timeTable = 'table'
    capacity = 100
    filledInternally = 14
    filledExternally = 42

    FEEDER_FEEDING_OK = 'FEEDER_FEEDING_OK'
    FEEDER_FEEDING_FAIL = 'FEEDER_FEEDING_FAIL'
    FEEDER_PING_OK = 'FEEDER_PING_OK'
    FEEDER_PING_FAIL = 'FEEDER_PING_FAIL'
    FEEDER_EATING_OK = 'FEEDER_EATING_OK'
    FEEDER_EATING_FAIL = 'FEEDER_EATING_FAIL'

    def __init__(self, name, userId, feederType):
        self.name = name 
        self.userId = userId
        self.feederType = feederType
        self.capacity = 100
        self.filledInternally = 100
        self.filledExternally = 0

    def addLabel(self, label):
        self.labels.append(label)
        self.stateLabels.append(False)

    def feed(self):
        self.filledInternally -= 5
        self.filledInternally += 10
    
    def deleteLabel(self):
        self.labels.pop
        self.stateLabels.pop

    def setTimeTable(self, newTimeTable):
        self.timeTable = newTimeTable

    def currentStateToJSON(self):
        feeder = [
			{'feederId': self.feederId,
			 'labels': self.labels,
             'stateLabels': self.stateLabels,
			 'userId': self.userId,
			 'feederType': self.feederType,
			 'timeTable': self.timeTable,
			 'capacity': self.capacity,
			 'filledInernally': self.filledInternally,
			 'filledExternally': self.filledExternally
			}
		]
       	return jsonify(feeder)

class User:
    userId = 0
    feeders = []
    timeTables = []

    def addTimeTable(self, timeTable):
    	self.timeTables.add(timeTable)

    def dropTimeTable(self, timeTable):
    	self.timeTables.drop(timeTable)

    def addFeeder(self, feeder):
    	self.feeders.add(feeder)

    def dropFeeder(self, feeder):
    	self.feeders.drop(feeder)
    
    def currentStateToJSON(self):
        user = [
			{'feederId': self.feederId,
			 'labels': self.labels,
             'stateLabels': self.stateLabels,
			 'userId': self.userId
			}
		]
        return jsonify(feeder)