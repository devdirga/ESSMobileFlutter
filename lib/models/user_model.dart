class UserModel {
  String? odooId;
  String? id;
  String? password;
  String? username;
  String? fullName;
  String? email;
  String? oldPassword;
  String? profilePict;
  String? profilePictUrl;
  List<LocationModel>? location;
  String? lastLogin;
  String? createBy;
  String? createDate;
  String? lastPasswordChangedDate;
  String? isSelfieAuth;
  Null additionalInfo;
  bool? enable;
  List<String>? roles;
  String? roleDescription;
  UserData? userData;
  String? lastUpdate;
  String? updateBy;
  UserModel({this.odooId,this.id,this.password,this.username,this.fullName,this.email,this.oldPassword,this.profilePict,this.profilePictUrl,this.location,this.lastLogin,this.createBy,this.createDate,this.lastPasswordChangedDate,this.isSelfieAuth,this.additionalInfo,this.enable,this.roles,this.roleDescription,this.userData,this.lastUpdate,this.updateBy});
  UserModel.fromJson(Map<String, dynamic> json) {
    odooId = json['OdooID'];
    id = json['Id'];
    password = json['Password'] != null ? json['Password'] : '';
    username = json['Username'];
    fullName = json['FullName'];
    email = json['Email'];
    oldPassword = json['OldPassword'] != null ? json['OldPassword'] : '';
    profilePict = json['ProfilePict'] != null ? json['ProfilePict'] : '';
    profilePictUrl = json['ProfilePictUrl'];
    if (json['Location'] != null) {
      location = <LocationModel>[];
      json['Location'].forEach((v) {
        location?.add(new LocationModel.fromJson(v));
      });
    }
    lastLogin = json['LastLogin'];
    createBy = json['CreateBy'] != null ? json['CreateBy'] : '';
    createDate = json['CreateDate'];
    lastPasswordChangedDate = json['LastPasswordChangedDate'];
    isSelfieAuth = json['IsSelfieAuth'];
    additionalInfo = json['AdditionalInfo'];
    enable = json['Enable'];
    roles = json['Roles'].cast<String>();
    roleDescription = json['RoleDescription'] != null ? json['RoleDescription'] : '';
    userData = json['UserData'] != null ? new UserData.fromJson(json['UserData']) : null;
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OdooID'] = this.odooId;
    data['Id'] = this.id;
    data['Password'] = this.password;
    data['Username'] = this.username;
    data['FullName'] = this.fullName;
    data['Email'] = this.email;
    data['OldPassword'] = this.oldPassword;
    data['ProfilePict'] = this.profilePict;
    data['ProfilePictUrl'] = this.profilePictUrl;
    if (this.location != null) {
      data['Location'] =
          this.location?.map((v) => v.toJson()).toList();
    }
    data['LastLogin'] = this.lastLogin;
    data['CreateBy'] = this.createBy;
    data['CreateDate'] = this.createDate;
    data['LastPasswordChangedDate'] = this.lastPasswordChangedDate;
    data['IsSelfieAuth'] = this.isSelfieAuth;
    data['AdditionalInfo'] = this.additionalInfo;
    data['Enable'] = this.enable;
    data['Roles'] = this.roles;
    data['RoleDescription'] = this.roleDescription;
    if (this.userData != null) {
      data['UserData'] = this.userData?.toJson();
    }
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    return data;
  }
}

class UserData {
  String? gender;
  String? hasSubordinate;
  String? lastEmploymentDate;
  String? profilePicture;
  UserData({this.gender, this.hasSubordinate, this.lastEmploymentDate});
  UserData.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    hasSubordinate = json['hasSubordinate'];
    lastEmploymentDate = json['lastEmploymentDate'];
    profilePicture = json['profilePicture'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gender'] = this.gender;
    data['hasSubordinate'] = this.hasSubordinate;
    data['lastEmploymentDate'] = this.lastEmploymentDate;
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}

class LocationModel {
  String? id;
  String? name;
  String? code;
  String? address;
  String? status;
  double? latitude;
  double? longitude;
  double? radius;
  bool? isVirtual;
  LocationModel({this.id, this.name, this.code, this.address, this.status, this.isVirtual, this.latitude, this.longitude, this.radius});
  LocationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    address = json['address'];
    status = json['status'];
    isVirtual = json['isVirtual'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['address'] = this.address;
    data['status'] = this.status;
    data['isVirtual'] = this.isVirtual;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['radius'] = this.radius;
    return data;
  }
}

class EntityModel {
  String? id;
  String? name;
  String? description;
  String? logo;
  String? createdBy;
  String? createdDate;
  String? lastUpdatedDate;
  String? status;
  String? mapboxTemplate;
  String? mapboxToken;
  String? mapboxId;
  List<ActivityTypeModel>? activityTypes;
  List<LocationModel>? locations;
  EntityModel({this.id,this.name,this.description,this.logo,this.createdBy,this.createdDate,this.lastUpdatedDate,this.status,this.mapboxTemplate,this.mapboxToken,this.mapboxId,this.activityTypes,this.locations});
  EntityModel.fromJson(Map<String, dynamic> json){
    id=json['id'];
    name=json['name'];
    description=json['description'];
    logo=json['logo'];
    createdBy=json['createdBy'];
    createdDate=json['createdDate'];
    lastUpdatedDate=json['lastUpdatedDate'];
    status=json['status'];
    mapboxTemplate=json['mapboxTemplate'];
    mapboxToken=json['mapboxToken'];
    mapboxId=json['mapboxId'];
    if (json['activityTypes'] != null) {
      activityTypes = <ActivityTypeModel>[];
      json['activityTypes'].forEach((v) {
        activityTypes?.add(new ActivityTypeModel.fromJson(v));
      });
    }
    if (json['locations'] != null) {
      locations = <LocationModel>[];
      json['locations'].forEach((v) {
        locations?.add(new LocationModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['name']=this.name;
    data['description']=this.description;
    data['logo']=this.logo;
    data['createdBy']=this.createdBy;
    data['createdDate']=this.createdDate;
    data['lastUpdatedDate']=this.lastUpdatedDate;
    data['status']=this.status;
    data['mapboxTemplate']=this.mapboxTemplate;
    data['mapboxToken']=this.mapboxToken;
    data['mapboxId']=this.mapboxId;
    data['activityTypes']=this.activityTypes;
    data['locations']=this.locations;
    return data;
  }
}

class ActivityTypeModel {
  String? id;
  String? entityID;
  String? uniqueKey;
  String? name;
  String? description;
  String? category;
  String? preActivities;
  String? postActivities;
  String? icon;
  String? createdBy;
  String? createdDate;
  String? lastUpdatedDate;
  String? status;
  ActivityTypeModel({this.id,this.entityID,this.uniqueKey,this.name,this.description,this.category,this.preActivities,this.postActivities,this.icon,this.createdBy,this.createdDate,this.lastUpdatedDate,this.status});
  ActivityTypeModel.fromJson(Map<String, dynamic> json){
    id=json['id'];
    entityID=json['entityID'];
    uniqueKey=json['uniqueKey'];
    name=json['name'];
    description=json['description'];
    category=json['category'];
    preActivities=json['preActivities'];
    postActivities=json['postActivities'];
    icon=json['icon'];
    createdBy=json['createdBy'];
    createdDate=json['createdDate'];
    lastUpdatedDate=json['lastUpdatedDate'];
    status=json['status'];
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['entityID']=this.entityID;
    data['uniqueKey']=this.uniqueKey;
    data['name']=this.name;
    data['description']=this.description;
    data['category']=this.category;
    data['preActivities']=this.preActivities;
    data['postActivities']=this.postActivities;
    data['icon']=this.icon;
    data['createdBy']=this.createdBy;
    data['createdDate']=this.createdDate;
    data['lastUpdatedDate']=this.lastUpdatedDate;
    data['status']=this.status;
    return data;
  }
}

class AttendanceModel {
  String? typeID;
  String? entityID;
  String? activityTypeID;
  String? locationID;
  double? longitude;
  double? latitude;
  String? inOut;
  String? employeeID;
  AttendanceModel({this.typeID,this.entityID,this.activityTypeID,this.locationID,this.latitude,this.longitude,this.inOut,this.employeeID});
  AttendanceModel.fromJson(Map<String, dynamic> json){
    typeID=json['typeID'];
    entityID=json['entityID'];
    activityTypeID=json['activityTypeID'];
    locationID=json['locationID'];
    longitude=json['longitude'];
    latitude=json['latitude'];
    inOut=json['inOut'];
    employeeID=json['employeeID'];    
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeID']=this.typeID;
    data['entityID']=this.entityID;
    data['activityTypeID']=this.activityTypeID;
    data['locationID']=this.locationID;
    data['latitude']=this.latitude;
    data['longitude']=this.longitude;
    data['inOut']=this.inOut;
    data['employeeID']=this.employeeID;
    return data;
  }
}

class ActivityLogModel {
  String? id;
  String? latitute;
  String? longitute;
  String? submittedBy;
  String? entityName;
  String? createdDate;
  String? createdBy;
  ActivityTypeMapModel? activityType;
  LocationMapModel? location;
  UserMapModel? user;
  ActivityLogModel({this.id,this.latitute,this.longitute,this.submittedBy,this.entityName,this.createdDate,this.createdBy, this.activityType, this.location,this.user});
  ActivityLogModel.fromJson(Map<String, dynamic> json){
    id=json['id'];
    latitute=json['latitute'];
    longitute=json['longitute'];
    submittedBy=json['submittedBy'];
    entityName=json['entityName'];
    createdDate=json['createdDate'];
    createdBy=json['createdBy'];  
    activityType= new ActivityTypeMapModel(activityTypeID: json['activityType']['activityTypeID'], activityTypeName: json['activityType']['activityTypeName']);
    location=new LocationMapModel(locationID: json['location']['locationID'], locationName: json['location']['locationName'], locationAddress: json['location']['locationAddress']);
    user=new UserMapModel(email: json['user']['email'], firstName:json['user']['firstName'], lastName: json['user']['lastName'], userID:json['user']['userID'],username:json['user']['username']);
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id']=this.id;
    data['latitute']=this.latitute;
    data['longitute']=this.longitute;
    data['submittedBy']=this.submittedBy;
    data['entityName']=this.entityName;
    data['createdDate']=this.createdDate;
    data['createdBy']=this.createdBy;
    return data;
  }
}

class ActivityTypeMapModel {
  String? activityTypeID;
  String? activityTypeName;
  ActivityTypeMapModel({this.activityTypeID,this.activityTypeName});
  ActivityTypeMapModel.fromJson(Map<String, dynamic> json){
    activityTypeID=json['activityTypeID'];
    activityTypeName=json['activityTypeName'];
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activityTypeID']=this.activityTypeID;
    data['activityTypeName']=this.activityTypeName;
    return data;
  }
}

class LocationMapModel {
  String? locationID;
  String? locationName;
  String? locationAddress;
  LocationMapModel({this.locationID,this.locationName,this.locationAddress});
  LocationMapModel.fromJson(Map<String, dynamic> json){
    locationID=json['locationID'];
    locationName=json['locationName'];
    locationAddress=json['locationAddress'];
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationID']=this.locationID;
    data['locationName']=this.locationName;
    data['locationAddress']=this.locationAddress;
    return data;
  }
}

class UserMapModel{
  String? email;
  String? firstName;
  String? lastName;
  String? userID;
  String? username;
  UserMapModel({this.email,this.firstName,this.lastName,this.userID, this.username});
  UserMapModel.fromJson(Map<String, dynamic> json){
    email=json['email'];
    firstName=json['firstName'];
    lastName=json['lastName'];
    userID=json['userID'];
    username=json['username'];
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email']=this.email;
    data['firstName']=this.firstName;
    data['lastName']=this.lastName;
    data['userID']=this.userID;
    data['username']=this.username;
    return data;
  }
}

