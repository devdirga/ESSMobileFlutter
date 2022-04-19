import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/common_service.dart';
import 'package:ess_mobile/services/resume_service.dart';
import 'package:ess_mobile/services/family_service.dart';
import 'package:ess_mobile/services/certificate_service.dart';
import 'package:ess_mobile/services/leave_service.dart';
import 'package:ess_mobile/services/time_management_service.dart';
import 'package:ess_mobile/services/travel_service.dart';
import 'package:ess_mobile/services/complaint_service.dart';
import 'package:ess_mobile/models/common_model.dart';

class TaskActiveScreen extends StatefulWidget {
  final dynamic filterRequest;

  TaskActiveScreen(this.filterRequest);

  @override
  _TaskActiveScreenState createState() => _TaskActiveScreenState();
}

class _TaskActiveScreenState extends State<TaskActiveScreen> {
  final CommonService _commonService = CommonService();
  final ResumeService _resumeService = ResumeService();
  final FamilyService _familyService = FamilyService();
  final CertificateService _certificateService = CertificateService();
  final LeaveService _leaveService = LeaveService();
  final TimeManagementService _timeManagementService = TimeManagementService();
  final TravelService _travelService = TravelService();
  final ComplaintService _complaintService = ComplaintService();

  Future<ApiResponse<dynamic>>? _taskActive;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().status != AppStatus.Authenticated) {
        context.read<AuthProvider>().signOut();

        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.login,
          ModalRoute.withName(Routes.login),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _taskActive = _commonService.taskHistory(widget.filterRequest);

    return _container(context);
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _taskActive,
        builder: (context, snapshot) {
          List<Widget> _children = <Widget>[];

          if (snapshot.hasError) {
            AppSnackBar.danger(context, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            var _response = snapshot.data?.data;

            switch (snapshot.data!.status) {
              case ApiStatus.LOADING:
                return AppLoading(
                  loadingMessage: snapshot.data!.message,
                );

              case ApiStatus.COMPLETED:
                if (_response.data.length > 0) {
                  Map<String, List<TaskModel>> _dataMap = {};

                  _response.data.sort((a, b) {
                    return a.submitDateTime
                        .toString()
                        .compareTo(b.submitDateTime.toString());
                  });

                  _response.data.reversed.forEach((v) {
                    DateTime _submitDateTime = DateFormat('yyyy-MM-ddTHH:mm:ss')
                        .parse(v.submitDateTime.toString(), false)
                        .toLocal();
                    String _title =
                        DateFormat('EEEE, dd MMM yyyy').format(_submitDateTime);

                    if (!_dataMap.containsKey(_title)) {
                      _dataMap[_title] = <TaskModel>[];
                    }

                    _dataMap[_title]!.add(v);
                  });

                  bool _expanded = true;

                  _dataMap.forEach((k, v) {
                    _children.add(
                      _buildExpansionTile(context, k, v, _expanded),
                    );
                    _expanded = false;
                  });
                } else {
                  _children.add(
                    ListTile(
                      title: Center(child: Text('No Data Available')),
                    ),
                  );
                }

                if (_response.message != null) {
                  return AppError(
                    errorMessage: _response.message,
                    onRetryPressed: () => setState(() {
                      _taskActive =
                          _commonService.taskHistory(widget.filterRequest);
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _taskActive =
                        _commonService.taskHistory(widget.filterRequest);
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done) && _loading == false
              ? ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: _children,
                )
              : AppLoading();
        },
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    String title,
    List<TaskModel> items,
    bool expanded,
  ) {
    List<Widget> _children = <Widget>[];

    if (items.length > 0) {
      items.asMap().forEach((i, v) {
        v.title ??= '';
        v.instanceId ??= '';
        v.submitEmployeeID ??= '';
        v.submitEmployeeName ??= '';
        v.reason ??= '';

        DateTime _submitDateTime = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(v.submitDateTime!, false)
            //.add(Duration(hours: 7))
            .toLocal();

        _children.add(
          ClipRRect(
            child: Container(
              color: (i % 2 == 0)
                  ? Colors.blueGrey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      v.title.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${v.instanceId.toString()} - Approval ${v.sequence.toString()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme!
                            .secondary
                            .withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${v.submitEmployeeName.toString()} / ${v.submitEmployeeID.toString()} / ${DateFormat('EEE, dd MMM yyyy HH:mm').format(_submitDateTime)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Reason : ${v.reason.toString()}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        (v.assignApprove == true)
                            ? ElevatedButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('Approve'),
                                  style: TextStyle(color: Colors.green),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).cardColor,
                                  side: BorderSide(color: Colors.green),
                                ),
                                onPressed: () => _approve(v),
                              )
                            : Container(),
                        (v.assignApprove == true)
                            ? Expanded(
                                child: Container(),
                              )
                            : Container(),
                        (v.assignCancel == true && v.trackingStatus == 0)
                            ? ElevatedButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('Cancel'),
                                  style: TextStyle(color: Colors.orange),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).cardColor,
                                  side: BorderSide(color: Colors.orange),
                                ),
                                onPressed: () => _cancel(v),
                              )
                            : Container(),
                        (v.assignCancel == true && v.trackingStatus == 0)
                            ? Expanded(
                                child: Container(),
                              )
                            : Container(),
                        (v.assignReject == true)
                            ? ElevatedButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('Reject'),
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).cardColor,
                                  side: BorderSide(color: Colors.red),
                                ),
                                onPressed: () => _reject(v),
                              )
                            : Container(),
                        (v.assignReject == true)
                            ? Expanded(
                                child: Container(),
                              )
                            : Container(),
                        ElevatedButton(
                          child: Text(
                            AppLocalizations.of(context).translate('Detail'),
                            style: TextStyle(color: Colors.blue),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).cardColor,
                            side: BorderSide(color: Colors.blue),
                          ),
                          onPressed: () => _detail(v),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.double_arrow,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          initiallyExpanded: expanded,
          children: _children,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _countTask() async {
    /*_commonService.mTaskActive(widget.filterRequest).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (this.mounted) {
          setState(() {
            globals.totalTask = v.data.data.length;
          });
        }
      }
    });*/
    _commonService.taskHistory(widget.filterRequest).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (this.mounted) {
          setState(() {
            globals.totalTask = v.data.data.length;
          });
        }
      }
    });
  }

  void _approve(TaskModel item) async {
    AppAlert(context).approve(
      title: item.title.toString(),
      desc:
          '${item.submitEmployeeName.toString()} / ${item.submitEmployeeID.toString()}',
      yes: () async {
        setState(() {
          _loading = true;
        });

        Map<String, dynamic> body = {
          'InstanceId': item.instanceId,
          'AXID': item.axid,
          'OriginatorEmployeeID': item.submitEmployeeID,
          'ActionEmployeeID': item.assignToEmployeeID,
          'ActionEmployeeName': item.assignToEmployeeName,
          'Notes': ''
        };

        ApiResponse<dynamic> result = await _commonService.taskSave(
          'MApprove',
          body,
        );

        if (result.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, result.message);
        }

        if (result.status == ApiStatus.COMPLETED) {
          if (result.data.statusCode == 200) {
            AppSnackBar.success(context, result.data.message.toString());
            setState(() {});
            _countTask();
          }

          if (result.data.statusCode == 400) {
            AppSnackBar.danger(context, result.data.message.toString());
            setState(() {});
          }
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _loading = false;
          });
        });
      },
    );
  }

  void _cancel(TaskModel item) async {
    AppAlert(context).cancel(
      title: item.title.toString(),
      desc:
          '${item.submitEmployeeName.toString()} / ${item.submitEmployeeID.toString()}',
      yes: (String? val) async {
        setState(() {
          _loading = true;
        });

        item.comment = val.toString().trim();

        Map<String, dynamic> body = {
          'InstanceId': item.instanceId,
          'AXID': item.axid,
          'OriginatorEmployeeID': item.submitEmployeeID,
          'ActionEmployeeID': item.assignToEmployeeID,
          'ActionEmployeeName': item.assignToEmployeeName,
          'Notes': item.comment
        };

        ApiResponse<dynamic> result = await _commonService.taskSave(
          'MCancel',
          body,
        );

        if (result.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, result.message);
        }

        if (result.status == ApiStatus.COMPLETED) {
          if (result.data.statusCode == 200) {
            AppSnackBar.success(context, result.data.message.toString());
            setState(() {});
          }

          if (result.data.statusCode == 400) {
            AppSnackBar.danger(context, result.data.message.toString());
            setState(() {});
          }

          _countTask();
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _loading = false;
          });
        });
      },
    );
  }

  void _reject(TaskModel item) async {
    AppAlert(context).reject(
      title: item.title.toString(),
      desc:
          '${item.submitEmployeeName.toString()} / ${item.submitEmployeeID.toString()}',
      yes: (String? val) async {
        setState(() {
          _loading = true;
        });

        item.comment = val.toString().trim();

        Map<String, dynamic> body = {
          'InstanceId': item.instanceId,
          'AXID': item.axid,
          'OriginatorEmployeeID': item.submitEmployeeID,
          'ActionEmployeeID': item.assignToEmployeeID,
          'ActionEmployeeName': item.assignToEmployeeName,
          'Notes': item.comment
        };

        ApiResponse<dynamic> result = await _commonService.taskSave(
          'MReject',
          body,
        );

        if (result.status == ApiStatus.ERROR) {
          AppSnackBar.danger(context, result.message);
        }

        if (result.status == ApiStatus.COMPLETED) {
          if (result.data.statusCode == 200) {
            AppSnackBar.success(context, result.data.message.toString());
            setState(() {});
          }

          if (result.data.statusCode == 400) {
            AppSnackBar.danger(context, result.data.message.toString());
            setState(() {});
          }

          _countTask();
        }

        Future.delayed(Duration.zero, () async {
          setState(() {
            _loading = false;
          });
        });
      },
    );
  }

  void _detail(TaskModel item) async {
    setState(() {
      _loading = true;
    });

    try {
      switch (item.requestType) {
        case 0:
          _resumeService
              .profileByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.resumeDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 1:
          _familyService
              .familyByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.familyDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 2:
          // Course
          break;
        case 3:
          _certificateService
              .certificateByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.certificateDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 4:
          _leaveService
              .leaveByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.leaveDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 5:
          _timeManagementService
              .timeAttendanceByInstance(
                  item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.absenceDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 6:
          _travelService
              .travelByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.sppdDetail,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 7:
          // Benefit
          break;
        case 8:
          // Recruitment
          break;
        case 9:
          // Retirement
          break;
        case 10:
          _complaintService
              .complaintByInstance(item.submitEmployeeID!, item.instanceId!)
              .then((v) {
            setState(() {
              _loading = false;
            }); 

            if (v.status == ApiStatus.COMPLETED) {
              if (v.data.data != null) {
                Map<String, dynamic> _item = v.data.data.toJson();
                _item['Readonly'] = true;
                _item['TrackingStatus'] = item.trackingStatus;
                _item['TrackingStatusDescription'] = item.trackingStatusDescription;

                globals.params = {'User': _item['EmployeeID']};

                Future.delayed(Duration(seconds: 2), () async {
                  Navigator.pushNamed(
                    context,
                    Routes.complaintEntry,
                    arguments: _item,
                  );
                });
              } else {
                AppAlert(context).noData(title: item.title.toString());
              }
            }
          });
          break;
        case 12:
          // Document Request
          break;
        default:
      }
    } catch (e) {
      //
    }
  }
}
