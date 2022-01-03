import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/attachment_model.dart';

class TrainingModel {
  String? trainingID;
  String? name;
  String? location;
  String? termAndCondition;
  String? room;
  String? purpose;
  String? description;
  DateTimeModel? schedule;
  String? eventDescription;
  bool? abroadTraining;
  double? cost;
  int? maxAttendees;
  int? minAttendees;
  String? typeID;
  String? typeDescription;
  String? subTypeID;
  String? subTypeDescription;
  String? vendor;
  int? trainingStatus;
  String? trainingStatusDescription;
  String? registrationDeadline;
  TrainingRegistrationModel? trainingRegistration;
  String? note;
  List<AttachmentModel>? attachments;
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

  TrainingModel({
    this.trainingID,
    this.name,
    this.location,
    this.termAndCondition,
    this.room,
    this.purpose,
    this.description,
    this.schedule,
    this.eventDescription,
    this.abroadTraining,
    this.cost,
    this.maxAttendees,
    this.minAttendees,
    this.typeID,
    this.typeDescription,
    this.subTypeID,
    this.subTypeDescription,
    this.vendor,
    this.trainingStatus,
    this.trainingStatusDescription,
    this.registrationDeadline,
    this.trainingRegistration,
    this.note,
    this.attachments,
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

  TrainingModel.fromJson(Map<String, dynamic> json) {
    trainingID = json['TrainingID'];
    name = json['Name'];
    location = json['Location'];
    termAndCondition = json['TermAndCondition'];
    room = json['Room'];
    purpose = json['Purpose'];
    description = json['Description'];
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
    eventDescription = json['EventDescription'];
    abroadTraining = json['AbroadTraining'];
    cost = json['Cost'];
    maxAttendees = json['MaxAttendees'];
    minAttendees = json['MinAttendees'];
    typeID = json['TypeID'];
    typeDescription = json['TypeDescription'];
    subTypeID = json['SubTypeID'];
    subTypeDescription = json['SubTypeDescription'];
    vendor = json['Vendor'];
    trainingStatus = json['TrainingStatus'];
    trainingStatusDescription = json['TrainingStatusDescription'];
    registrationDeadline = json['RegistrationDeadline'];
    trainingRegistration = json['TrainingRegistration'] != null
        ? new TrainingRegistrationModel.fromJson(json['TrainingRegistration'])
        : null;
    note = json['Note'];
    if (json['Attachments'] != null) {
      attachments = <AttachmentModel>[];
      json['Attachments'].forEach((v) {
        attachments?.add(new AttachmentModel.fromJson(v));
      });
    }
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
    data['TrainingID'] = this.trainingID;
    data['Name'] = this.name;
    data['Location'] = this.location;
    data['TermAndCondition'] = this.termAndCondition;
    data['Room'] = this.room;
    data['Purpose'] = this.purpose;
    data['Description'] = this.description;
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    data['EventDescription'] = this.eventDescription;
    data['AbroadTraining'] = this.abroadTraining;
    data['Cost'] = this.cost;
    data['MaxAttendees'] = this.maxAttendees;
    data['MinAttendees'] = this.minAttendees;
    data['TypeID'] = this.typeID;
    data['TypeDescription'] = this.typeDescription;
    data['SubTypeID'] = this.subTypeID;
    data['SubTypeDescription'] = this.subTypeDescription;
    data['Vendor'] = this.vendor;
    data['TrainingStatus'] = this.trainingStatus;
    data['TrainingStatusDescription'] = this.trainingStatusDescription;
    data['RegistrationDeadline'] = this.registrationDeadline;
    if (this.trainingRegistration != null) {
      data['TrainingRegistration'] = this.trainingRegistration?.toJson();
    }
    data['Note'] = this.note;
    if (this.attachments != null) {
      data['Attachments'] = this.attachments?.map((v) => v.toJson()).toList();
    }
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

class TrainingRegistrationModel {
  String? trainingID;
  String? registrationDate;
  Null training;
  List<TrainingReferenceModel>? references;
  int? registrationStatus;
  String? registrationStatusDescription;
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

  TrainingRegistrationModel({
    this.trainingID,
    this.registrationDate,
    this.training,
    this.references,
    this.registrationStatus,
    this.registrationStatusDescription,
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

  TrainingRegistrationModel.fromJson(Map<String, dynamic> json) {
    trainingID = json['TrainingID'];
    registrationDate = json['RegistrationDate'];
    training = json['Training'];
    if (json['References'] != null) {
      references = <TrainingReferenceModel>[];
      json['References'].forEach((v) {
        references?.add(new TrainingReferenceModel.fromJson(v));
      });
    }
    registrationStatus = json['RegistrationStatus'];
    registrationStatusDescription = json['RegistrationStatusDescription'];
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
    data['TrainingID'] = this.trainingID;
    data['RegistrationDate'] = this.registrationDate;
    data['Training'] = this.training;
    if (this.references != null) {
      data['References'] = this.references?.map((v) => v.toJson()).toList();
    }
    data['RegistrationStatus'] = this.registrationStatus;
    data['RegistrationStatusDescription'] = this.registrationStatusDescription;
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

class TrainingReferenceModel {
  int? axid;
  int? type;
  String? typeDescription;
  String? description;
  String? createdDate;
  DateTimeModel? validity;
  AttachmentModel? attachment;

  TrainingReferenceModel({
    this.axid,
    this.type,
    this.typeDescription,
    this.description,
    this.createdDate,
    this.validity,
    this.attachment,
  });

  TrainingReferenceModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    type = json['Type'];
    typeDescription = json['TypeDescription'];
    description = json['Description'];
    createdDate = json['CreatedDate'];
    validity = json['Validity'] != null
        ? new DateTimeModel.fromJson(json['Validity'])
        : null;
    attachment = json['Attachment'] != null
        ? new AttachmentModel.fromJson(json['Attachment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['Type'] = this.type;
    data['TypeDescription'] = this.typeDescription;
    data['Description'] = this.description;
    data['CreatedDate'] = this.createdDate;
    if (this.validity != null) {
      data['Validity'] = this.validity?.toJson();
    }
    if (this.attachment != null) {
      data['Attachment'] = this.attachment?.toJson();
    }
    return data;
  }
}
