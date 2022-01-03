import 'package:ess_mobile/models/user_model.dart';

class AuthModel {
  int? authState;
  bool? success;
  String? message;
  String? data;
  UserModel? user;

  AuthModel({
    this.authState,
    this.success,
    this.message,
    this.data,
    this.user,
  });

  AuthModel.fromJson(Map<String, dynamic> json) {
    authState = json['AuthState'];
    success = json['Success'];
    message = json['Message'] != null ? json['Message'] : '';
    data = json['Data'] != null ? json['Data'] : '';
    user = json['User'] != null ? new UserModel.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AuthState'] = this.authState;
    data['Success'] = this.success;
    data['Message'] = this.message;
    data['Data'] = this.data;
    if (this.user != null) {
      data['User'] = this.user?.toJson();
    }
    return data;
  }
}
