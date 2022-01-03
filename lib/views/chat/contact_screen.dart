import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ess_mobile/widgets/scaffold.dart';
import 'package:ess_mobile/widgets/drawer.dart';
import 'package:ess_mobile/widgets/loading.dart';
import 'package:ess_mobile/providers/auth_provider.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/localizations.dart';
import 'package:ess_mobile/utils/routes.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/services/chat_service.dart';
import 'package:ess_mobile/models/chat_model.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ChatService _chatService = ChatService();

  TextEditingController _searchController = TextEditingController(text: '');
  Map<String, dynamic> _unread = {};
  List<AuthorModel> _contacts = <AuthorModel>[];
  List<AuthorModel> _contactList = <AuthorModel>[];

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

    _chatService.messageUnread({
      'sender': globals.appAuth.user?.id,
      'receiver': globals.appAuth.user?.id,
    }).then((v) {
      if (v.status == ApiStatus.COMPLETED) {
        if (v.data.data.length > 0) {
          v.data.data.forEach((i) {
            _unread[i['author']] = i['sent'];
          });
        }

        _chatService.author({'search': '', 'skip': 0, 'take': 1000}).then((v) {
          if (v.status == ApiStatus.COMPLETED) {
            if (v.data.data.length > 0) {
              _contacts = [];

              v.data.data.forEach((i) {
                if (i.id != globals.appAuth.user?.id) {
                  _contacts.add(i);
                }
              });

              setState(() {
                _contactList.addAll(_contacts);
              });
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      navBar: NavBar(
        title: Text(AppLocalizations.of(context).translate('InteractiveChat')),
      ),
      main: _container(context),
      drawer: AppDrawer(tokenUrl: globals.appAuth.data),
    );
  }

  Widget _container(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
                size: 20,
              ),
              filled: true,
              fillColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
              contentPadding: EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: (_contactList.length > 0)
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _contactList.length,
                  itemBuilder: (context, index) {
                    return _contactChat(_contactList[index]);
                  },
                )
              : AppLoading(),
        ),
      ],
    );
  }

  Widget _contactChat(AuthorModel contact) {
    contact.imageUrl ??= '';

    DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(contact.updatedAt!);

    if (contact.lastSeen == 0) {
      lastSeen = DateTime.fromMillisecondsSinceEpoch(contact.updatedAt!);
    }

    return GestureDetector(
      onTap: () {
        _chatService.messageRead({
          'sender': globals.appAuth.user?.id,
          'receiver': contact.id.toString(),
        }).then((v) {
          if (v.status == ApiStatus.COMPLETED) {
            Navigator.pushNamed(
              context,
              Routes.chat,
              arguments: contact.toJson(),
            );
          }
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  (contact.imageUrl != '')
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(contact.imageUrl!),
                          backgroundColor: Colors.transparent,
                        )
                      : CircleAvatar(
                          radius: 20,
                          child: Text(
                            contact.firstName
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(contact.firstName.toString()),
                          SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy HH:mm').format(lastSeen),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (_unread.containsKey(contact.id.toString()))
                ? CircleAvatar(
                    child: Text(
                      _unread[contact.id.toString()].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.lightGreen,
                    maxRadius: 11,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<AuthorModel> _searchList = <AuthorModel>[];

      _contacts.forEach((item) {
        String name = item.firstName.toString();
        if (name.toLowerCase().contains(query.toLowerCase())) {
          _searchList.add(item);
        }
      });

      setState(() {
        _contactList.clear();
        _contactList.addAll(_searchList);
      });
    } else {
      setState(() {
        _contactList.clear();
        _contactList.addAll(_contacts);
      });
    }
    return;
  }
}
