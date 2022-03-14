import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/time_management_model.dart';
import 'package:ess_mobile/models/agenda_model.dart';
import 'package:ess_mobile/services/master_service.dart';

class TimeManagementService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;
  late String _localPath;

  MasterService _masterService = MasterService();

  Future<ApiResponse> timeAttendance(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Time Attendance');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/timemanagement/MGet',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TimeAttendanceModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['TimeAttendance'] = v['UpdateRequest'];
            v['TimeAttendance']['UpdateRequest'] = 1;
          }

          _data.add(TimeAttendanceModel.fromJson(v['TimeAttendance']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> timeAttendanceAll(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Time Attendance');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/timemanagement/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TimeAttendanceModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['TimeAttendance'] = v['UpdateRequest'];
            v['TimeAttendance']['UpdateRequest'] = 1;
          }

          _data.add(TimeAttendanceModel.fromJson(v['TimeAttendance']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> subordinateAttendance(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Subordinate Attendance');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/timemanagement/MGetSubordinate',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TimeAttendanceModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TimeAttendanceModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> subordinateAttendanceAll(
      Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Subordinate Attendance');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/timemanagement/subordinate/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TimeAttendanceModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TimeAttendanceModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> absenceImported(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Absence Imported');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/timemanagement/mgetabsenceimported',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<AbsenceImportedModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(AbsenceImportedModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> timeAttendanceSave(
      String route, PlatformFile? fileDoc, String data, String reason) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('${globals.apiUrl}/ess/timemanagement/MUpdateTimeAttendance'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;
      request.fields['Reason'] = reason;
      if(fileDoc != null){
        request.files.add(http.MultipartFile(
          'FileUpload',
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

  Future<ApiResponse> timeAttendanceDelete(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Deleting Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/timemanagement/timeattendance/delete',
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

  Future<ApiResponse> timeAttendanceDiscard(String id) async {
    var _apiResponse = ApiResponse.loading('Discarding Changes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/timemanagement/MDiscardTimeAttendanceChange/$id',
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

  Future<ApiResponse> timeAttendanceByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Time Attendance');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/timemanagement/MGetByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = TimeAttendanceModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> agenda(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Agenda');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/timemanagement/MAgendaGet',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<AgendaModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(AgendaModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<File> getAgendaFile(String token, String filename) async {
    var reqBody = {
      'JsonData': token
    };
    
    final response = await http.post(
      Uri.parse('${globals.apiUrl}/ess/timemanagement/magendadownload'),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
      },
      body: json.encode(reqBody)
    );
    
    _localPath = (await _masterService.findLocalPath())!;
    final savedDir = Directory(_localPath);
    String tempPath = savedDir.path;
    File file = new File('$tempPath/$filename');
    file.writeAsBytes(response.bodyBytes);

    return file;
  }
}
