import 'package:ess_mobile/views/attendance/listcheckinout_screen.dart';
import 'package:flutter/material.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/views/attendance/checkinout_screen.dart';

class AttendanceScreen extends StatelessWidget {

  dynamic _filterReq;
  int selectedPage;
  AttendanceScreen({required this.selectedPage});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: selectedPage,
        length: 2,
        child: AppScaffold(
            navBar: NavBar(
              title: Text(AppLocalizations.of(context).translate('Attendance')),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.poll),
                    text: AppLocalizations.of(context).translate('Absence'),
                  ), 
                  Tab(
                    icon: Icon(Icons.history),
                    text: AppLocalizations.of(context)
                        .translate('Absence History'),
                  )                  
                ],
              ),
            ),
            main: TabBarView(
              children: [
                ChechInOutScreen(_filterReq),
                LazyLoadingPage()
              ],
            ),
            drawer: AppDrawer(tokenUrl: globals.appAuth.data)
        )
    );
  }
}
