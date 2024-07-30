https://github.com/DrTun/cct001

1) App Name
ios.Runner.Info.plist > CFBundleDisplayName

android.app.src.main.AndroidManifest.xml > android:label

flutter pub add -d change_app_package_name          
dart run change_app_package_name:main com.nirvasoft.cc001     

2) App Icon
ios.Runner.Assets.xcassets.AppIcon.appiconset
(Icon Set Creator >  replace AppIcon.appiconset folder)

android.app.src.main.AndroidManifest.xml > android:Icon : "@mipmap/ic_launcher"
anroid.app.src.main.res.mipmap-xxx
(replace ic_launcher.png)

3) Notification - Provider and Consumer

4) Arguments
pass with construtor
final args = ModalRoute.of(context)!.settings.arguments as ClassName 
Do not use restorable push 

5) Firebase
https://firebase.flutter.dev/docs/messaging/overview/
https://firebase.flutter.dev/docs/messaging/apple-integration/
https://firebase.google.com/docs/flutter/setup?platform=ios 

https://pub.dev/packages/firebase_analytics
https://firebase.google.com/docs/crashlytics/get-started?platform=flutter

flutter pub add firebase_core
flutter pub add firebase_analytics
flutter pub add firebase_crashlytics && flutter pub add firebase_analytics
flutter pub add firebase_messaging

- App > build.gradle - plugins 
  + more
- App > src > kotlin - main activities and package re-name if needed

flutterfire cli 
flutterfire configure

(if needed)
flutterfire configure \
  --project=??? \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=com.nirvasoft.???\
  --android-package-name=com.nirvasoft.???


6) Flavor
https://docs.flutter.dev/deployment/flavors
https://ahmedyusuf.medium.com/setup-flavors-in-ios-flutter-with-different-firebase-config-43c4c4823e6b
APN is needed for each iOS app under messaging

iOS
- Schemes 
- Runner Project - Configurations
- Runner Target - Product Bundle Identifier, Product Name, Primary App Icon
- Info Plist - Bundle Display Name 
- ios.Runner > Assets.xcassets > AppIcon sub folders dev/staging/sit/prd
- config - sub folders dev/staging/sit/prd Google Service Info.plist
- For Each iOS App ID in Firebase Messging Tab
- APN

Android
- App > build.gradle - Flavor Dimension, productFlavors
- srs > sub folders - res and google-servers.json

.vscode > luanch.json
    
flutter run  -t  lib/main_dev.dart --flavor dev --dart-define-from-file   

7) AppConfig
8) 
9)
Terminal
flutter clean 
flutter pub get
flutter pub outdated
flutter pub cache repair
flutter doctor

dart fix --apply (be careful. pls back up)

git clean -xfd                                                        
git stash save --keep-index
git stash drop
git pull

___________

Platform  Firebase App Id
android   1:691588793720:android:833973b7fc03d442bfb48d
ios       1:691588793720:ios:2ad564d21264ed02bfb48d

Name:FirebaseAPN
Key ID:6A9HF2BG9U
Services:Apple Push Notifications service (APNs)
Team ID: C88K3MQESJ


TBC
1) GPS / Map
2) socket
3) bubbles
- app icons
- tabs
- card



