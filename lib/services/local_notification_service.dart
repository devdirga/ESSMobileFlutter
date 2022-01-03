import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ess_mobile/utils/routes.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context){
    final InitializationSettings _initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@drawable/ic_stat_logo")
    );

    _notificationPlugin.initialize(
      _initializationSettings, 
      onSelectNotification: (String? data) async {
        Navigator.pushNamed(context, Routes.notification);
      }
    );
  }

  static void display(RemoteMessage message) async{
    final id = DateTime.now().millisecondsSinceEpoch ~/1000;
    final NotificationDetails _notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        "ess_tps_channel",
        "ESS TPS Channel",
        channelDescription: "ESS TPS Channel for Firebase Messaging",
        importance: Importance.max,
        priority: Priority.high
      )
    );
    await _notificationPlugin.show(id, message.notification!.title, message.notification!.body, _notificationDetails);
  }
}