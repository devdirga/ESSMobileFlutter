import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/widgets/snackbar.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/providers/theme_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/chat_service.dart';
import 'package:ess_mobile/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final _author = types.User(
    id: globals.chatAuthor.id.toString(),
    firstName: globals.chatAuthor.firstName.toString(),
  );

  AuthorModel? _contact;
  List<types.Message> _messages = [];
  int _take = 25;
  int _skip = 0;
  int _total = 0;

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.values.length > 0) {
        if (message.data.containsKey('module') &&
            message.data.containsKey('value')) {
          final String module = message.data['module'];
          final MessageModel msg =
              MessageModel.fromJson(json.decode(message.data['value']));

          if (module == 'chat') {
            final updatedMessage = types.Message.fromJson(msg.toJson());

            if (msg.receiver.toString() == globals.chatAuthor.id.toString()) {
              if (this.mounted) {
                setState(() {
                  _messages.insert(0, updatedMessage);
                });
              }
            }
          }
        }
      }
    });

    Future.delayed(Duration.zero, () async {
      if (_author.id.toString() != 'null') {
        setState(() {
          _arguments().then((contact) async {
            if (contact != null) {
              _contact = contact;
              _loadMessages(_author.id, _contact!.id.toString());
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_contact != null)
        ? AppScaffold(
            navBar: NavBar(
              title: Row(
                children: <Widget>[
                  (_contact?.imageUrl != '')
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(_contact!.imageUrl!),
                          backgroundColor: Colors.transparent,
                        )
                      : CircleAvatar(
                          radius: 20,
                          child: Text(
                            _contact!.firstName
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.7),
                        ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_contact!.firstName.toString()),
                          SizedBox(height: 2),
                          Text(
                            _contact!.email.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              toolbarHeight: 70,
            ),
            main: Padding(
              padding: EdgeInsets.all(0.0),
              child: _container(context),
            ),
          )
        : AppScaffold(
            navBar: NavBar(
              title: Text(
                AppLocalizations.of(context).translate('InteractiveChat'),
              ),
            ),
            main: AppLoading(
              loadingMessage:
                  'Cloud messaging subscription error and push notification wont send.',
            ),
          );
  }

  Widget _container(BuildContext context) {
    return Chat(
      messages: _messages,
      user: _author,
      onAttachmentPressed: _handleAtachmentPressed,
      onMessageTap: _handleMessageTap,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onSendPressed: _handleSendPressed,
      onEndReached: _handleEndReached,
      theme: DefaultChatTheme(
        primaryColor: (context.read<ThemeProvider>().isDarkModeOn)
            ? Colors.teal.withOpacity(0.3)
            : Colors.lightGreen,
        secondaryColor:
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
        sentMessageBodyTextStyle: TextStyle(color: Colors.white),
        receivedMessageBodyTextStyle: TextStyle(
          color: Theme.of(context)
              .buttonTheme
              .colorScheme!
              .onSurface
              .withOpacity(0.8),
        ),
        backgroundColor: Colors.transparent,
        inputTextColor: Theme.of(context)
            .buttonTheme
            .colorScheme!
            .onSurface
            .withOpacity(0.8),
        inputBackgroundColor: (context.read<ThemeProvider>().isDarkModeOn)
            ? Colors.black.withOpacity(0.3)
            : Colors.blueGrey.withOpacity(0.1),
        messageInsetsHorizontal: 16,
        messageInsetsVertical: 12,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.teal.shade50,
                    ),
                    height: 50,
                    width: 50,
                    child: Icon(
                      Icons.image,
                      size: 20,
                      color: Colors.teal.shade400,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.blue.shade50,
                    ),
                    height: 50,
                    width: 50,
                    child: Icon(
                      Icons.attach_file,
                      size: 20,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.red.shade50,
                    ),
                    height: 50,
                    width: 50,
                    child: Icon(
                      Icons.cancel,
                      size: 20,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withReadStream: true,
    );

    if (result != null) {
      ApiResponse<dynamic> upload =
          await _chatService.uploadFile(result.files.single);

      String fileName = '', filePath = '';

      if (upload.status == ApiStatus.COMPLETED) {
        if (upload.data['statusCode'] == 200) {
          if (upload.data['data'] != null) {
            fileName = upload.data['data']['name'];
            filePath = upload.data['data']['path'];
          }
        }

        if (upload.data['statusCode'] == 400) {
          AppSnackBar.danger(context, upload.data['message'].toString());
          return;
        }
      }

      if (upload.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, upload.message);
        return;
      }

      final message = types.FileMessage(
        author: _author,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: (fileName != '') ? fileName : result.files.single.name,
        uri: (filePath != '') ? filePath : result.files.single.path!,
        size: result.files.single.size,
        status: types.Status.sending,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      ApiResponse<dynamic> upload = await _chatService.uploadImage({
        'file': base64Encode(bytes),
        'fileName': result.name,
      });

      String fileName = '', filePath = '';

      if (upload.status == ApiStatus.COMPLETED) {
        if (upload.data.statusCode == 200) {
          if (upload.data.data != null) {
            fileName = upload.data.data['name'];
            filePath = upload.data.data['path'];
          }
        }

        if (upload.data.statusCode == 400) {
          AppSnackBar.danger(context, upload.data.message.toString());
          return;
        }
      }

      if (upload.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, upload.message);
        return;
      }

      final message = types.ImageMessage(
        author: _author,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: Uuid().v4(),
        name: (fileName != '') ? fileName : result.name,
        uri: (filePath != '') ? filePath : result.path,
        size: bytes.length,
        width: image.width.toDouble(),
        status: types.Status.sending,
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      if (await canLaunch(message.uri)) {
        await launch(
          message.uri,
          forceSafariVC: false,
          forceWebView: false,
        );
      } else {
        await OpenFile.open(message.uri);
      }
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
      status: types.Status.sending,
    );

    _addMessage(textMessage);
  }

  Future<void> _handleEndReached() async {
    if (_total > _skip) {
      _skip += _take;
      _loadMessages(_author.id, _contact!.id.toString());
    }
  }

  void _addMessage(types.Message message) async {
    setState(() {
      _messages.insert(0, message);
    });

    Map<String, dynamic> msg = message.toJson();
    msg['channel'] = '';
    msg['sender'] = _author.id;
    msg['receiver'] = _contact!.id;
    msg['status'] = 'sent';

    Map<String, dynamic>.from(msg).forEach((k, v) {
      if (v == null) {
        msg.remove(k);
      }
    });

    Map<String, dynamic>.from(msg['author']).forEach((k, v) {
      if (v == null) {
        msg['author'].remove(k);
      }
    });

    ApiResponse<dynamic> result = await _chatService.messageSend(msg);

    if (result.status == ApiStatus.ERROR) {
      AppSnackBar.danger(context, result.message);
    }

    if (result.status == ApiStatus.COMPLETED) {
      Map<String, dynamic> body = {
        'notification': {'body': '${_author.firstName} has sent you a message'},
        'data': {'module': 'chat', 'value': msg},
        'to': _contact!.token,
        'priority': 'high',
        'direct_boot_ok': true,
      };

      ApiResponse<dynamic> notify = await _chatService.notifySend(body);

      if (notify.status == ApiStatus.ERROR) {
        AppSnackBar.danger(context, notify.message);
      }

      if (notify.status == ApiStatus.COMPLETED) {
        final updatedMessage = types.Message.fromJson(msg);

        if (this.mounted) {
          setState(() {
            _messages[0] = updatedMessage;
          });
        }
      }
    }
  }

  void _loadMessages(String sender, String receiver) async {
    Map<String, dynamic> body = {
      'sender': sender,
      'receiver': receiver,
      'skip': _skip,
      'take': _take
    };

    _chatService.message(body).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          v.data.data.sort((b, a) {
            return a.createdAt.toString().compareTo(b.createdAt.toString());
          });

          final messages = (v.data.data as List)
              .map((e) => types.Message.fromJson(e.toJson()))
              .toList();

          setState(() {
            if (_skip == 0) {
              _messages = messages;
            } else {
              _messages.addAll(messages);
            }

            _total = v.data.total;
          });
        }
      }
    });
  }

  Future<AuthorModel?> _arguments() async {
    Object? _args = ModalRoute.of(context)!.settings.arguments;

    if (_args != null) {
      Map<String, dynamic> _val = _args as Map<String, dynamic>;
      return AuthorModel.fromJson(_val);
    }

    return null;
  }
}
