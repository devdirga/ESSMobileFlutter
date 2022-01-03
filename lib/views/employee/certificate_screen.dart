import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/alert.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/certificate_service.dart';
import 'package:ess_mobile/models/certificate_model.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final CertificateService _certificateService = CertificateService();

  Future<ApiResponse<dynamic>>? _certificates;

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

    _certificates =
        _certificateService.certificates(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Certificate')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      ),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.certificateEntry,
          ).then((val) {
            setState(() {
              _certificates =
                  _certificateService.certificates(globals.getFilterRequest());
            });
          });
        },
        refresh: () {
          setState(() {
            _certificates =
                _certificateService.certificates(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _certificates,
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
                  bool _expanded = true;
                  _response.data.sort((a, b) {
                    return a.axid.toString().compareTo(b.axid.toString());
                  });

                  // var indexData = 0;
                  _response.data.reversed.forEach((v) {
                    /*_dataRows.add(DataRow(
                      cells: _dataCells(v),
                      color: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        // Even rows will have a grey color.
                        if (indexData.isEven) {
                          return Colors.grey.withOpacity(0.3);
                        }
                        return Colors.white;
                         // Use default value for other states and odd rows.
                      })
                    ));
                    indexData++;
                    */
                    _children.add(_buildExpansionTile(context, v, _expanded));
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
                      _certificates = _certificateService
                          .certificates(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _certificates = _certificateService
                        .certificates(globals.getFilterRequest());
                  }),
                );
            }
          }

          return (snapshot.connectionState == ConnectionState.done)
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

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildExpansionTile(
    BuildContext context,
    CertificateModel items,
    bool expanded,
  ) {

    TextStyle? _textStyle = TextStyle(
      color: (items.status == 0)
          ? Colors.grey
          : Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    if (items.action == 2) {
      _textStyle = TextStyle(
        color: (items.status == 0) ? Colors.grey.shade300 : Colors.red,
        decoration: TextDecoration.lineThrough,
      );
    }

    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.validity!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.validity!.finish!, false)
        .toLocal();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: (items.status == 0) ? [Colors.grey.shade700, Colors.grey.shade500] : [Colors.blueAccent, Colors.lightBlueAccent],
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items.typeDescription!,
                  style: (items.action == 2) ? _textStyle: Theme.of(context).primaryTextTheme.subtitle1
                ),
                SizedBox(height: 5),
                Text(
                  items.note!,
                  style: (items.action == 2) ? _textStyle: Theme.of(context).primaryTextTheme.subtitle2
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('dd/MM/yyyy').format(_scheduledDateStart) + ' - ' + DateFormat('dd/MM/yyyy').format(_scheduledDateFinish),
                  style: (items.action == 2) ? _textStyle: Theme.of(context).primaryTextTheme.bodyText1
                )
              ],
            ),
            trailing: _dataActions(items)
          )
        ),
      ),
    );
  }

  List<DataCell> _dataCells(CertificateModel item) {
    item.typeDescription ??= '';
    item.note ??= '';

    DateTime _scheduledDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.validity!.start!, false)
        .toLocal();
    DateTime _scheduledDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.validity!.finish!, false)
        .toLocal();

    TextStyle? _textStyle = TextStyle(
      color: (item.status == 0)
          ? Colors.grey
          : Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    if (item.action == 2) {
      _textStyle = TextStyle(
        color: (item.status == 0) ? Colors.grey : Colors.red,
        decoration: TextDecoration.lineThrough,
      );
    }

    return <DataCell>[
      DataCell(_dataActions(item)),
      DataCell(Container(
        width: 210,
        child: Text(item.typeDescription!, style: _textStyle),
      )),
      DataCell(Container(
        width: 210,
        child: Text(item.note!, style: _textStyle),
      )),
      DataCell(Text(
        DateFormat('dd MMM yyyy').format(_scheduledDateStart),
        style: _textStyle,
      )),
      DataCell(Text(
        DateFormat('dd MMM yyyy').format(_scheduledDateFinish),
        style: _textStyle,
      )),
      DataCell(Text((item.reqRenew! ? 'Yes' : 'No'), style: _textStyle)),
    ];
  }

  dynamic _dataActions(CertificateModel item) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).hintColor,
      ),
      itemBuilder: (context) => (item.status == 0)
          ? [
              PopupMenuItem(
                child: Row(
                  children: space(10.0, <Widget>[
                    Icon(Icons.hourglass_bottom),
                    Text(
                      AppLocalizations.of(context).translate('WaitingApproval'),
                    ),
                  ]),
                ),
                value: -1,
              ),
            ]
          : [
              (item.action == 0 || item.action == 2)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.edit_off),
                          Text(
                            AppLocalizations.of(context)
                                .translate('DiscardChanges'),
                          ),
                        ]),
                      ),
                      value: 0,
                    ),
              // PopupMenuItem(
              //   child: Row(
              //     children: space(10.0, <Widget>[
              //       Icon(Icons.remove_red_eye),
              //       Text(
              //         AppLocalizations.of(context).translate('ViewData')_,
              //       ),
              //     ]),
              //   ),
              //   value: 1,
              // ),
              (item.action == 2)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.edit_sharp),
                          Text(
                            AppLocalizations.of(context).translate('EditData'),
                          ),
                        ]),
                      ),
                      value: 2,
                    ),
              (item.action == 2)
                  ? PopupMenuItem(height: 0.0, child: SizedBox.shrink())
                  : PopupMenuItem(
                      child: Row(
                        children: space(10.0, <Widget>[
                          Icon(Icons.delete_sharp),
                          Text(
                            AppLocalizations.of(context)
                                .translate('DeleteData'),
                          ),
                        ]),
                      ),
                      value: 3,
                    ),
              PopupMenuItem(
                child: Row(
                  children: space(10.0, <Widget>[
                    Icon(
                      Icons.file_download,
                      color: (item.accessible!)
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                    Text(
                      AppLocalizations.of(context).translate('DownloadFile'),
                      style: (item.accessible!)
                          ? null
                          : TextStyle(color: Theme.of(context).disabledColor),
                    ),
                  ]),
                ),
                value: 4,
              ),
            ],
      onSelected: (value) async {
        if (value == 0) {
          AppAlert(context).discard(
            title: AppLocalizations.of(context).translate('Certificate'),
            yes: () async {
              ApiResponse<dynamic> result = await _certificateService
                  .certificateDiscard(item.id.toString());

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _certificates = _certificateService
                        .certificates(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }
            },
          );
        }

        if (value == 1) {
          Map<String, dynamic> _item = item.toJson();
          _item['Readonly'] = true;

          Navigator.pushNamed(
            context,
            Routes.certificateEntry,
            arguments: _item,
          ).then((val) {
            setState(() {
              _certificates =
                  _certificateService.certificates(globals.getFilterRequest());
            });
          });
        }

        if (value == 2) {
          Navigator.pushNamed(
            context,
            Routes.certificateEntry,
            arguments: item.toJson(),
          ).then((val) {
            setState(() {
              _certificates =
                  _certificateService.certificates(globals.getFilterRequest());
            });
          });
        }

        if (value == 3) {
          AppAlert(context).delete(
            title: AppLocalizations.of(context).translate('Certificate'),
            yes: (reason) async {
              Map<String, dynamic> body = {
                'Id': item.axid,
                'EmployeeID': item.employeeID,
                'Reason': reason,
              };

              ApiResponse<dynamic> result =
                  await _certificateService.certificateDelete(body);

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _certificates = _certificateService
                        .certificates(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }
            },
          );
        }

        if (value == 4) {
          if (item.accessible!) {
            // globals.launchInBrowser(
            //   '${globals.apiUrl}/employee/certificate/download/${globals.appAuth.user?.id}/${item.axid}',
            // );

            Navigator.pushNamed(
              context,
              Routes.downloader,
              arguments: {
                'name': 'Certificate File (${item.typeDescription})',
                'link':
                    '${globals.apiUrl}/ess/employee/MDownloadCertificate/${globals.appAuth.user?.id}/${item.id}/${item.filename}',
              },
            );
          }
        }
      },
    );
  }
}
