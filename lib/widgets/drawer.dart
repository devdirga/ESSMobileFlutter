import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/widgets/logo.dart';

class AppDrawer extends StatelessWidget {
  final String? tokenUrl;

  AppDrawer({Key? key, this.tokenUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).canvasColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AppLogo(size: 80),
                  SizedBox(height: 10),
                  Text(
                    'ESS v' + globals.packageInfo.version,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text(AppLocalizations.of(context).translate('Dashboard')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.dashboard);
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                AppLocalizations.of(context).translate('Employee'),
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('Profile'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.profile);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('DocumentRequest'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, Routes.documentRequest);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.payments_sharp),
              title: Text(
                AppLocalizations.of(context).translate('Payroll'),
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('Payslip'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.payslip);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('SimLoan'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.simLoan);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.timer),
              title: Text(
                AppLocalizations.of(context).translate('TimeManagement'),
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('MyAttendance'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, Routes.timeAttendance);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context)
                        .translate('SubordinateAttendance'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, Routes.subordinateAttendance);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.event_available),
              title: Text(
                AppLocalizations.of(context).translate('Agenda'),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.agenda);
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text(AppLocalizations.of(context).translate('Leave')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.leave);
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.folder_shared),
              title: Text(
                AppLocalizations.of(context).translate('ComplaintRequest'),
              ),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('Ticket'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.complaints);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context).translate('Resolution'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.resolutions);
                  },
                ),
                /*ListTile(
                  leading: Icon(Icons.arrow_right),
                  title: Text(
                    AppLocalizations.of(context)
                        .translate('TicketCategory'),
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, Routes.ticketCategories);
                  },
                ),*/
              ],
            ),
            ListTile(
              leading: Icon(Icons.poll),
              title: Text(AppLocalizations.of(context).translate('Survey')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.survey);
              },
            ),
            ListTile(
              leading: Icon(Icons.app_settings_alt),
              title: Text(AppLocalizations.of(context).translate('Attendance')),
              // onTap: () async {
              //   String _link = await createDynamicLink();
              //   await launch(_link);
              // },
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.attendance);
              },
            ),
            /*ListTile(
              leading: Icon(Icons.shop),
              title: Text(AppLocalizations.of(context).translate('Travel')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.travel);
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text(AppLocalizations.of(context).translate('Training')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.training);
              },
            )
            ListTile(
              leading: Icon(Icons.airline_seat_flat),
              title:
                  Text(AppLocalizations.of(context).translate('SleepMonitor')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.sleepMonitor);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat_sharp),
              title: Text(
                  AppLocalizations.of(context).translate('InteractiveChat')),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.chatContact);
              },
            ), */
          ],
        ),
      ),
    );
  }

  Future<String> createDynamicLink() async {
    var parameters = DynamicLinkParameters(
      uriPrefix: 'https://esstps.page.link',
      link: Uri.parse('https://esstps.page.link.com/kara?token=' + tokenUrl!),
      androidParameters: AndroidParameters(
        packageName: "com.kara",
      ),
      iosParameters: IosParameters(
        bundleId: "com.exmple.test",
        appStoreId: '1498909115',
      ),
    );
    var shortLink = await parameters.buildShortLink();
    var shortUrl = shortLink.shortUrl;

    return shortUrl.toString();
  }
}
