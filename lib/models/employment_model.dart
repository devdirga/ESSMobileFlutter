import 'package:ess_mobile/models/datetime_model.dart';

class EmploymentModel {
  DateTimeModel? assigmentDate;
  String? positionID;
  bool? primaryPosition;
  String? position;
  String? description;
  String? id;
  int? status;
  String? statusDescription;
  String? axRequestID;
  int? axid;
  String? employeeID;
  String? employeeName;
  String? reason;
  String? oldData;
  String? newData;
  String? createdDate;
  int? action;
  String? lastUpdate;
  String? updateBy;
  dynamic updateRequest;

  EmploymentModel({
    this.assigmentDate,
    this.positionID,
    this.primaryPosition,
    this.position,
    this.description,
    this.id,
    this.status,
    this.statusDescription,
    this.axRequestID,
    this.axid,
    this.employeeID,
    this.employeeName,
    this.reason,
    this.oldData,
    this.newData,
    this.createdDate,
    this.action,
    this.lastUpdate,
    this.updateBy,
    this.updateRequest,
  });

  EmploymentModel.fromJson(Map<String, dynamic> json) {
    assigmentDate = json['AssigmentDate'] != null
        ? new DateTimeModel.fromJson(json['AssigmentDate'])
        : null;
    positionID = json['PositionID'];
    primaryPosition = json['PrimaryPosition'];
    position = json['Position'];
    description = json['Description'];
    id = json['Id'];
    status = json['Status'];
    statusDescription = json['StatusDescription'];
    axRequestID = json['AXRequestID'];
    axid = json['AXID'];
    employeeID = json['EmployeeID'];
    employeeName = json['EmployeeName'];
    reason = json['Reason'];
    oldData = json['OldData'];
    newData = json['NewData'];
    createdDate = json['CreatedDate'];
    action = json['Action'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
    updateRequest = json['UpdateRequest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.assigmentDate != null) {
      data['AssigmentDate'] = this.assigmentDate?.toJson();
    }
    data['PositionID'] = this.positionID;
    data['PrimaryPosition'] = this.primaryPosition;
    data['Position'] = this.position;
    data['Description'] = this.description;
    data['Id'] = this.id;
    data['Status'] = this.status;
    data['StatusDescription'] = this.statusDescription;
    data['AXRequestID'] = this.axRequestID;
    data['AXID'] = this.axid;
    data['EmployeeID'] = this.employeeID;
    data['EmployeeName'] = this.employeeName;
    data['Reason'] = this.reason;
    data['OldData'] = this.oldData;
    data['NewData'] = this.newData;
    data['CreatedDate'] = this.createdDate;
    data['Action'] = this.action;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    data['UpdateRequest'] = this.updateRequest;
    return data;
  }
}
