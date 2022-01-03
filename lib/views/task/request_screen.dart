import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/common_service.dart';
import 'package:ess_mobile/models/common_model.dart';

class TaskRequestScreen extends StatefulWidget {
  @override
  _TaskRequestScreenState createState() => _TaskRequestScreenState();
}

class _TaskRequestScreenState extends State<TaskRequestScreen> {
  final CommonService _commonService = CommonService();

  Future<ApiResponse<dynamic>>? _updateRequest;

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

    _updateRequest = _commonService.updateRequest(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Activity')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        filter: () {
          AppDateFilter(context).show(yes: (val) {
            setState(() {
              _updateRequest = _commonService
                  .updateRequest(globals.getFilterRequest(params: val));
            });
          });
        },
        refresh: () {
          setState(() {
            _updateRequest =
                _commonService.updateRequest(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _updateRequest,
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
                  Map<String, List<UpdateRequestModel>> _dataMap = {};

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
                      _dataMap[_title] = <UpdateRequestModel>[];
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
                      _updateRequest = _commonService
                          .updateRequest(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _updateRequest = _commonService
                        .updateRequest(globals.getFilterRequest());
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
    String title,
    List<UpdateRequestModel> items,
    bool expanded,
  ) {
    List<Widget> _children = <Widget>[];

    if (items.length > 0) {
      items.asMap().forEach((i, v) {
        v.title ??= '';

        DateTime _submitDateTime = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(v.submitDateTime!, false)
            .add(Duration(hours: 7))
            .toLocal();

        MaterialColor _colorStatus = Colors.lightBlue;

        switch (v.trackingStatus) {
          case 1:
            _colorStatus = Colors.green;
            break;
          case 2:
            _colorStatus = Colors.orange;
            break;
          case 3:
            _colorStatus = Colors.red;
            break;
        }

        _children.add(
          ClipRRect(
            child: Container(
              color: (i % 2 == 0)
                  ? Colors.blueGrey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              child: ListTile(
                title: Text(v.title.toString()),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      DateFormat('EEE, dd MMM yyyy HH:mm')
                          .format(_submitDateTime),
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      ' | ${v.trackingStatusDescription.toString()}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Icon(Icons.check_circle, color: _colorStatus),
              ),
              padding: EdgeInsets.symmetric(vertical: 2.0),
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
}
