import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/attachment_model.dart';

class AgendaModel {
  String? id;
  String? agendaID;
  String? issuer;
  String? name;
  String? description;
  String? notes;
  int? axid;
  String? location;
  String? category;
  String? createdDate;
  int? agendaFor;
  String? agendaForDescription;
  int? agendaType;
  List<String>? employeeRecipients;
  List<AttachmentModel>? attachments;
  DateTimeModel? schedule;
  String? hash;
  String? lastUpdate;
  String? updateBy;

  AgendaModel({
    this.id,
    this.agendaID,
    this.issuer,
    this.name,
    this.description,
    this.notes,
    this.axid,
    this.location,
    this.category,
    this.createdDate,
    this.agendaFor,
    this.agendaForDescription,
    this.agendaType,
    this.employeeRecipients,
    this.attachments,
    this.schedule,
    this.hash,
    this.lastUpdate,
    this.updateBy,
  });

  AgendaModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    agendaID = json['AgendaID'];
    issuer = json['Issuer'];
    name = json['Name'];
    description = json['Description'];
    notes = json['Notes'];
    axid = json['AXID'];
    location = json['Location'];
    category = json['Category'];
    createdDate = json['CreatedDate'];
    agendaFor = json['AgendaFor'];
    agendaForDescription = json['AgendaForDescription'];
    agendaType = json['AgendaType'];
    employeeRecipients = json['EmployeeRecipients'] != null 
      ? [...json['EmployeeRecipients']]
      : null;
    if (json['Attachments'] != null) {
      attachments = <AttachmentModel>[];
      json['Attachments'].forEach((v) {
        attachments?.add(new AttachmentModel.fromJson(v));
      });
    }
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
    hash = json['Hash'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['AgendaID'] = this.agendaID;
    data['Issuer'] = this.issuer;
    data['Name'] = this.name;
    data['Description'] = this.description;
    data['Notes'] = this.notes;
    data['AXID'] = this.axid;
    data['Location'] = this.location;
    data['Category'] = this.category;
    data['CreatedDate'] = this.createdDate;
    data['AgendaFor'] = this.agendaFor;
    data['AgendaForDescription'] = this.agendaForDescription;
    data['AgendaType'] = this.agendaType;
    if (this.employeeRecipients != null) {
      data['EmployeeRecipients'] = this.employeeRecipients;
    }
    if (this.attachments != null) {
      data['Attachments'] = this.attachments?.map((v) => v.toJson()).toList();
    }
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    data['Hash'] = this.hash;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    return data;
  }
}

class EmployeeRecipientModel {
  EmployeeRecipientModel.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
