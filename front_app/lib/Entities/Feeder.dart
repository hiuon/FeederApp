class Feeder {
  int feederId;
  int userId;
  List<bool> labelsState;
  List<String> labels;
  String feederType;
  List<String> timeTable;
  String logs;
  int capacity;
  int filledInernally;
  int filledExternally;

  Feeder(
      {this.feederId,
      this.labels,
      this.feederType,
      this.labelsState,
      this.timeTable,
      this.capacity,
      this.filledExternally,
      this.filledInernally,
      this.logs});

  factory Feeder.fromJson(Map<String, dynamic> json) {
    print("////////");
    print(json);
    return Feeder(
        feederId: json["feederId"] as int,
        labels: (json["labels"] as String).split("__"),
        feederType: (json["feederType"] as String).toString(),
        timeTable: (json["timeTable"] as String).split("__"),
        capacity: json["capacity"] as int,
        filledExternally: json["filledExternally"] as int,
        filledInernally: json["filledInternally"] as int,
        logs: log(),
        labelsState:
            fromStringToBool((json["labelsState"] as String).split("__")));
  }

  static String log() {
    return "test information...........................................еуые";
  }

  static List<bool> fromStringToBool(List<String> state) {
    List<bool> stateL = new List<bool>();
    for (String i in state) {
      if (i == "false") {
        stateL.add(false);
      } else {
        stateL.add(true);
      }
    }
    return stateL;
  }

  static String removeLabel(Feeder feeder) {
    StringBuffer newTimeTable = new StringBuffer();
    StringBuffer newLabels = new StringBuffer();
    StringBuffer newLabelsState = new StringBuffer();
    if (feeder.labels.isEmpty != true) {
      for (int i = 0; i < feeder.labels.length - 1; i++) {
        if (i == feeder.labels.length - 2) {
          newLabels.write(feeder.labels[i]);
          newLabelsState.write(feeder.labelsState[i].toString());
        } else {
          newLabels.write(feeder.labels[i] + "__");
          newLabelsState.write(feeder.labelsState[i].toString() + "__");
        }
      }
    }
    if (newLabels.toString() == "__") {
      newLabels = new StringBuffer();
      newLabelsState = new StringBuffer();
    }

    for (int i = 0; i < feeder.timeTable.length; i++) {
      if (i != feeder.timeTable.length - 1) {
        newTimeTable.write(feeder.timeTable[i] + "__");
      } else {
        newTimeTable.write(feeder.timeTable[i]);
      }
    }

    return "feederId=" +
        feeder.feederId.toString() +
        "&userId=" +
        feeder.userId.toString() +
        "&labels=" +
        newLabels.toString() +
        "&labelsState=" +
        newLabelsState.toString() +
        "&feederType=" +
        feeder.feederType +
        "&timeTable=" +
        newTimeTable.toString() +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }

  static String changeLabel(Feeder feeder) {
    StringBuffer newTimeTable = new StringBuffer();
    StringBuffer newLabels = new StringBuffer();
    StringBuffer newLabelsState = new StringBuffer();
    if (feeder.labels.isEmpty != true) {
      for (int i = 0; i < feeder.labels.length; i++) {
        if (i == feeder.labels.length - 1) {
          newLabels.write(feeder.labels[i]);
          newLabelsState.write(feeder.labelsState[i].toString());
        } else {
          newLabels.write(feeder.labels[i] + "__");
          newLabelsState.write(feeder.labelsState[i].toString() + "__");
        }
      }
    }
    if (newLabels.toString() == "__") {
      newLabels = new StringBuffer();
      newLabelsState = new StringBuffer();
    }

    for (int i = 0; i < feeder.timeTable.length; i++) {
      if (i != feeder.timeTable.length - 1) {
        newTimeTable.write(feeder.timeTable[i] + "__");
      } else {
        newTimeTable.write(feeder.timeTable[i]);
      }
    }

    return "feederId=" +
        feeder.feederId.toString() +
        "&userId=" +
        feeder.userId.toString() +
        "&labels=" +
        newLabels.toString() +
        "&labelsState=" +
        newLabelsState.toString() +
        "&feederType=" +
        feeder.feederType +
        "&timeTable=" +
        newTimeTable.toString() +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }

  static String addLabel(Feeder feeder, String label) {
    StringBuffer newTimeTable = new StringBuffer();
    StringBuffer newLabels = new StringBuffer();
    StringBuffer newLabelsState = new StringBuffer();
    if (feeder.labels.isEmpty != true) {
      for (int i = 0; i < feeder.labels.length; i++) {
        newLabels.write(feeder.labels[i] + "__");
        newLabelsState.write(feeder.labelsState[i].toString() + "__");
      }
    }
    newLabels.write(label);
    newLabelsState.write("false");
    for (int i = 0; i < feeder.timeTable.length; i++) {
      if (i != feeder.timeTable.length - 1) {
        newTimeTable.write(feeder.timeTable[i] + "__");
      } else {
        newTimeTable.write(feeder.timeTable[i]);
      }
    }

    return "feederId=" +
        feeder.feederId.toString() +
        "&userId=" +
        feeder.userId.toString() +
        "&labels=" +
        newLabels.toString() +
        "&labelsState=" +
        newLabelsState.toString() +
        "&feederType=" +
        feeder.feederType +
        "&timeTable=" +
        newTimeTable.toString() +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }

  static String timeTableChange(Feeder feeder, List<bool> timeT) {
    StringBuffer newLabels = new StringBuffer();
    StringBuffer newLabelsState = new StringBuffer();
    StringBuffer newTimeTable = new StringBuffer();
    if (feeder.labels.isEmpty != true) {
      for (int i = 0; i < feeder.labels.length; i++) {
        if (feeder.labels.length - 1 != i) {
          newLabels.write(feeder.labels[i] + "__");
          newLabelsState.write(feeder.labelsState[i].toString() + "__");
        } else {
          newLabels.write(feeder.labels[i]);
          newLabelsState.write(feeder.labelsState[i].toString());
        }
      }
    }
    for (int i = 0; i < feeder.timeTable.length; i++) {
      if (i != feeder.timeTable.length - 1) {
        if (timeT[i] == false) {
          newTimeTable.write("0__");
        } else {
          newTimeTable.write("1__");
        }
      } else {
        if (timeT[i] == false) {
          newTimeTable.write("0");
        } else {
          newTimeTable.write("1");
        }
      }
    }
    return "feederId=" +
        feeder.feederId.toString() +
        "&userId=" +
        feeder.userId.toString() +
        "&labels=" +
        newLabels.toString() +
        "&labelsState=" +
        newLabelsState.toString() +
        "&feederType=" +
        feeder.feederType +
        "&timeTable=" +
        newTimeTable.toString() +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }
}
