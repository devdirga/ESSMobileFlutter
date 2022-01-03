class CityModel {
  String? id;
  int? axid;
  String? name;
  String? description;

  CityModel({this.id, this.axid, this.name, this.description});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    axid = json['AXID'];
    name = json['Name'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['AXID'] = this.axid;
    data['Name'] = this.name;
    data['Description'] = this.description;
    return data;
  }
}

class CertificateTypeModel {
  int? axid;
  String? typeID;
  String? description;
  bool? reqRenew;

  CertificateTypeModel({
    this.axid,
    this.typeID,
    this.description,
    this.reqRenew,
  });

  CertificateTypeModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    typeID = json['TypeID'];
    description = json['Description'];
    reqRenew = json['ReqRenew'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['TypeID'] = this.typeID;
    data['Description'] = this.description;
    data['ReqRenew'] = this.reqRenew;
    return data;
  }
}

class FamilyRelationshipModel {
  int? axid;
  String? typeID;
  String? description;

  FamilyRelationshipModel({this.axid, this.typeID, this.description});

  FamilyRelationshipModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    typeID = json['TypeID'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['TypeID'] = this.typeID;
    data['Description'] = this.description;
    return data;
  }
}

class IdentificationTypeModel {
  int? axid;
  String? type;
  String? description;

  IdentificationTypeModel({this.axid, this.type, this.description});

  IdentificationTypeModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    type = json['Type'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['Type'] = this.type;
    data['Description'] = this.description;
    return data;
  }
}

class ElectronicAddressTypeModel {
  int? axid;
  String? type;
  String? description;

  ElectronicAddressTypeModel({this.axid, this.type, this.description});

  ElectronicAddressTypeModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    type = json['Type'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['Type'] = this.type;
    data['Description'] = this.description;
    return data;
  }
}

class TravelPurposeModel {
  int? axid;
  String? purposeID;
  String? description;
  bool? isOverseas;

  TravelPurposeModel({
    this.axid,
    this.purposeID,
    this.description,
    this.isOverseas,
  });

  TravelPurposeModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    purposeID = json['PurposeID'];
    description = json['Description'];
    isOverseas = json['IsOverseas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['PurposeID'] = this.purposeID;
    data['Description'] = this.description;
    data['IsOverseas'] = this.isOverseas;
    return data;
  }
}

class TravelTransportationModel {
  int? axid;
  String? transportationID;
  String? description;

  TravelTransportationModel({
    this.axid,
    this.transportationID,
    this.description,
  });

  TravelTransportationModel.fromJson(Map<String, dynamic> json) {
    axid = json['AXID'];
    transportationID = json['TransportationID'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AXID'] = this.axid;
    data['TransportationID'] = this.transportationID;
    data['Description'] = this.description;
    return data;
  }
}

class TrainingTypeModel {
  int? minAttendees;
  int? typeGroup;
  int? numberOfDays;
  String? typeID;
  String? description;
  int? axid;

  TrainingTypeModel({
    this.minAttendees,
    this.typeGroup,
    this.numberOfDays,
    this.typeID,
    this.description,
    this.axid,
  });

  TrainingTypeModel.fromJson(Map<String, dynamic> json) {
    minAttendees = json['MinAttendees'];
    typeGroup = json['TypeGroup'];
    numberOfDays = json['NumberOfDays'];
    typeID = json['TypeID'];
    description = json['Description'];
    axid = json['AXID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MinAttendees'] = this.minAttendees;
    data['TypeGroup'] = this.typeGroup;
    data['NumberOfDays'] = this.numberOfDays;
    data['TypeID'] = this.typeID;
    data['Description'] = this.description;
    data['AXID'] = this.axid;
    return data;
  }
}

class AbsenceCodeModel {
  String? descriptionField;
  String? groupIdField;
  String? idField;
  bool? isEditable;
  bool? isAttachment;
  bool? isOnList;

  AbsenceCodeModel({
    this.descriptionField,
    this.groupIdField,
    this.idField,
    this.isEditable,
    this.isAttachment,
    this.isOnList,
  });

  AbsenceCodeModel.fromJson(Map<String, dynamic> json) {
    descriptionField = json['DescriptionField'];
    groupIdField = json['GroupIdField'];
    idField = json['IdField'];
    isEditable = json['IsEditable'];
    isAttachment = json['IsAttachment'];
    isOnList = json['IsOnList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DescriptionField'] = this.descriptionField;
    data['GroupIdField'] = this.groupIdField;
    data['IdField'] = this.idField;
    data['IsEditable'] = this.isEditable;
    data['IsAttachment'] = this.isAttachment;
    data['IsOnList'] = this.isOnList;
    return data;
  }
}
