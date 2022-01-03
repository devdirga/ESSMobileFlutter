import 'package:ess_mobile/views/attendance/listcheckinout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/views/attendance/checkinout_screen.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
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
              title: Text(AppLocalizations.of(context).translate('Attendance')),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.history),
                    text: AppLocalizations.of(context)
                        .translate('Absence History'),
                  ),
                  Tab(
                    icon: Icon(Icons.poll),
                    text: AppLocalizations.of(context).translate('Absence'),
                  ), 
                ],
              ),
            ),
            main: TabBarView(
              children: [
                LazyLoadingPage(),
                ChechInOutScreen(_filterReq)
                
              ],
            ),
            drawer: AppDrawer(tokenUrl: globals.appAuth.data)));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
