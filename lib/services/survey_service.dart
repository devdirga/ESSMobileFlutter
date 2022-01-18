import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/time_management_model.dart';
import 'package:ess_mobile/models/survey_model.dart';
import 'package:ess_mobile/models/ticket_category_model.dart';
import 'package:ess_mobile/models/agenda_model.dart';
import 'package:ess_mobile/services/master_service.dart';

class SurveyService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;
  late String _localPath;

  MasterService _masterService = MasterService();

  Future<ApiResponse> surveys(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Complaints');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/surveyess/mgetsurvey',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<SurveyModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(SurveyModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> history(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Resolution');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/surveyess/mgethistory',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      List<SurveyHistoryModel> _data = [];

      if (response != null) {
        response.forEach((v) {
          _data.add(SurveyHistoryModel.fromJson(v));
        });
      }

      _apiResponse = ApiResponse.completed(_data);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> ticketCategories() async {
    var _apiResponse = ApiResponse.loading('Fetching Ticket Categories');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetTicketCategories',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TicketCategoryModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TicketCategoryModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }


  Future<ApiResponse> complaintSave(PlatformFile fileDoc, String data, String reason) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('${globals.apiUrl}/ess/complaint/MRequest'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;
      request.fields['Reason'] = reason;
      request.files.add(http.MultipartFile(
        'FileUpload',
        fileDoc.readStream!,
        fileDoc.size,
        filename: fileDoc.name,
      ));

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

  Future<ApiResponse> updateMobileAttendance() async {
    try{
      final req = http.MultipartRequest('GET', Uri.parse('${globals.apiUrl}/api/absence/updatedoinoutdev'));
      Map<String, String> h = {HttpHeaders.authorizationHeader:'Bearer $_apiToken'};
      req.headers.addAll(h);      
      return ApiResponse.completed(json.decode(await (await req.send()).stream.bytesToString()));
    }catch(e){
      return ApiResponse.error(e.toString());
    }
  }


}
