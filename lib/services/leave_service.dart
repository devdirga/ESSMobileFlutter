import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/leave_model.dart';
import 'package:ess_mobile/models/resume_model.dart';

class LeaveService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> calendar(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave Calendar');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/leave/MGetCalendar',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      dynamic _leaves;
      dynamic _holidays;

      if (response['Data'] != null) {
        if (response['Data']['Leaves'] != null) {
          _leaves = response['Data']['Leaves'];
        }

        if (response['Data']['Holidays'] != null) {
          _holidays = response['Data']['Holidays'];
        }
      }

      LeaveCalendarModel _calendar = LeaveCalendarModel.fromJson({
        'Leaves': _leaves,
        'Holidays': _holidays,
      });

      _res.data = _calendar;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> history(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave History');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetHistory/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<LeaveHistoryModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(LeaveHistoryModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> subordinate(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave Subordinate');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetSubordinate/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<SubordinateModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(SubordinateModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> subtitution(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave Subtitution');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetSubtitutions/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<EmployeeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(EmployeeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> leaveType(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave Type');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetType/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<LeaveTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(LeaveTypeModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> leaveInfo(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave Info');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetInfoAll/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = LeaveInfoModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> leaveRequest(
      String route, PlatformFile? fileDoc, String data) async {
    var _apiResponse = ApiResponse.loading('Request Leave');

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${globals.apiUrl}/ess/leave/MCreate'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;

      if (fileDoc != null) {
        request.files.add(http.MultipartFile(
          'fileUpload',
          fileDoc.readStream!,
          fileDoc.size,
          filename: fileDoc.name,
        ));
      }

      final response = await request.send();
      String stream = await response.stream.bytesToString();

      _apiResponse = ApiResponse.completed(json.decode(stream));
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> leaveByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Leave');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/leave/MGetByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = LeaveModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
