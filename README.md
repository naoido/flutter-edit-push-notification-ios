## プッシュ通知をクライアントで前処理する
### 前提
プッシュ通知をFirebaseCloudMessagingから送信する。
iOSのみの実装
### ディレクトリ構成
```
.
├── Makefile # firebaseの初期化のためにおいてる
├── README.md
├── firebase.json # firebaseのクライアント側の情報
├── go.mod # goの依存関係
├── ios
│   ├── PushNotificationService # ここが重要
│   │   ├── Info.plist
│   │   └── NotificationService.swift # プッシュ通知の前処理
│   ├── Runner
├── lib
│   ├── firebase_options.dart # make initすると自動生成される
│   └── main.dart # 雑に情報出すだけのフロント画面
├── main.go # プッシュ通知を送信するためのスクリプト
├── serviceAccountKey.json # ignoreされてる管理側Firebase情報
└── test_push_notification.iml 
```
### 既存のプロジェクトに編集ロジックを追加する場合
1. Xcodeで`File > New > Target...`をクリック
2. `Notification Service Extention`を選択し、`Next`
3. `Product Name(任意の値)`を入力し、`Finish`
4. `Runner > Build Phases`で`Embed Foundation Extensions`を`Run Script`の前に移動させる
    - これしないとエラー出ます。
5. 生成された`NotificationService.swift`をお好みに編集
6. Flutterで実行し、プッシュ通知を送信(go run main.go)して動作を確認する
