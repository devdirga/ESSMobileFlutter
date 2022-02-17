import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
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
import 'package:ess_mobile/services/family_service.dart';
import 'package:ess_mobile/models/family_model.dart';

class FamilyScreen extends StatefulWidget {
  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final FamilyService _familyService = FamilyService();

  Future<ApiResponse<dynamic>>? _families;
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

    _families = _familyService.families(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Family')),
      ),
      main: LoadingOverlay(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: _container(context),
        ),
        isLoading: _loading,
        // demo of some additional parameters
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
      ),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.familyEntry,
          ).then((val) {
            setState(() {
              _families = _familyService.families(globals.getFilterRequest());
            });
          });
        },
        refresh: () {
          setState(() {
            _families = _familyService.families(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _families,
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

                  _response.data.reversed.forEach((v) {
                    if(v.action != 2){
                      _children.add(_buildExpansionTile(context, v, _expanded));
                      _expanded = false;
                    }
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
                      _families =
                          _familyService.families(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _families =
                        _familyService.families(globals.getFilterRequest());
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

  Widget _buildExpansionTile(
    BuildContext context,
    FamilyModel items,
    bool expanded,
  ) {

    TextStyle? _textStyle = TextStyle(
      color: (items.updateRequest == 1)
          ? Colors.grey
          : Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    if (items.action == 2) {
      _textStyle = TextStyle(
        color: (items.updateRequest == 1) ? Colors.red.shade400 : Colors.red,
        decoration: TextDecoration.lineThrough,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: (items.updateRequest == 1) ? [Colors.grey.shade700, Colors.grey.shade500] : [Colors.blueAccent, Colors.lightBlueAccent],
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
                  items.name!,
                  style: (items.action == 2) ? _textStyle: Theme.of(context).primaryTextTheme.subtitle1
                ),
                SizedBox(height: 5),
                Text(
                  items.relationshipDescription!,
                  style: (items.action == 2) ? _textStyle: Theme.of(context).primaryTextTheme.bodyText1
                )
              ],
            ),
            trailing: (items.action == 2) ? null : _dataActions(items)
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(FamilyModel item) {
    item.name ??= '';
    item.genderDescription ??= '';
    item.religionDescription ??= '';
    item.relationshipDescription ??= '';
    item.birthplace ??= '';

    DateTime _birthdate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.birthdate!, false)
        .toLocal();

    TextStyle? _textStyle = TextStyle(
      color: (item.updateRequest == 1)
          ? Colors.grey
          : Theme.of(context).buttonTheme.colorScheme?.onSurface,
    );

    if (item.action == 2) {
      _textStyle = TextStyle(
        color: (item.updateRequest == 1) ? Colors.grey : Colors.red,
        decoration: TextDecoration.lineThrough,
      );
    }

    return <DataCell>[
      DataCell(_dataActions(item)),
      DataCell(Text(item.nik!, style: _textStyle)),
      DataCell(Text(item.name!, style: _textStyle)),
      DataCell(Text(item.genderDescription!, style: _textStyle)),
      DataCell(Text(item.religionDescription!, style: _textStyle)),
      DataCell(Text(item.relationshipDescription!, style: _textStyle)),
      DataCell(Text(
        DateFormat('dd MMM yyyy').format(_birthdate),
        style: _textStyle,
      )),
      DataCell(Text(item.birthplace!, style: _textStyle)),
    ];
  }

  dynamic _dataActions(FamilyModel item) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).hintColor,
      ),
      itemBuilder: (context) => (item.updateRequest == 1)
          ? [
              PopupMenuItem(
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
                    Icon(Icons.hourglass_bottom),
                    Text(
                      AppLocalizations.of(context).translate('WaitingApproval'),
                    ),
                  ]),
                ),
                value: -1,
              )
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
              PopupMenuItem(
                child: Row(
                  children: space(10.0, <Widget>[
                    Icon(Icons.remove_red_eye),
                    Text(
                      AppLocalizations.of(context).translate('ViewData'),
                    ),
                  ]),
                ),
                value: 1,
              ),
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
              /*(item.action == 2 && item.updateRequest != 1)
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
                    ), */
              (item.accessible == true)
                ? PopupMenuItem(
                  child: Row(
                    children: space(10.0, <Widget>[
                      Icon(
                        Icons.file_download
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('DownloadDocument')
                      ),
                    ]),
                  ),
                  value: 4,
                )
                : PopupMenuItem(height: 0.0, child: SizedBox.shrink()),
            ],
      onSelected: (value) async {
        if (value == 0) {
          AppAlert(context).discard(
            title: AppLocalizations.of(context).translate('Family'),
            yes: () async {
              setState(() {
                _loading = true;
              });

              ApiResponse<dynamic> result =
                  await _familyService.familyDiscard(item.id.toString());

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _families =
                        _familyService.families(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }

              Future.delayed(Duration(seconds: 3), () async {
                setState(() {
                  _loading = false;
                });
              });
            },
          );
        }

        if (value == 1) {
          Map<String, dynamic> _item = item.toJson();
          _item['Readonly'] = true;

          Navigator.pushNamed(
            context,
            Routes.familyEntry,
            arguments: _item,
          ).then((val) {
            setState(() {
              _families = _familyService.families(globals.getFilterRequest());
            });
          });
        }

        if (value == 2) {
          Navigator.pushNamed(
            context,
            Routes.familyEntry,
            arguments: item.toJson(),
          ).then((val) {
            setState(() {
              _families = _familyService.families(globals.getFilterRequest());
            });
          });
        }

        if (value == 3) {
          AppAlert(context).delete(
            title: AppLocalizations.of(context).translate('Family'),
            yes: (reason) async {
              setState(() {
                _loading = true;
              });

              Map<String, dynamic> body = {
                'Id': item.axid,
                'EmployeeID': item.employeeID,
                'Reason': reason,
              };

              ApiResponse<dynamic> result =
                  await _familyService.familyDelete(body);

              if (result.status == ApiStatus.ERROR) {
                AppSnackBar.danger(context, result.message);
              }

              if (result.status == ApiStatus.COMPLETED) {
                if (result.data.statusCode == 200) {
                  AppSnackBar.success(context, result.data.message.toString());

                  setState(() {
                    _families =
                        _familyService.families(globals.getFilterRequest());
                  });
                }

                if (result.data.statusCode == 400) {
                  AppSnackBar.danger(context, result.data.message.toString());
                }
              }

              Future.delayed(Duration(seconds: 3), () async {
                setState(() {
                  _loading = false;
                });
              });
              
            },
          );
        }

        if (value == 4) {
          if (item.accessible!) {
            // globals.launchInBrowser(
            //   '${globals.apiUrl}/employee/family/document/download/${globals.appAuth.user?.id}/${item.axid}',
            // );

            Navigator.pushNamed(
              context,
              Routes.downloader,
              arguments: {
                'name': 'Document Verification (${item.name})',
                'link':
                    '${globals.apiUrl}/ess/employee/MDownloadFamilyDocument/${globals.appAuth.user?.id}/${item.axid}/${item.filename}',
              },
            );
          }
        }
      },
    );
  }
}
