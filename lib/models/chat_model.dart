class AuthorModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? token;
  String? imageUrl;
  Map<String, dynamic>? metadata;
  Null role;
  int? lastSeen;
  int? createdAt;
  int? updatedAt;

  AuthorModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.token,
    this.imageUrl,
    this.metadata,
    this.role,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
  });

  AuthorModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    email = json['Email'];
    token = json['Token'];
    imageUrl = json['ImageUrl'];
    metadata = json['Metadata'] != null
        ? json['Metadata'] as Map<String, dynamic>
        : null;
    role = json['Role'];
    lastSeen = json['LastSeen'];
    createdAt = json['CreatedAt'];
    updatedAt = json['UpdatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Email'] = this.email;
    data['Token'] = this.token;
    data['ImageUrl'] = this.imageUrl;
    if (this.metadata != null) {
      data['Metadata'] = this.metadata;
    }
    data['Role'] = this.role;
    data['LastSeen'] = this.lastSeen;
    data['CreatedAt'] = this.createdAt;
    data['UpdatedAt'] = this.updatedAt;
    return data;
  }
}

class MessageModel {
  String? id;
  AuthorModel? author;
  String? channel;
  String? sender;
  String? receiver;
  String? roomId;
  String? status;
  String? text;
  String? type;
  String? name;
  String? uri;
  String? mimeType;
  int? size;
  num? width;
  num? height;
  int? createdAt;
  int? updatedAt;
  Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.author,
    this.channel,
    required this.sender,
    required this.receiver,
    this.roomId,
    this.status,
    this.text,
    required this.type,
    this.name,
    this.uri,
    this.mimeType,
    this.size,
    this.width,
    this.height,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    author = json['Author'] != null
        ? new AuthorModel.fromJson(json['Author'])
        : null;
    channel = json['Channel'];
    sender = json['Sender'];
    receiver = json['Receiver'];
    roomId = json['RoomId'];
    status = json['Status'];
    text = json['Text'];
    type = json['Type'];
    name = json['Name'];
    uri = json['Uri'];
    mimeType = json['MimeType'];
    size = json['Size'];
    width = json['Width'];
    height = json['Height'];
    createdAt = json['CreatedAt'];
    updatedAt = json['UpdatedAt'];
    metadata = json['Metadata'] != null
        ? json['Metadata'] as Map<String, dynamic>
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    if (this.author != null) {
      data['Author'] = this.author?.toJson();
    }
    data['Channel'] = this.channel;
    data['Sender'] = this.sender;
    data['Receiver'] = this.receiver;
    data['RoomId'] = this.roomId;
    data['Status'] = this.status;
    data['Text'] = this.text;
    data['Type'] = this.type;
    data['Name'] = this.name;
    data['Uri'] = this.uri;
    data['MimeType'] = this.mimeType;
    data['Size'] = this.size;
    data['Width'] = this.width;
    data['Height'] = this.height;
    data['CreatedAt'] = this.createdAt;
    data['UpdatedAt'] = this.updatedAt;
    if (this.metadata != null) {
      data['Metadata'] = this.metadata;
    }

    return data;
  }
}
