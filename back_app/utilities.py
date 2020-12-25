from datetime import datetime

timings = [
	'00:00',
	'03:00',
	'06:00',
	'09:00',
	'12:00',
	'15:00',
	'18:00',
	'21:00'
	]
exportFilename = 'exportFile'


def shiftedToTheLeft(text, size):
	if len(text)!=size:
		text += " "*(size-len(text))
	return text

def logToRow(log):
	columnLength = 20
	row = shiftedToTheLeft(str(log['logId']),columnLength)
	row += shiftedToTheLeft(log['logType'], columnLength)
	row += shiftedToTheLeft(log['logMessage'],45)
	row += shiftedToTheLeft(str(log['userId']),columnLength)
	row += shiftedToTheLeft(str(log['feederId']),columnLength)
	row += shiftedToTheLeft(log['timeStamp'],columnLength)
	return row

def decodeTimeTable(value):
	values = value.split('__')
	value = ''
	result = ''
	for value, index in zip(values, range(len(values))):
		print(value, index)
		if value=='1':
			result += timings[index] + ' '

	return result

def timeTableToFile(value):
	global exportFilename
	exportFilename = 'exportFile-'+str(datetime.now().strftime("%Y_%m_%d_%H_%M_%S"))+'.txt'
	with open(exportFilename,'w+') as f:
		f.write(decodeTimeTable(value))
		f.close()

def fileToTimetable(filepath):
	with open(filepath, 'r') as f:
		values = f.read().split(" ")
		timeTable = ''
		
		for value in values:
			if value in timings:
				timeTable += '1__'
			else:
				timeTable += '0__'
		timeTable = timeTable[:-2]
	return timeTable

def logsToFile(logs):
	global exportFilename
	head = ['logId', 'logType', 'logMessage', 'userId', 'feederId', 'timeStamp']
	row = ''
	for item in head:
		if (item == 'logMessage'): 
			row += shiftedToTheLeft(item, 45)
		else: 
			row += shiftedToTheLeft(item, 20)
	exportFilename = 'exportFile-'+str(datetime.now().strftime("%Y_%m_%d_%H_%M_%S"))+'.txt'
	with open(exportFilename,'w+') as f:
		f.write(row)
		f.write('\n')
		for log in logs:
			f.write(logToRow(log)+'\n')
		f.close()

def datetimeToStr(datetime):
	result = ''
	result += datetime[0][datetime[0].find('(')+1:]
	
	for value in datetime[1:3]:
		if int(value)>=10:
			result += '-' + value
		else: 
			result += '-0' + value

	if int(datetime[3])>=10:
		result += ' ' + datetime[3]
	else: 
		result += ' ' + datetime[3]

	for value in datetime[4:-1]:
		if int(value)>=10:
			result += ':' + value
		else: 
			result += ':0' + value

	result += '.' + datetime[-1][:-1]

	return result

def safeIntForDB(value):
	if value == 'None':
		return -1
	else:
		return int(value)

def getCurrentHour():
	return int(datetime.now().strftime('%H'))

def getCurrentMinute():
	return int(datetime.now().strftime('%M'))

def timeForFeeding():
	for timing in timings:
		hour, minute = int(timing.split(":")[0]), int(timing.split(":")[1])

		if getCurrentHour() == hour and getCurrentMinute() == minute:
			return True
	return False

def needToFeed(timeTable, k):
	feedTimings = timeTable.split("__")
	if feedTimings[k]=='1':
		return True 
	else:
		return False