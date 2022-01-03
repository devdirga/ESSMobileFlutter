import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/space.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/warning_letter_service.dart';
import 'package:ess_mobile/models/warning_letter_model.dart';

class WarningLetterScreen extends StatefulWidget {
  @override
  _WarningLetterScreenState createState() => _WarningLetterScreenState();
}

class _WarningLetterScreenState extends State<WarningLetterScreen> {
  final WarningLetterService _warningLetterService = WarningLetterService();

  Future<ApiResponse<dynamic>>? _warningLetters;

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

    _warningLetters =
        _warningLetterService.warningLetters(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('WarningLetter')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _warningLetters,
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
                      _warningLetters = _warningLetterService
                          .warningLetters(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _warningLetters = _warningLetterService
                        .warningLetters(globals.getFilterRequest());
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
    WarningLetterModel items,
    bool expanded,
  ) {

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
                  items.codeSP! + ' ' + items.worker!,
                  style: Theme.of(context).primaryTextTheme.subtitle1
                ),
                SizedBox(height: 5),
                Text(
                  items.description!,
                  style: Theme.of(context).primaryTextTheme.bodyText1
                )
              ],
            ),
            trailing: _dataActions(items)
          )
        ),
      ),
    );
  }

  dynamic _dataActions(WarningLetterModel item) {
    return PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
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
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            if (item.accessible!) {
              // globals.launchInBrowser(
              //   '${globals.apiUrl}/employee/warningLetter/download/${globals.appAuth.user?.id}/${item.axid}',
              // );

              Navigator.pushNamed(
                context,
                Routes.downloader,
                arguments: {
                  'name':
                      'Warning Letter (${item.codeSP}, ${item.description})',
                  'link':
                      '${globals.apiUrl}/ess/employee/MDownloadWarningLetters/${globals.appAuth.user?.id}/${item.axid}/${item.filename}/${item.filename}',
                },
              );
            }
          }
        },
      );
  }

  List<DataCell> _dataCells(WarningLetterModel item) {
    item.worker ??= '';
    item.codeSP ??= '';
    item.description ??= '';

    DateTime _scheduleStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.start!, false)
        .toLocal();
    DateTime _scheduleFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.schedule!.finish!, false)
        .toLocal();

    return <DataCell>[
      DataCell(Text(item.worker.toString())),
      DataCell(PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
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
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            if (item.accessible!) {
              // globals.launchInBrowser(
              //   '${globals.apiUrl}/employee/warningLetter/download/${globals.appAuth.user?.id}/${item.axid}',
              // );

              Navigator.pushNamed(
                context,
                Routes.downloader,
                arguments: {
                  'name':
                      'Warning Letter (${item.codeSP}, ${item.description})',
                  'link':
                      '${globals.apiUrl}/ess/employee/MDownloadWarningLetters/${globals.appAuth.user?.id}/${item.axid}/${item.filename}/${item.filename}',
                },
              );
            }
          }
        },
      )),
      DataCell(Text(item.codeSP.toString())),
      DataCell(Container(
        width: 210,
        child: Text(item.description.toString()),
      )),
      DataCell(Text(DateFormat('dd MMM yyyy').format(_scheduleStart))),
      DataCell(Text(DateFormat('dd MMM yyyy').format(_scheduleFinish))),
      DataCell(PopupMenuButton(
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).hintColor,
        ),
        itemBuilder: (context) => [
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
            value: 0,
          ),
        ],
        onSelected: (value) {
          if (value == 0) {
            if (item.accessible!) {
              // globals.launchInBrowser(
              //   '${globals.apiUrl}/employee/warningLetter/download/${globals.appAuth.user?.id}/${item.axid}',
              // );

              Navigator.pushNamed(
                context,
                Routes.downloader,
                arguments: {
                  'name':
                      'Warning Letter (${item.codeSP}, ${item.description})',
                  'link':
                      '${globals.apiUrl}/ess/employee/MDownloadWarningLetters/${globals.appAuth.user?.id}/${item.axid}/${item.filename}',
                },
              );
            }
          }
        },
      )),
    ];
  }
}
