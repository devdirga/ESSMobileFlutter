import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:ess_mobile/models/user_model.dart';
import 'package:ess_mobile/services/attendance_service.dart';
import 'package:ess_mobile/services/survey_service.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/utils/shared_preference.dart';
import 'package:ess_mobile/views/attendance/attendance_screen.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/loadingtext.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class ChechInOutScreen extends StatefulWidget {
  final dynamic filterRequest;
  ChechInOutScreen(this.filterRequest);
  @override
  _ChechInOutScreenState createState() => _ChechInOutScreenState();
}

class _ChechInOutScreenState extends State<ChechInOutScreen> {
  List<LocationModel> locations = [], nearest = [], locationlist = [];
  LocationModel selectedLocation = new LocationModel(), currentLocation = new LocationModel();
  List<Map<String, dynamic>> _entities = [];
  List<ActivityTypeModel> _activitytypes = [];
  final AttendanceService _attendanceService = AttendanceService();
  bool ready  = false, allready = false;
  final SurveyService _surveyService = SurveyService();
  bool _loading = false;
  bool isInRadius = false;
  NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
  AppSharedPreference _sharedPrefsHelper = AppSharedPreference(); 

  @override
  void initState() {
    super.initState();
    _sharedPrefsHelper.isDisclaimerLoc.then((statusValue) {
      if(statusValue == false){
        _showDialog();
      }
      else {
        getCurrentLocation();
      }
    });
    
    
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().status != AppStatus.Authenticated) {
        context.read<AuthProvider>().signOut();
        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, ModalRoute.withName(Routes.login));
      }
    });
  }

  _showDialog() async {
    await Future.delayed(Duration(milliseconds: 50));
    
    showDialog(context: context, builder: (BuildContext context) => new AlertDialog(
      title: new Text("Location Authorization"),
      content: new Text("In order to guarantee the app functionality, the location access is absolute neccessary.\n" + 
      "Therefore you should allow access to the location of this device.\n"+
      "ESS TPS will collect location data even when your app is in background to enable:\n"+
      "- checking your current location for Attendance\n"+
      "- measuring the distance between your current location for validate absence"),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: (){
            _sharedPrefsHelper.saveDisclaimerLoc(true);
            getCurrentLocation();
            Navigator.of(context).pop();
        }, child: new Text("OK"))
      ]
    ));
  }

  getCurrentLocation() async {
    Location loc = new Location();
    bool srvUp = await loc.serviceEnabled();
    if (!srvUp) {
      srvUp = await loc.requestService();
      if (srvUp) {
        PermissionStatus granted = await loc.hasPermission();
        if (granted == PermissionStatus.denied) {
          granted = await loc.requestPermission();
          if (granted != PermissionStatus.granted) {
            ready = true;
          } else {
            ready = false;
          }
        } else {
          ready = true;
        }
      }
    } else {
      ready = true;
    }
    if (ready) {
      await _attendanceService.entities().then((v) {
        if (v.status == ApiStatus.COMPLETED){
          if (v.data.data.length > 0){
            v.data.data.forEach((i) {_entities.add(i.toJson());});
            _entities.forEach(( element) {
              _activitytypes = element['activityTypes'];
              locationlist = element['locations'];
            });
            loc.getLocation().then((d) {
              if(this.mounted){
                setState(() {
                  currentLocation.latitude = d.latitude!;
                  currentLocation.longitude = d.longitude!;

                  // nearest = getNearestLoc(currentLocation.latitude, currentLocation.longitude, locationlist);
                  // selectedLocation = chooseLocation(nearest);
                  nearest = getAssignedLocation(currentLocation.latitude, currentLocation.longitude, locationlist);
                  selectedLocation = chooseAssignedLocation(nearest);
                  _loading = false;
                  allready = true;
                });
              }    
            });
          }
        }
      });      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingOverlay(
        child: Container(
          child: Column(
            children: [
              Flexible(
                child: allready ?
                  Column(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border.all(color: Colors.blue), color: Colors.blue),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: DropdownButton(
                            dropdownColor: Colors.blue,
                            focusColor: Colors.white,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            value:selectedLocation.code,
                            items:nearest.map((data) {
                              return DropdownMenuItem(
                                value: data.code,
                                child: Text('${data.name!} - (${myFormat.format(data.distance!.roundToDouble()).replaceAll(",", ".")} m) ${myFormat.format(data.radius!.roundToDouble()).replaceAll(",", ".")} m',style: TextStyle(fontSize: 14,color: Colors.white))
                              );
                            }).toList(),
                            onChanged: (v) {
                              if(this.mounted){
                                setState(() {
                                  selectedLocation = nearest.singleWhere((e) => e.code == v);
                                  if(selectedLocation.isInRadius == true){
                                    isInRadius = true;
                                  }else{
                                    isInRadius = false;
                                  }
                                });
                              }
                            }
                          )
                        )
                      )
                    ),
                    Flexible(
                      flex: 10,
                      child: (_entities.length > 0) ? 
                        new FlutterMap(
                        options: new MapOptions(center: new latlng.LatLng(currentLocation.latitude!, currentLocation.longitude!)),
                        layers: [
                          new TileLayerOptions(
                            urlTemplate: _entities.first['mapboxTemplate'],
                            additionalOptions: {'accessToken':_entities.first['mapboxToken'],'id': _entities.first['mapboxId']}),
                          new MarkerLayerOptions(markers: [
                            Marker(point: latlng.LatLng(currentLocation.latitude!, currentLocation.longitude!),builder: (ctx) => Icon(Icons.pin_drop,color: Colors.red, size: 25,))
                          ])
                        ]
                      ) :  AppLoadingText(loadingMessage: 'Rendering map ...')
                    ), 
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (){},
                          label: Text('Current location : ${currentLocation.latitude.toString()} , ${currentLocation.longitude.toString()}'),
                          icon: Icon(Icons.info_outlined),
                          style: ElevatedButton.styleFrom(primary: Colors.black)
                        )
                      )
                    ),
                    Flexible(
                      flex: 2,
                      child: (nearest.length > 0 && isInRadius == true) ?
                        Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(2),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (globals.appAuth.user!.isSelfieAuth!.toLowerCase() =="yes") {
                                    await ImagePicker().pickImage( source: ImageSource.camera).then((photo) {
                                      selfiecheckinout(File(photo!.path),'IN');
                                    });
                                  } else {
                                    final LocalAuthentication bioAuth = LocalAuthentication();
                                    bool isBioSupport = await bioAuth.isDeviceSupported();
                                    bool isBioCheck = await bioAuth.canCheckBiometrics;
                                    if (isBioSupport && isBioCheck) {
                                      List<BiometricType> biotypes = await bioAuth.getAvailableBiometrics();
                                      String biostring = 'BIO=>';
                                      biotypes.forEach((element) {
                                        biostring = biostring + element.toString() + '|';
                                      });
                                      await bioAuth.authenticate(localizedReason:'Biometric').then((auth){
                                        if(auth){
                                          biometriccheckinout('IN');
                                        }
                                      }).onError((error, stackTrace) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              action: SnackBarAction(label: 'ERR',onPressed: () {}),
                                              content:  Text(error.toString()),
                                              duration: const Duration(milliseconds: 5000),
                                              behavior: SnackBarBehavior.floating
                                            )
                                        );
                                      });                                      
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            action: SnackBarAction(label: 'OK',onPressed: () {}),
                                            content:  Text('Biometric not available'),
                                            duration: const Duration(milliseconds: 5000),
                                            behavior: SnackBarBehavior.floating
                                          )
                                      );
                                    }
                                  }
                                },
                                label: Text('Check in'),
                                icon: Icon(Icons.login_outlined),
                                style: ElevatedButton.styleFrom(primary: Colors.green)
                              )
                            )
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(2),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                    if (globals.appAuth.user!.isSelfieAuth!.toLowerCase() =="yes") {
                                      await ImagePicker().pickImage( source: ImageSource.camera).then((photo) {
                                        selfiecheckinout(File(photo!.path),'OUT');
                                      });
                                    } else {
                                      final LocalAuthentication bioAuth = LocalAuthentication();
                                      bool isBioSupport = await bioAuth.isDeviceSupported();
                                      bool isBioCheck = await bioAuth.canCheckBiometrics;
                                      if (isBioSupport && isBioCheck) {
                                        await bioAuth.authenticate(localizedReason:'Biometric').then((auth) {
                                          if (auth) {
                                            biometriccheckinout('OUT');
                                          }
                                        });
                                      }
                                    }
                                },
                                label: Text('Check out'),
                                icon: Icon(Icons.logout_outlined),
                                style: ElevatedButton.styleFrom(primary: Colors.blue)
                              )
                            )
                          )
                        ]
                      ): 
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (){},
                                label: Text('you are too far from ${selectedLocation.name}'),
                                icon: Icon(Icons.not_listed_location_outlined),
                                style: ElevatedButton.styleFrom(primary: Colors.red)
                              )
                            )
                          )
                        ]
                      )
                    ),
                    Flexible(
                      // flex: 2,
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (){
                            getCurrentLocation();
                          }, 
                          label: Text('Update my location'),
                          icon: Icon(Icons.my_location),
                          style: ElevatedButton.styleFrom(primary: Colors.black)
                        ),
                      ),
                    )
                  ]
                ) : AppLoading()
              )
            ]
          )
        ),
        isLoading: _loading,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator()
      ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  LocationModel chooseLocation(List<LocationModel> locs){
    try{      
      bool isVirtual = locs.any((e) => e.isVirtual == true);
      if(isVirtual){
        return locs.singleWhere((e) => e.isVirtual == true);
      }else{
        LocationModel l = new LocationModel();
        locs.forEach((e) { 
          if(e.isVirtual == false){
            l = e;
          }
        });
        return l;
      }
    } on Exception catch(_){
      return new LocationModel();
    }
  }

  List<LocationModel> getNearestLoc(double? lat, double? long, List<LocationModel> locs) {
    List<LocationModel> nearest = [];
    try {
      locs.forEach((e) {
        if (e.isVirtual == true) {
          nearest.add(e);
        } else {

          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((e.latitude! - lat!) * p) / 2 +
            c(lat * p) * c(e.latitude! * p) *
            (1 - c((e.longitude! - long!) * p)) / 2;
          var n = 12742 * asin(sqrt(a)) * 1000;

          if (n <= e.radius!) {
            nearest.add(e);
          }
        }
      });      
      return nearest;
    } on Exception catch (_) {
      return nearest;
    }
  }

  List<LocationModel> getAssignedLocation(double? lat, double? long, List<LocationModel> locs){
    List<LocationModel> assigned = [];
    try{
      locs.forEach((e) {
        if(e.isVirtual==true){
          e.distance = 0;
          e.isInRadius = true;
          assigned.add(e);
        }else{
          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((e.latitude! - lat!) * p) / 2 +
            c(lat * p) * c(e.latitude! * p) *
            (1 - c((e.longitude! - long!) * p)) / 2;
          var n = 12742 * asin(sqrt(a)) * 1000;
          e.distance = n;
          if(n<=e.radius!){
            e.isInRadius = true;
          }else{
            e.isInRadius = false;
          }
          assigned.add(e);
        }
      });
      return assigned;
    } on Exception catch (_) {
      return assigned;
    }
  }

  LocationModel chooseAssignedLocation(List<LocationModel> locs){
    try{
      LocationModel loc = locs.first;
      bool inRad = false;
      if(loc.isInRadius==true){
        inRad = true;
      }else{
        inRad = false;
      }
      setState(() {
        isInRadius = inRad;
      });
      return loc;
    } on Exception catch(_){
      return new LocationModel();
    }
  }

  void biometriccheckinout(String type) async {
    setState(() {
      _loading = true;
    });
    bool temporary = false;
    await _surveyService.surveys(globals.getFilterRequest()).then((res) {
      if (res.status == ApiStatus.COMPLETED){
        if (res.data.data.length > 0){
          List<Map<String, dynamic>> entitySurvey = [];
          res.data.data.forEach((i) {
            entitySurvey.add(i.toJson());
          });
          entitySurvey.forEach((element) {
            if(element['AlreadyFilled']== false && element['IsRequired']== true){
              temporary = true;
            }
          });
        }       

        _attendanceService.biometriccheckinout(JsonEncoder().convert(
        new AttendanceModel(
          typeID: 'biometric',
          activityTypeID: ((type=="IN") ? _activitytypes.firstWhere((e) => e.name=='Checkin') : _activitytypes.firstWhere((e) => e.name=='Checkout')).id,
          entityID: _entities.first['id'],
          locationID: selectedLocation.code,
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          inOut: type,
          employeeID: globals.appAuth.user!.username.toString(),
          temporary: temporary
        ).toJson())).then((upl) {
          setState(() {
            _loading = false;
          });
          if (upl.status == ApiStatus.ERROR) {
            AppSnackBar.danger(context, upl.message);
          }
          if (upl.status == ApiStatus.COMPLETED) {

            if (upl.data['StatusCode'] == 200) {
              // Navigator.pop(context);
              // Navigator.of(context).pushNamedAndRemoveUntil(
              // Routes.attendance,
              // ModalRoute.withName(Routes.attendance));

              if(temporary){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      action: SnackBarAction(label: 'OK',onPressed: () {}),
                      // content:  Text('${upl.data['Message'].toString()}'),
                      content: Text('Ada survey yang harus diisi, di mohon membuka halaman survey'),
                      duration: const Duration(milliseconds: 5000),
                      behavior: SnackBarBehavior.floating
                    )
                );
              } else {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      action: SnackBarAction(label: 'OK',onPressed: () {}),
                      content:  Text('${upl.data['Message'].toString()}'),
                      // content: Text('Ada survey yang harus diisi, di mohon membuka halaman survey'),
                      duration: const Duration(milliseconds: 5000),
                      behavior: SnackBarBehavior.floating
                    )
                );
              }
              
              // to another tab
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> AttendanceScreen(selectedPage: 1)));
            }
            if (upl.data['StatusCode'] == 400) {
              setState(() {
                _loading = false;
              });
              AppSnackBar.danger(context, upl.data['Message'].toString());
            }
          }
        }).onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                action: SnackBarAction(label: 'ERROR',onPressed: () {}),
                // content:  Text('${upl.data['Message'].toString()}'),
                content: Text(error.toString()),
                duration: const Duration(milliseconds: 5000),
                behavior: SnackBarBehavior.floating
              )
          );
        });
      }
    }); 



    // await _attendanceService.biometriccheckinout(
    //   JsonEncoder().convert(
    //     new AttendanceModel(
    //       typeID: 'biometric',
    //       activityTypeID: ((type=="IN") ? _activitytypes.firstWhere((e) => e.name=='Checkin') : _activitytypes.firstWhere((e) => e.name=='Checkout')).id,
    //       entityID: _entities.first['id'],
    //       locationID: selectedLocation.code,
    //       latitude: currentLocation.latitude,
    //       longitude: currentLocation.longitude,
    //       inOut: type,
    //       employeeID: globals.appAuth.user!.username.toString(),
    //       temporary: temporary
    //     ).toJson())).then((upl) {
    //       if (upl.status == ApiStatus.ERROR) {
    //         AppSnackBar.danger(context, upl.message);
    //       }
    //       if (upl.status == ApiStatus.COMPLETED) {
    //         if (upl.data['StatusCode'] == 200) {              
    //           Navigator.pop(context);
    //           Navigator.of(context).pushNamedAndRemoveUntil(
    //           Routes.attendance,
    //           ModalRoute.withName(Routes.attendance));
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //                 action: SnackBarAction(label: 'OK',onPressed: () {}),
    //                 content:  Text('${upl.data['Message'].toString()}'),
    //                 duration: const Duration(milliseconds: 3000),
    //                 behavior: SnackBarBehavior.floating
    //               )
    //           );
    //           // to another tab
    //           Navigator.push(context, MaterialPageRoute(builder: (context)=> AttendanceScreen(selectedPage: 1)));
    //         }
    //         if (upl.data['StatusCode'] == 400) {
    //           AppSnackBar.danger(context, upl.data['Message'].toString());
    //         }
    //       }
    //     }
    //   );


      Future.delayed(Duration.zero, () async {
        setState(() {
          _loading = false;
        });
      });

  }

  void selfiecheckinout(File file, String type,) async{
    setState(() {
      _loading = true;
    });
    bool temporary = false;
    await _surveyService.surveys(globals.getFilterRequest()).then((res) {
      if (res.status == ApiStatus.COMPLETED){
        if (res.data.data.length > 0){
          List<Map<String, dynamic>> entitySurvey = [];
          res.data.data.forEach((i) {
            entitySurvey.add(i.toJson());
          });
          entitySurvey.forEach((element) {
            if(element['AlreadyFilled']== false && element['IsRequired']== true){
              temporary = true;
            }
          });
        }

        _attendanceService.selfiecheckinout(file, JsonEncoder().convert(
          new AttendanceModel(
            typeID: 'photo',
            activityTypeID: ((type=="IN") ? _activitytypes.firstWhere((e) => e.name=='Checkin') : _activitytypes.firstWhere((e) => e.name=='Checkout')).id,
            entityID: _entities.first['id'],
            locationID: selectedLocation.code,
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            inOut: type,
            employeeID: globals.appAuth.user!.username.toString(),
            temporary: temporary
          ).toJson())).then((upl) {
            setState(() {
              _loading = false;
            });
            if (upl.status == ApiStatus.ERROR) {
              AppSnackBar.danger(context, upl.message);
            }
            if (upl.status == ApiStatus.COMPLETED){
              if (upl.data['StatusCode'] == 200){
                if(temporary){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        action: SnackBarAction(label: 'OK',onPressed: () {}),
                        // content:  Text('${upl.data['Message'].toString()}'),
                        content: Text('Ada survey yang harus diisi, di mohon membuka halaman survey'),
                        duration: const Duration(milliseconds: 5000),
                        behavior: SnackBarBehavior.floating
                      )
                  );
                } else {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        action: SnackBarAction(label: 'OK',onPressed: () {}),
                        content:  Text('${upl.data['Message'].toString()}'),
                        // content: Text('Ada survey yang harus diisi, di mohon membuka halaman survey'),
                        duration: const Duration(milliseconds: 5000),
                        behavior: SnackBarBehavior.floating
                      )
                  );
                }
              }
              if (upl.data['StatusCode'] == 400) {
                AppSnackBar.danger(context, upl.data['Message'].toString());
              }
            }
          }).onError((error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  action: SnackBarAction(label: 'ERROR',onPressed: () {}),
                  // content:  Text('${upl.data['Message'].toString()}'),
                  content: Text(error.toString()),
                  duration: const Duration(milliseconds: 5000),
                  behavior: SnackBarBehavior.floating
                )
            );
          });
      }
    });

    // await _attendanceService.selfiecheckinout(file,JsonEncoder().convert(
    //   new AttendanceModel(
    //     typeID: 'photo',
    //     activityTypeID: ((type=="IN") ? _activitytypes.firstWhere((e) => e.name=='Checkin') : _activitytypes.firstWhere((e) => e.name=='Checkout')).id,
    //     entityID: _entities.first['id'],
    //     locationID: selectedLocation.code,
    //     latitude: currentLocation.latitude,
    //     longitude: currentLocation.longitude,
    //     inOut: type,
    //     employeeID: globals.appAuth.user!.username.toString()
    //   ).toJson())).then((upl) {
    //     if (upl.status == ApiStatus.ERROR) {
    //       AppSnackBar.danger(context, upl.message);
    //     }
    //     if (upl.status == ApiStatus.COMPLETED) {
    //       if (upl.data['StatusCode'] == 200) {
    //         // AppSnackBar.success(context, upl.data['Message'].toString());
    //         Navigator.pop(context);
    //         Navigator.of(context).pushNamedAndRemoveUntil(
    //         Routes.attendance,
    //         ModalRoute.withName(Routes.attendance));
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //               action: SnackBarAction(label: 'OK',onPressed: () {}),
    //               content:  Text('${upl.data['Message'].toString()}'),
    //               duration: const Duration(milliseconds: 3000),
    //               behavior: SnackBarBehavior.floating
    //             )
    //         );
    //         // to another tab
    //           Navigator.push(context, MaterialPageRoute(builder: (context)=> AttendanceScreen(selectedPage: 1)));
    //       }
    //       if (upl.data['StatusCode'] == 400) {
    //         AppSnackBar.danger(context, upl.data['Message'].toString());
    //       }
    //     }
    //   }
    // );

    Future.delayed(Duration.zero, () async {
      setState(() {
        _loading = false;
      });
    });
  }
}