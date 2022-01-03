class NotificationModel {
  String? id;
  String? timestamp;
  int? type;
  String? sender;
  String? receiver;
  String? module;
  String? message;
  String? notes;
  bool? read;
  List<String>? actions;
  bool? isTask;
  int? status;

  NotificationModel({
    this.id,
    this.timestamp,
    this.type,
    this.sender,
    this.receiver,
    this.module,
    this.message,
    this.notes,
    this.read,
    this.actions,
    this.isTask,
    this.status
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    timestamp = json['Timestamp'];
    type = json['Type'];
    sender = json['Sender'];
    receiver = json['Receiver'];
    module = json['Module'];
    message = json['Message'];
    notes = json['Notes'];
    read = json['Read'];
    actions = json['Actions'] != null 
      ? [...json['Actions']]
      : null;
    isTask = json['IsTask'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Timestamp'] = this.timestamp;
    data['Type'] = this.type;
    data['Sender'] = this.sender;
    data['Receiver'] = this.receiver;
    data['Module'] = this.module;
    data['Message'] = this.message;
    data['Notes'] = this.notes;
    data['Read'] = this.read;
    if (this.actions != null) {
      data['Actions'] = this.actions;
    }
    data['IsTask'] = this.isTask;
    data['Status'] = this.status;
    return data;
  }
}
