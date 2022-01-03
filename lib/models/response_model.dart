class ResponseModel {
  int? statusCode;
  String? message;
  dynamic data;
  dynamic tdata;
  int? total;

  ResponseModel({this.statusCode, this.message, this.data, this.total});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['StatusCode'];
    message = json['Message'];
    data = json['Data'] != null ? json['Data'] : '';
    total = json['Total'];
    tdata = json['Data'] != null ? json['Data'] : '';

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StatusCode'] = this.statusCode;
    data['Message'] = this.message;
    data['Data'] = this.data;
    data['Total'] = this.total;
    return data;
  }
}
