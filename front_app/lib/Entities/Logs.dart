class Log {
  int feederId;
  int logId;
  String logMessage;
  String logType;
  String timeStamp;
  int userId;

  Log(
      {this.feederId,
      this.logId,
      this.logMessage,
      this.logType,
      this.timeStamp,
      this.userId});

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
        feederId: json["feederId"] as int,
        logId: json["logId"] as int,
        logMessage: json["logMessage"] as String,
        logType: json["logType"] as String,
        timeStamp: json["timeStamp"] as String,
        userId: json["userId"] as int);
  }

  static String setWidth(String string, int size) {
    //int temp = size - string.length;
    StringBuffer str = new StringBuffer(string);
    for (int i = 0; i < 3; i++) {
      str.write("  ");
    }
    str.write("|");
    return str.toString();
  }

  static String logToString(List<Log> logs) {
    StringBuffer temp = new StringBuffer();
    temp.write(setWidth("feederId", 15) +
        setWidth("logId", 10) +
        setWidth("logMessage", 45) +
        setWidth("logType", 15) +
        setWidth("timeStamp", 20) +
        setWidth("userId", 10) +
        "\n");
    for (Log log in logs) {
      temp.write(setWidth(log.feederId.toString(), 15) +
          setWidth(log.logId.toString(), 10) +
          setWidth(log.logMessage, 45) +
          setWidth(log.logType, 15) +
          setWidth(log.timeStamp, 20) +
          setWidth(log.userId.toString(), 10) +
          "\n");
    }
    return temp.toString();
  }
}
