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
https://firebase.google.com/docs/flutter/setup?platform=ios


TBC:
1. SQFLite
2. Log File
4. Native Code
5. Authentication / ID Federation

Platform  Firebase App Id
android   1:691588793720:android:833973b7fc03d442bfb48d
ios       1:691588793720:ios:0b93e6399a75a01fbfb48d