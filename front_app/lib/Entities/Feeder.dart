class Feeder {
  int feederId;
  int userId;
  List<bool> labelsState;
  List<String> labels;
  String feederType;
  String timeTable;
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
        timeTable: (json["timeTable"] as String).toString(),
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
        "no" +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }

  static String changeLabel(Feeder feeder) {
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
        "no" +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }

  static String addLabel(Feeder feeder, String label) {
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
        "no" +
        "&capacity=100" +
        "&filledInternally=" +
        feeder.filledInernally.toString() +
        "&filledExternally=" +
        feeder.filledExternally.toString();
  }
}
