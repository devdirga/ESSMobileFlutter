import 'package:flutter/material.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;

class RecruitmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('Recruitment')),
      ),
      main: Text(
        AppLocalizations.of(context).translate('Recruitment'),
      ),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }
}
