import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/employment_service.dart';
import 'package:ess_mobile/models/employment_model.dart';

class EmploymentScreen extends StatefulWidget {
  @override
  _EmploymentScreenState createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> {
  final EmploymentService _employmentService = EmploymentService();

  Future<ApiResponse<dynamic>>? _employments;

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

    _employments = _employmentService.employments(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Employment')),
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
        future: _employments,
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
                      _employments = _employmentService
                          .employments(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _employments = _employmentService
                        .employments(globals.getFilterRequest());
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
    EmploymentModel items,
    bool expanded,
  ) {

    DateTime _assigmentDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.assigmentDate!.start!, false)
        .toLocal();
    DateTime _assigmentDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.assigmentDate!.finish!, false)
        .toLocal();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: items.primaryPosition! ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ) : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.grey, Colors.grey.shade300],
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
                  items.description!,
                  style: Theme.of(context).primaryTextTheme.subtitle1
                ),
                SizedBox(height: 5),
                Text(
                  DateFormat('dd/MM/yyyy').format(_assigmentDateStart) + ' - ' + DateFormat('dd/MM/yyyy').format(_assigmentDateFinish),
                  style: Theme.of(context).primaryTextTheme.bodyText1
                )
              ],
            )
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DataCell> _dataCells(EmploymentModel item) {
    item.description ??= '';

    DateTime _assigmentDateStart = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.assigmentDate!.start!, false)
        .toLocal();
    DateTime _assigmentDateFinish = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(item.assigmentDate!.finish!, false)
        .toLocal();

    return <DataCell>[
      DataCell(Container(
        width: 210,
        child: Text(item.description.toString()),
      )),
      DataCell(Text(DateFormat('dd MMM yyyy').format(_assigmentDateStart))),
      DataCell(Text(DateFormat('dd MMM yyyy').format(_assigmentDateFinish))),
      DataCell(Text(item.primaryPosition! ? 'Yes' : 'No')),
    ];
  }
}
