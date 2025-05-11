import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Data Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _fcmToken = "取得中...";
  Map<String, dynamic> _receivedData = {};
  String _lastMessageSource = "";

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token ?? "トークン取得失敗";
    });
    print("FCM Token: $_fcmToken");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.data.isNotEmpty) {
        setState(() {
          _receivedData = message.data;
          _lastMessageSource = "フォアグラウンド受信";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('フォアグラウンドでデータ受信: ${message.data['my_custom_key_1'] ?? 'データなし'}')),
        );
      }

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');
      if (message.data.isNotEmpty) {
        setState(() {
          _receivedData = message.data;
          _lastMessageSource = "バックグラウンドから復帰 (通知タップ)";
        });
      }
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('Terminated app opened via notification');
      print('Message data: ${initialMessage.data}');
      if (initialMessage.data.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          setState(() {
            _receivedData = initialMessage.data;
            _lastMessageSource = "終了状態から起動 (通知タップ)";
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? customKey1Value = _receivedData['my_custom_key_1']?.toString();
    final String? updateAvailableValue = _receivedData['update_available']?.toString();
    final String? itemIdValue = _receivedData['item_id']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FCMデータ表示デモ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'FCM登録トークン:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(_fcmToken),
            const SizedBox(height: 20),
            Text(
              '最後に受信したメッセージのソース: $_lastMessageSource',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              '受信したデータ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_receivedData.isEmpty)
              const Text('まだデータを受信していません。')
            else ...[
              if (customKey1Value != null)
                ListTile(title: const Text('my_custom_key_1:'), subtitle: Text(customKey1Value)),
              if (updateAvailableValue != null)
                ListTile(title: const Text('update_available:'), subtitle: Text(updateAvailableValue)),
              if (itemIdValue != null)
                ListTile(title: const Text('item_id:'), subtitle: Text(itemIdValue)),
              const Divider(),
              const Text('全データ (JSON風):'),
              Text(_receivedData.toString()),
            ]
          ],
        ),
      ),
    );
  }
}
