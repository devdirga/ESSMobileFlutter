import 'dart:io';
import 'dart:convert';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/medical_record_model.dart';
import 'package:ess_mobile/services/master_service.dart';

class MedicalRecordService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;
  late String _localPath;

  MasterService _masterService = MasterService();

  Future<ApiResponse> medicalRecords(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Medical Records');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetMedicalRecords/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<MedicalRecordModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(MedicalRecordModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<File> getMedicalRecordFile(String token, String filename) async {
    var reqBody = {
      'token': token
    };
    
    final response = await _restApi.post(
      '${globals.apiUrl}/ess/employee/MDownloadMedicalRecord',
      body: json.encode(reqBody),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
      },
    );
    
    _localPath = (await _masterService.findLocalPath())!;
    final savedDir = Directory(_localPath);
    String tempPath = savedDir.path;
    File file = new File('$tempPath/$filename');
    file.writeAsBytes(response.bodyBytes);

    return file;
  }
}
