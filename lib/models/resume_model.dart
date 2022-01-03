import 'package:ess_mobile/models/identification_model.dart';
import 'package:ess_mobile/models/bank_account_model.dart';
import 'package:ess_mobile/models/tax_model.dart';
import 'package:ess_mobile/models/attachment_model.dart';
import 'package:ess_mobile/models/electronic_address_model.dart';

class EmployeeModel {
  dynamic old;
  String? birthplace;
  String? birthdate;
  String? lastEmploymentDate;
  String? workerTimeType;
  String? department;
  String? position;
  int? gender;
  String? genderDescription;
  AttachmentModel? isExpartriateAttachment;
  bool? isExpatriate;
  bool? accessibleProfilePicture;
  AddressModel? address;
  int? religion;
  String? religionDescription;
  Null maritalStatusAttachment;
  int? maritalStatus;
  String? maritalStatusDescription;
  List<IdentificationModel>? identifications;
  List<BankAccountModel>? bankAccounts;
  List<TaxModel>? taxes;
  List<ElectronicAddressModel>? electronicAddresses;
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

  EmployeeModel({
    this.old,
    this.birthplace,
    this.birthdate,
    this.lastEmploymentDate,
    this.workerTimeType,
    this.department,
    this.position,
    this.gender,
    this.genderDescription,
    this.isExpartriateAttachment,
    this.isExpatriate,
    this.accessibleProfilePicture,
    this.address,
    this.religion,
    this.religionDescription,
    this.maritalStatusAttachment,
    this.maritalStatus,
    this.maritalStatusDescription,
    this.identifications,
    this.bankAccounts,
    this.taxes,
    this.electronicAddresses,
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

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    old = json['Old'];
    birthplace = json['Birthplace'];
    birthdate = json['Birthdate'];
    lastEmploymentDate = json['LastEmploymentDate'];
    workerTimeType = json['WorkerTimeType'];
    department = json['Department'];
    position = json['Position'];
    gender = json['Gender'];
    genderDescription = json['GenderDescription'];
    isExpartriateAttachment = json['IsExpartriateAttachment'] != null
        ? new AttachmentModel.fromJson(json['IsExpartriateAttachment'])
        : null;
    isExpatriate = json['IsExpatriate'];
    accessibleProfilePicture = json['AccessibleProfilePicture'];
    address = json['Address'] != null
        ? new AddressModel.fromJson(json['Address'])
        : null;
    religion = json['Religion'];
    religionDescription = json['ReligionDescription'];
    maritalStatusAttachment = json['MaritalStatusAttachment'];
    maritalStatus = json['MaritalStatus'];
    maritalStatusDescription = json['MaritalStatusDescription'];
    if (json['Identifications'] != null) {
      identifications = <IdentificationModel>[];
      json['Identifications'].forEach((v) {
        identifications?.add(new IdentificationModel.fromJson(v));
      });
    }
    if (json['BankAccounts'] != null) {
      bankAccounts = <BankAccountModel>[];
      json['BankAccounts'].forEach((v) {
        bankAccounts?.add(new BankAccountModel.fromJson(v));
      });
    }
    if (json['Taxes'] != null) {
      taxes = <TaxModel>[];
      json['Taxes'].forEach((v) {
        taxes?.add(new TaxModel.fromJson(v));
      });
    }
    if (json['ElectronicAddresses'] != null) {
      electronicAddresses = <ElectronicAddressModel>[];
      json['ElectronicAddresses'].forEach((v) {
        electronicAddresses?.add(new ElectronicAddressModel.fromJson(v));
      });
    }
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
    data['Old'] = this.old;
    data['Birthplace'] = this.birthplace;
    data['Birthdate'] = this.birthdate;
    data['LastEmploymentDate'] = this.lastEmploymentDate;
    data['WorkerTimeType'] = this.workerTimeType;
    data['Department'] = this.department;
    data['Position'] = this.position;
    data['Gender'] = this.gender;
    data['GenderDescription'] = this.genderDescription;
    if (this.isExpartriateAttachment != null) {
      data['IsExpartriateAttachment'] = this.isExpartriateAttachment?.toJson();
    }
    data['IsExpatriate'] = this.isExpatriate;
    data['AccessibleProfilePicture'] = this.accessibleProfilePicture;
    if (this.address != null) {
      data['Address'] = this.address?.toJson();
    }
    data['Religion'] = this.religion;
    data['ReligionDescription'] = this.religionDescription;
    data['MaritalStatusAttachment'] = this.maritalStatusAttachment;
    data['MaritalStatus'] = this.maritalStatus;
    data['MaritalStatusDescription'] = this.maritalStatusDescription;
    if (this.identifications != null) {
      data['Identifications'] =
          this.identifications?.map((v) => v.toJson()).toList();
    }
    if (this.bankAccounts != null) {
      data['BankAccounts'] = this.bankAccounts?.map((v) => v.toJson()).toList();
    }
    if (this.taxes != null) {
      data['Taxes'] = this.taxes?.map((v) => v.toJson()).toList();
    }
    if (this.electronicAddresses != null) {
      data['ElectronicAddresses'] =
          this.electronicAddresses?.map((v) => v.toJson()).toList();
    }
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

class AddressModel {
  String? street;
  String? city;
  String? value;
  String? originalValue;
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

  AddressModel({
    this.street,
    this.city,
    this.value,
    this.originalValue,
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

  AddressModel.fromJson(Map<String, dynamic> json) {
    street = json['Street'];
    city = json['City'];
    value = json['Value'];
    originalValue = json['OriginalValue'];
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
    data['Street'] = this.street;
    data['City'] = this.city;
    data['Value'] = this.value;
    data['OriginalValue'] = this.originalValue;
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
