import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/shared_preference.dart';
import 'package:ess_mobile/models/auth_model.dart';
import 'package:ess_mobile/models/response_model.dart';

enum AppStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Registering,
  Registered,
  Unregistered
}

class AuthProvider extends ChangeNotifier {
  AppSharedPreference _sharedPrefsHelper = AppSharedPreference();
  RestApi _restApi = RestApi();
  AuthModel _auth = AuthModel();
  AppStatus _status = AppStatus.Uninitialized;

  AuthModel get auth => _auth;
  AppStatus get status => _status;

  AuthProvider() {
    initAuthUser();
  }

  Future<void> initAuthUser() async {
    String? _authUser = await _sharedPrefsHelper.authUser;

    if (_authUser != null) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(_authUser);

        _auth = AuthModel.fromJson(jsonResponse);
        _status = AppStatus.Authenticated;

        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<ApiResponse> register(
    String id,
    String email,
    String password,
  ) async {
    var _apiResponse = ApiResponse.loading('Registration Process');
    _status = AppStatus.Registering;

    Map<String, dynamic> payload = {
      'EmployeeID': id,
      'Email': email,
      'Password': password,
    };

    dynamic body = json.encode(payload);

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/auth/register',
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      _apiResponse = ApiResponse.completed(response);

      _auth = AuthModel.fromJson(response['Data']);

      if (_auth.success == true) {
        _status = AppStatus.Registered;
      } else {
        _status = AppStatus.Unregistered;
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      _status = AppStatus.Unregistered;
    }

    notifyListeners();
    return _apiResponse;
  }

  Future<ApiResponse> signIn(
    String id,
    String password,
  ) async {
    var _apiResponse = ApiResponse.loading('Login Process');
    _status = AppStatus.Authenticating;

    Map<String, dynamic> payload = {
      'EmployeeID': id,
      'Email': id,
      'Password': password
    };

    dynamic body = json.encode(payload);

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/site/auth/signin',
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if(response != null){
        if(response['StatusCode'] == 200){
          _apiResponse = ApiResponse.completed(response);
          _auth = AuthModel.fromJson(response['Data']);
          _sharedPrefsHelper.saveLoginData(json.encode(payload));
          _sharedPrefsHelper.saveAuthUser(jsonEncode(_auth));

          if (_auth.success == true) {
            _status = AppStatus.Authenticated;
          } else {
            _status = AppStatus.Unauthenticated;
          }
        }
        else{
          _apiResponse = ApiResponse.error(response['Message']);
          _status = AppStatus.Unauthenticated;
        }
      }
      else{
        _apiResponse = ApiResponse.error("Error");
        _status = AppStatus.Unauthenticated;
      }
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
      _status = AppStatus.Unauthenticated;
    }

    notifyListeners();
    return _apiResponse;
  }

  Future signOut() async {
    _auth = AuthModel();
    _sharedPrefsHelper.removeAuthUser();
    _status = AppStatus.Unauthenticated;

    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<ApiResponse> forgotPassword(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Forgot Password');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/site/auth/MRequestResetPassword',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> verificationCode(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Verification Code');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/auth/forgotpassword/verified',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> createPassword(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Create Password');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/auth/forgotpassword/createpassword',
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> changePassword(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Change Password');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/site/auth/mchangepassword',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer '+ _auth.data!
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> checkPasswordStatus(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Check Password Status');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/site/auth/mismustchangepassword/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer '+ _auth.data!,
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
