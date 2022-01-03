import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('EmployeeProfile')),
      ),
      main: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: _container(context),
      ),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }

  Widget _container(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: _gridItem.length,
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, _gridItem[index]['route']);
            },
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).buttonTheme.colorScheme?.primary,
                  ),
                  child: Icon(
                    _gridItem[index]['icon'],
                    size: 36.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Text(
                  _gridItem[index]['title'],
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<Map<String, dynamic>> _gridItem = [
    {
      'icon': Icons.library_books_sharp,
      'title': 'Resume',
      'route': Routes.resume,
    },
    {
      'icon': Icons.family_restroom,
      'title': 'Family',
      'route': Routes.family,
    },
    {
      'icon': Icons.assignment_ind_sharp,
      'title': 'Employment',
      'route': Routes.employment,
    },
    {
      'icon': Icons.brightness_auto,
      'title': 'Certificate',
      'route': Routes.certificate,
    },
    {
       'icon': Icons.warning,
       'title': 'Warning Letter',
       'route': Routes.warningLetter,
    },
    {
      'icon': Icons.medical_services_sharp,
      'title': 'Medical Record',
      'route': Routes.medicalRecord,
    },
    {
      'icon': Icons.auto_stories,
      'title': 'Document',
      'route': Routes.document,
    },
  ];
}
