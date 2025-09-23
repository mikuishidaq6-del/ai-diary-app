🩺 Health Diary App
📌 概要

Health Diary App は、日々の健康状態を手軽に記録し、グラフやカレンダーで分かりやすく可視化できる Flutter アプリです。
体温・血圧・脈拍・体重などの基本データから、白血球数・赤血球数・血小板数といった血液データまで対応。
さらに AI アシスタントが投稿に対して 共感 → 安心 → 励まし の流れで優しくフィードバックを返してくれます。

医療系日記アプリを目指した「かわいく・やさしいデザイン」で、ポートフォリオとしても見せられる実装になっています。

✨ 主な機能

健康データの記録

体温 / 血圧 / 脈拍 / SpO₂ / 体重

白血球数 / 赤血球数 / 血小板数

コメントも自由に入力可能

入力バリデーション付き（例：体温 30–45℃）

タイムライン表示

過去の記録をカード型で表示

アイコン付きで見やすく、おしゃれなデザイン

編集・削除も簡単に操作可能

グラフ表示

fl_chart を用いた折れ線グラフ

項目ごとにタブ切り替え

期間フィルター（1か月 / 3か月 / 6か月 / 1年 / 全期間）

未入力値は前回値で補完してスムーズに描画

カレンダー表示

TableCalendar を利用

記録のある日は水色のマーカー表示

日付を選択するとその日の詳細が見れる

AIアシスタント

Firebase Functions 経由で OpenAI API を利用

「あなたは血液がん患者に寄り添う看護師です。共感→安心→励ましの流れで短く100文字以内で返答」というプロンプト

ユーザー投稿にやさしいコメントを返す

🛠 使用技術

フロントエンド: Flutter (Dart)

データベース: Hive（ローカル保存）

バックエンド: Firebase Functions

外部API: OpenAI API (Chat Completions)

パッケージ

fl_chart : グラフ描画

table_calendar : カレンダーUI

hive / hive_flutter : 軽量DB

firebase_core : Firebase連携

🚀 セットアップ方法

リポジトリをクローン

git clone https://github.com/yourname/health-diary-app.git
cd health-diary-app


パッケージをインストール

flutter pub get


Firebase セットアップ

firebase_options.dart を用意（Firebase CLIで生成）

Functions の環境変数に OpenAI API Key を設定

firebase functions:secrets:set OPENAI_API_KEY


実行

flutter run

📱 使い方

アプリを起動すると「タイムライン」が表示されます

右下の ＋ ボタン から新しい記録を追加できます

「📊 グラフ」ボタンで各項目の推移を確認できます

「📅 カレンダー」から日ごとの記録を確認できます

投稿ページから AI アシスタントにメッセージを送ると、優しい返信が届きます

🎨 デザインの工夫

全体を 水色ベース にして落ち着いたかわいらしい雰囲気に

アイコンを多用して 直感的にわかりやすいUI

タブやボタンは丸みを持たせ、柔らかい印象に

ユーザーが「毎日使いたくなるデザイン」を意識

💡 今後の展望

Google Fit / Apple HealthKit 連携

通知機能で入力忘れを防止

クラウド同期によるマルチデバイス対応

ダークモード対応

📖 ライセンス

MIT License