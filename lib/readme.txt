https://github.com/DrTun/cct001

1) App Name
ios.Runner.Info.plist > CFBundleDisplayName

android.app.src.main.AndroidManifest.xml > android:label

2) App Icon
ios.Runner.Assets.xcassets.AppIcon.appiconset
Contents.json
...png
(Icon Set Creator >  replace AppIcon.appiconset folder)

android.app.src.main.AndroidManifest.xml > android:Icon : "@mipmap/ic_launcher"
anroid.app.src.main.res.mipmap-xxx
(replace ic_launcher.png)

3)
flutter run --release   
Select iOS device

4) Arguments
pass with construtor
final args = ModalRoute.of(context)!.settings.arguments as ClassName 
Do not use restorable push 

5) Firebase
https://firebase.flutter.dev/docs/messaging/overview/
https://firebase.flutter.dev/docs/messaging/apple-integration/
https://firebase.google.com/docs/flutter/setup?platform=ios 

6) Flavor
https://docs.flutter.dev/deployment/flavors

iOS
- Schemes 
- Runner Project - Configurations
- Runner Target - Product Bundle Identifier, Product Name, Primary App Icon
- Info Plist - Bundle Display Name - $(PRODUCT_NAME)
- ios.Runner > Assets.xcassets > AppIcon

Android
- App > build.gradle - Flafor Dimension, productFlavors
- srs > sub folders - res and google-servers.json

.vscode > luanch.json
    
flutter run  -t  lib/main_dev.dart --flavor dev
flutter run  -t  lib/main_dev.dart --flavor staging  
flutter run  -t  lib/main.dart --flavor prd
 
flutter run  --release  lib/main_dev.dart --flavor dev
flutter run  --release  lib/main_dev.dart --flavor staging
flutter run  --release  lib/main.dart --flavor prd   


Platform  Firebase App Id
android   1:691588793720:android:833973b7fc03d442bfb48d
ios       1:691588793720:ios:2ad564d21264ed02bfb48d

Name:FirebaseAPN
Key ID:6A9HF2BG9U
Services:Apple Push Notifications service (APNs)
Team ID: C88K3MQESJ