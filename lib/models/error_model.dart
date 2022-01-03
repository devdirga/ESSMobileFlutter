class ErrorModel {
  ErrorsModel? errors;
  String? title;
  int? status;
  String? traceId;

  ErrorModel({this.errors, this.title, this.status, this.traceId});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    errors = json['errors'] != null
        ? new ErrorsModel.fromJson(json['errors'])
        : null;
    title = json['title'];
    status = json['status'];
    traceId = json['traceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.errors != null) {
      data['errors'] = this.errors?.toJson();
    }
    data['title'] = this.title;
    data['status'] = this.status;
    data['traceId'] = this.traceId;
    return data;
  }
}

class ErrorsModel {
  List<String>? identifications0Status;

  ErrorsModel({this.identifications0Status});

  ErrorsModel.fromJson(Map<String, dynamic> json) {
    identifications0Status = json['identifications[0].status'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['identifications[0].status'] = this.identifications0Status;
    return data;
  }
}
