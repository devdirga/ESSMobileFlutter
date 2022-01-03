import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:open_file/open_file.dart';
import 'package:ess_mobile/utils/localizations.dart';

class AppAlert {
  final BuildContext context;

  AppAlert(this.context);

  Future<void> save({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(title, 'Are you sure saving your data?', yes, cancel, true);
  }

  Future<void> saveDraft({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        title, 'Are you sure to save your data as draft?', yes, cancel, false);
  }

  Future<void> update({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(title, 'Are you sure updating your data?', yes, cancel, true);
  }

  Future<void> delete({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(title, 'Are you sure deleting your data?', yes, cancel, true);
  }

  Future<void> cancelRequest({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        title, 'Are you sure cancel your request?', yes, cancel, false);
  }

  Future<void> discard({
    String title = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        title, 'Are you sure discarding your data?', yes, cancel, false);
  }

  Future<void> approve({
    String title = '',
    String desc = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        'Are you sure want to approve?', '$title\n$desc', yes, cancel, false);
  }

  Future<void> cancel({
    String title = '',
    String desc = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        'Are you sure want to cancel?', '$title\n$desc', yes, cancel, true);
  }

  Future<void> reject({
    String title = '',
    String desc = '',
    Function? yes,
    Function? cancel,
  }) async {
    _reasonAlert(
        'Are you sure want to reject?', '$title\n$desc', yes, cancel, true);
  }

  Future<void> updateVersion() async {
    _defaultAlert('App Version', 'Your app version is outdated. Updating.', AlertType.info);
  }

  Future<void> noData({String title = ''}) async {
    _defaultAlert(title, 'No Data Available', AlertType.info);
  }

  Future<void> required({String title = ''}) async {
    _defaultAlert(title, 'Please enter all required fields.', AlertType.error);
  }

  Future<void> attachment({String title = ''}) async {
    _defaultAlert(title, 'Document attachment is required.', AlertType.error);
  }

  Future<void> multipleAttachment({String title = '', int file = 0}) async {
    _defaultAlert(
        title,
        'There are $file changed field(s) that has no attachment.',
        AlertType.warning);
  }

  Future<void> changePassword({
    Function? yes,
    Function? cancel,
  }) async {
    String currentPassword = '';
    String newPassword = '';

    Alert(
      context: context,
      type: AlertType.none,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationDuration: Duration(milliseconds: 400),
        titleStyle: Theme.of(context).textTheme.headline6!,
        descStyle: Theme.of(context).textTheme.subtitle1!,
      ),
      title: 'Change your password',
      desc: '',
      image: Image.asset('assets/images/reset-password.png', width: 90.0),
      content: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: 'Current Password',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            autofocus: true,
            onChanged: (text) {
              currentPassword = text.toString().trim();
            },
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'New Password',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (text) {
              newPassword = text.toString().trim();
            },
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('No'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.red,
          onPressed: () async {
            Navigator.pop(context);

            if (cancel != null) {
              cancel();
            }
          },
        ),
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('Save'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () async {
            if (currentPassword.trim() != '' && newPassword.trim() != '') {
              Navigator.pop(context);

              if (yes != null) {
                yes(currentPassword.trim(), newPassword.trim());
              }
            }
          },
        ),
      ],
    ).show();
  }

  _defaultAlert(
    String title,
    String desc,
    AlertType type,
  ) {
    Alert(
      context: context,
      type: type,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationDuration: Duration(milliseconds: 400),
        titleStyle: Theme.of(context).textTheme.headline6!,
        descStyle: Theme.of(context).textTheme.subtitle1!,
      ),
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('OK'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show();
  }

  _reasonAlert(
    String title,
    String desc,
    Function? yes,
    Function? cancel,
    bool reason,
  ) {
    String getValue = '';

    Alert(
      context: context,
      type: AlertType.none,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationDuration: Duration(milliseconds: 400),
        titleStyle: Theme.of(context).textTheme.headline6!,
        descStyle: Theme.of(context).textTheme.subtitle1!,
      ),
      title: title,
      desc: desc,
      image: Image.asset('assets/images/question.png', width: 90.0),
      content: (!reason)
          ? Container()
          : Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    'Please specify the reason of your request below',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Reason',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  autofocus: true,
                  onChanged: (text) {
                    getValue = text.toString().trim();
                  },
                ),
              ],
            ),
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('No'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.red,
          onPressed: () async {
            Navigator.pop(context);

            if (cancel != null) {
              cancel();
            }
          },
        ),
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('Yes'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () async {
            if (!reason) {
              Navigator.pop(context);

              if (yes != null) {
                yes();
              }
            } else {
              if (getValue != '') {
                Navigator.pop(context);

                if (yes != null) {
                  yes(getValue);
                }
              }
            }
          },
        ),
      ],
    ).show();
  }

  exportExcelAlert(
    String _filePath
  ) {
    Alert(
      context: context,
      type: AlertType.info,
      style: AlertStyle(
        isCloseButton: false,
        isOverlayTapDismiss: false,
        animationDuration: Duration(milliseconds: 400),
        titleStyle: Theme.of(context).textTheme.headline6!,
        descStyle: Theme.of(context).textTheme.subtitle1!,
      ),
      title: "Export to Excel",
      desc: "Data successfully exported to xls.",
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('Open'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
            OpenFile.open(_filePath);
          },
        ),
        DialogButton(
          child: Text(
            AppLocalizations.of(context).translate('Close'),
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: () => Navigator.pop(context),
        )
      ],
    ).show();
  }
}
