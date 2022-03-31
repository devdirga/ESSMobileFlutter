import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/datefilter.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/views/task/active_screen.dart';
import 'package:ess_mobile/views/task/history_screen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  dynamic _filterReq;

  int tabIndex = 0;

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

    Map<String, dynamic> getValue = {
      'Offset': 0
    };

    _filterReq = globals.getFilterRequest(params: getValue);
    
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        navBar: NavBar(
          title: Text(AppLocalizations.of(context).translate('Task')),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.app_registration),
                text: AppLocalizations.of(context).translate('Active'),
              ),
              Tab(
                icon: Icon(Icons.history),
                text: AppLocalizations.of(context).translate('History'),
              ),
            ],
            onTap: (index) {
              setState(() {
                tabIndex = index;
              });
            },
          ),
        ),
        main: TabBarView(
          children: [
            TaskActiveScreen(_filterReq),
            TaskHistoryScreen(_filterReq),
          ],
        ),
        drawer: AppDrawer(tokenUrl: globals.appAuth.data),
        actionButton: Visibility(
          child: AppActionButton(
            filter: () {
              AppDateFilter(context).show(yes: (val) {
                setState(() {
                  _filterReq = globals.getFilterRequest(params: val);
                });
              });
            },
          ),
          visible: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
