import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/providers/auth_provider.dart';

class Appbrowser extends StatefulWidget with WidgetsBindingObserver {
  
  @override
  _AppbrowserState createState() => _AppbrowserState();
}

class _AppbrowserState extends State<Appbrowser> {
  late Map<String, dynamic> _browserData;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Object? _args = ModalRoute.of(context)!.settings.arguments;

      if (_args != null) {
        setState(() {
          _browserData = _args as Map<String, dynamic>;
        });
      }

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
        title: Text(_browserData['name'].toString()),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: Builder(
          builder: (context) => _browserData['link'] != null
            ? Column(
                children: [
                  Expanded(
                    child: WebView(
                      initialUrl: _browserData['link'].toString(),
                      javascriptMode: JavascriptMode.unrestricted
                    )
                  )
                ]
              )
            : AppLoading()
        ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}