import 'package:ess_mobile/services/simulasi_pinjaman_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/actionbutton.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/error.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/loan_request_model.dart';

class SimLoanScreen extends StatefulWidget {
  @override
  _SimLoanScreenState createState() => _SimLoanScreenState();
}

class _SimLoanScreenState extends State<SimLoanScreen> {
  final SimulasiPinjamanService _simLoanService = SimulasiPinjamanService();

  Future<ApiResponse<dynamic>>? _simLoan;

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

    _simLoan = _simLoanService.getLoanRequest(globals.getFilterRequest());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('SimLoan')),
      ),
      main: Padding(
        padding: EdgeInsets.all(10.0),
        child: _container(context),
      ),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
      actionButton: AppActionButton(
        create: () {
          Navigator.pushNamed(
            context,
            Routes.requestLoan,
          ).then((val) {
            setState(() {
              _simLoan = _simLoanService.getLoanRequest(globals.getFilterRequest());
            });
          });
        },
        refresh: () {
          setState(() {
            _simLoan = _simLoanService.getLoanRequest(globals.getFilterRequest());
          });
        },
      ),
    );
  }

  Widget _container(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FutureBuilder<ApiResponse<dynamic>>(
        future: _simLoan,
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

                  var indexData = 0;
                  _response.data.reversed.forEach((v) {
                    var evenData = indexData.isEven ? true : false;
                    _children.add(_buildExpansionTile(context, v, _expanded, evenData));
                    _expanded = false;
                    indexData++;
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
                      _simLoan = _simLoanService.getLoanRequest(globals.getFilterRequest());
                    }),
                  );
                }
                break;
              case ApiStatus.ERROR:
                return AppError(
                  errorMessage: snapshot.data!.message,
                  onRetryPressed: () => setState(() {
                    _simLoan = _simLoanService.getLoanRequest(globals.getFilterRequest());
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
    LoanRequestModel items,
    bool expanded,
    bool evenData
  ) {

    DateTime _requestDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
        .parse(items.requestDate!, false)
        .toLocal();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: evenData ? [Colors.grey.shade100, Colors.grey.shade300] : [Colors.grey.shade300, Colors.grey],
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
                  'Simulation ID: '+ items.idSimulation!,
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Request Date: ' + DateFormat('dd/MM/yyyy').format(_requestDate),
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Loan Value: ' + globals.formatCurrency.format(items.loanValue),
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Length: ' + items.periodeLength!.toString() + ' months',
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Net Income: ' + globals.formatCurrency.format(items.netIncome),
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Installment: ' + globals.formatCurrency.format(items.installmentValue),
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
                SizedBox(height: 5),
                Text(
                  'Income After Installment: ' + globals.formatCurrency.format(items.incomeAfterInstallment),
                  style: Theme.of(context).primaryTextTheme.bodyText2
                ),
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
}
