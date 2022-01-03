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
import 'package:ess_mobile/views/training/registration_screen.dart';
import 'package:ess_mobile/views/training/history_screen.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  dynamic _filterReq;

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

    _filterReq = globals.getFilterRequest();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        navBar: NavBar(
          title: Text(AppLocalizations.of(context).translate('Training')),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.app_registration),
                text:
                    AppLocalizations.of(context).translate('OpenRegistration'),
              ),
              Tab(
                icon: Icon(Icons.history),
                text: AppLocalizations.of(context).translate('History'),
              ),
            ],
          ),
        ),
        main: TabBarView(
          children: [
            RegistrationScreen(_filterReq),
            HistoryScreen(_filterReq),
          ],
        ),
        drawer: AppDrawer(tokenUrl: globals.appAuth.data),
        actionButton: AppActionButton(
          filter: () {
            AppDateFilter(context).show(yes: (val) {
              setState(() {
                _filterReq = globals.getFilterRequest(params: val);
              });
            });
          },
          refresh: () {
            setState(() {
              _filterReq = globals.getFilterRequest();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
