import 'datetime_model.dart';
import 'attachment_model.dart';

class DocumentModel {
  String? documentType;
  String? description;
  String? notes;
  String? filepath;
  String? filename;
  String? fileext;
  String? checksum;
  bool? accessible;
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

  DocumentModel({
    this.documentType,
    this.description,
    this.notes,
    this.filepath,
    this.filename,
    this.fileext,
    this.checksum,
    this.accessible,
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

  DocumentModel.fromJson(Map<String, dynamic> json) {
    documentType = json['DocumentType'];
    description = json['Description'];
    notes = json['Notes'];
    filepath = json['Filepath'];
    filename = json['Filename'];
    fileext = json['Fileext'];
    checksum = json['Checksum'];
    accessible = json['Accessible'];
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
    data['DocumentType'] = this.documentType;
    data['Description'] = this.description;
    data['Notes'] = this.notes;
    data['Filepath'] = this.filepath;
    data['Filename'] = this.filename;
    data['Fileext'] = this.fileext;
    data['Checksum'] = this.checksum;
    data['Accessible'] = this.accessible;
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

class DocumentRequestModel {
  String? requestDate;
  DateTimeModel? validDate;
  String? documentType;
  String? description;
  String? notes;
  String? filepath;
  String? filename;
  String? fileext;
  String? checksum;
  bool? accessible;
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
  AttachmentModel? attachment;

  DocumentRequestModel({
    this.requestDate,
    this.validDate,
    this.documentType,
    this.description,
    this.notes,
    this.filepath,
    this.filename,
    this.fileext,
    this.checksum,
    this.accessible,
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
    this.attachment
  });

  DocumentRequestModel.fromJson(Map<String, dynamic> json) {
    requestDate = json['RequestDate'];
    validDate = json['ValidDate'] != null
        ? new DateTimeModel.fromJson(json['ValidDate'])
        : null;
    documentType = json['DocumentType'];
    description = json['Description'];
    notes = json['Notes'];
    filepath = json['Filepath'];
    filename = json['Filename'];
    fileext = json['Fileext'];
    checksum = json['Checksum'];
    accessible = json['Accessible'];
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
    attachment = json['Attachment'] != null
        ? new AttachmentModel.fromJson(json['Attachment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RequestDate'] = this.requestDate;
    if (this.validDate != null) {
      data['ValidDate'] = this.validDate?.toJson();
    }
    data['DocumentType'] = this.documentType;
    data['Description'] = this.description;
    data['Notes'] = this.notes;
    data['Filepath'] = this.filepath;
    data['Filename'] = this.filename;
    data['Fileext'] = this.fileext;
    data['Checksum'] = this.checksum;
    data['Accessible'] = this.accessible;
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
    if (this.attachment != null) {
      data['Attachment'] = this.attachment?.toJson();
    }
    return data;
  }
}
