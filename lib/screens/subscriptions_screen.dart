import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/models/qb_filter.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/users/constants.dart';

class QBConfig {
  static final String appID = "84639";
  static final String authKey = "q8j4aNsXrUYOu84";
  static final String authSecret = "FpR6KwGY3WPbeFk";
  static final String accountKey = "-yzmdEdJ5RwBxYkDZda-";
  static String get apiEndpoint => null;
  static String get chatEndpoint => null;
}

class SubscriptionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SubscriptionScreenState();
}

class SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    setupQB();
  }

  setupQB() async {
    await QB.settings.init(
      QBConfig.appID,
      QBConfig.authKey,
      QBConfig.authSecret,
      QBConfig.accountKey,
      apiEndpoint: QBConfig.apiEndpoint,
      chatEndpoint: QBConfig.chatEndpoint,
    );
    await QB.settings.enableAutoReconnect(true);
    await QB.settings.initStreamManagement(10, autoReconnect: true);

    await QB.chat.subscribeEventConnections(QBChatEvents.CONNECTED, (event) {
      print(QBChatEvents.CONNECTED);
      print(event);
    });

    await QB.chat.subscribeEventConnections(QBChatEvents.CONNECTION_CLOSED,
        (event) {
      print(QBChatEvents.CONNECTION_CLOSED);
      print(event);
    });

    var result = await QB.auth.login('95943', 'AndPassword');
    await QB.chat.connect(result.qbUser.id, 'AndPassword');
  }

  @override
  dispose() async {
    super.dispose();
    await QB.chat.unsubscribeEventConnections(QBChatEvents.CONNECTED);
    await QB.chat.unsubscribeEventConnections(QBChatEvents.CONNECTION_CLOSED);

    if (await QB.chat.isConnected()) {
      await QB.chat.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("QB Test app"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text("QB Test App"),
              Spacer(),
              MaterialButton(
                onPressed: () {
                  _loadUser();
                },
                child: Text("Load QB User"),
              ),
              Container(
                height: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _loadUser() async {
    try {
      final user = await _getQBUser("121080689");
      print("User received $user");
    } on UserFetchException catch (e) {
      print(e.toString());
    }
  }

  Future<QBUser> _getQBUser(String qbUserId) async {
    try {
      QBFilter qbFilter = new QBFilter();

      qbFilter.field = QBUsersFilterFields.ID;
      qbFilter.operator = QBUsersFilterOperators.IN;
      //Can't pass array as type which should be good to get bunch of users with one request
      qbFilter.type = QBUsersFilterTypes.NUMBER;
      //value can only be a String but id is int, use dynamic maybe ?
      qbFilter.value = qbUserId;
      var users = await QB.users.getUsers(filter: qbFilter);
      if (users.length == 0) {
        throw UserFetchException("User with id $qbUserId not found");
      }
      if (users.length > 1) {
        throw UserFetchException(
            "To many users when fetching with id $qbUserId");
      }
      return users.first;
    } on PlatformException catch (e) {
      print(e.toString());
      throw UserFetchException("Platform internal exception");
    }
  }
}

class UserFetchException implements Exception {
  String _message;

  UserFetchException([String message = 'Invalid value']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
