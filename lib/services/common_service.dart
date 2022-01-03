import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ess_mobile/models/notification_model.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/common_model.dart';
import 'package:ess_mobile/services/master_service.dart';

class CommonService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;
  late String _localPath;

  MasterService _masterService = MasterService();

  Future<ApiResponse> taskHistory(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Task');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/task/MGetRange/${body['EmployeeID']}',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TaskModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TaskModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> taskActive(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Task');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/task/MGetActive/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TaskModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TaskModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> mTaskActive(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Task');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/task/MGetActive',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
        body: json.encode(body)
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TaskModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TaskModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> taskSave(String route, Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/task/$route',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> updateUserToken(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Update User Token');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/employee/MUpdateUserToken',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getNotification(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Update User Token');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/notification/MGet',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<NotificationModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(NotificationModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> setReadNotification(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Saving Loan Request');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/notification/MSetRead',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> updateRequest(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Update Request');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/common/updateRequest/range/${body['EmployeeID']}',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<UpdateRequestModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(UpdateRequestModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> updateRequestAll(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Update Request');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/common/updateRequest/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<UpdateRequestModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(UpdateRequestModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> updateRequestDetail(
      Map<String, dynamic> body, String id) async {
    var _apiResponse = ApiResponse.loading('Fetching Update Request');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/common/updateRequest/${body['EmployeeID']}/$id',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = UpdateRequestModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> taskWorkflowsByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Workflows');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/UpdateRequest/MGetByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = UpdateRequestModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getLatestVersion() async {
    var _apiResponse = ApiResponse.loading('Fetching Latest Version App');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/administrator/getmobileversion',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<File> getInstallerFile(String platform, String filename) async {
    String _url = '${globals.apiUrl}/ess/administrator/download/';
    if(platform == 'Android'){
      _url = _url + 'android/' + filename;
    }
    if(platform == 'iOS'){
      _url = _url + 'ios/' + filename;
    }
    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
      }
    );
    
    _localPath = (await _masterService.findLocalPath())!;
    final savedDir = Directory(_localPath);
    String tempPath = savedDir.path;
    File file = new File('$tempPath/$filename');
    file.writeAsBytes(response.bodyBytes);

    return file;
  }
}
