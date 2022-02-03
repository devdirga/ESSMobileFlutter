import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ess_mobile/models/user_model.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AttendanceService {
  RestApi rest = RestApi();
  String? token = globals.appAuth.data;
  String ctype = 'Content-Type';
  String appjson = 'application/json';

  Future<ApiResponse> locations(Map<String, dynamic> b) async {
    try {
      ResponseModel r = ResponseModel.fromJson(
        await rest.get(
          '${globals.apiUrl}/api/user/locations?userID=${b['EmployeeID']}',
          headers: {ctype: appjson,HttpHeaders.authorizationHeader: 'Bearer $token',
        }
      ));
      r.data = [];
      r.tdata.forEach((d){
        r.data.add(LocationModel.fromJson(d));
      });
      return ApiResponse.completed(r);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> entities() async{
    try {
      ResponseModel r = ResponseModel.fromJson(
        await rest.get(
          '${globals.apiUrl}/api/entity/mlist?skip=0&limit=2&search=',
          headers: {ctype: appjson, HttpHeaders.authorizationHeader: 'Bearer $token'}
      ));
      r.data = [];
      r.tdata.forEach((d){
        r.data.add(EntityModel.fromJson(d));
      });
      return ApiResponse.completed(r);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> activitytypes(Map<String, dynamic> b) async {
    try {
      ResponseModel r = ResponseModel.fromJson(
        await rest.get(
          '${globals.apiUrl}/api/activity/type/list?entityID=${b['entityID']}&skip=0&limit=2&search=',
          headers: {ctype: appjson, HttpHeaders.authorizationHeader: 'Bearer $token'}
      ));
      r.data = [];
      r.tdata.forEach((d){
        r.data.add(ActivityTypeModel.fromJson(d));
      });
      return ApiResponse.completed(r);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> activitylogs(Map<String, dynamic> b) async {
    try {
      ResponseModel r = ResponseModel.fromJson(
        await rest.get(
          '${globals.apiUrl}/api/activity/log/lists?skip=${b['skip']}&limit=${b['limit']}',
          headers: {ctype: appjson, HttpHeaders.authorizationHeader: 'Bearer $token'}
      ));
      r.data = [];
      r.tdata.forEach((d){
        r.data.add(ActivityLogModel.fromJson(d));
      });
      return ApiResponse.completed(r);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> selfiecheckinout(File f, String d) async {
    var length = await f.length();
    try{
      final r = http.MultipartRequest('POST', Uri.parse('${globals.apiUrl}/api/absence/doinoutdev'));
      Map<String, String> h = {HttpHeaders.authorizationHeader:'Bearer $token'};
      r.headers.addAll(h);
      r.fields['JsonData'] = d;
      r.files.add(http.MultipartFile(
        'FileUpload',
        new http.ByteStream(f.openRead()).cast(),
        length,
        filename: basename(f.path),
      ));
      return ApiResponse.completed(json.decode(await (await r.send()).stream.bytesToString()));
    }catch(e){
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse> biometriccheckinout(String d) async {
    try{
      final req = http.MultipartRequest('POST', Uri.parse('${globals.apiUrl}/api/absence/doinoutdev'));
      Map<String, String> h = {HttpHeaders.authorizationHeader:'Bearer $token'};
      req.headers.addAll(h);
      req.fields['JsonData'] = d;
      return ApiResponse.completed(json.decode(await (await req.send()).stream.bytesToString()));
    }catch(e){
      return ApiResponse.error(e.toString());
    }
  }
  
}
