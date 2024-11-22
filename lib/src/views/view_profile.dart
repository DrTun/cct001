import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/api/api_data_service_flaxi.dart';
import '../modules/flaxi/api_data_models/driver_register_models.dart';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';
import '../providers/mynotifier.dart';
import '../root_page.dart';
import '../shared/app_config.dart';
import '../shared/global_data.dart';

class ViewProfile extends StatefulWidget {
  static const routeName = '/profile';
  const ViewProfile({super.key});
  static String baseURLDEV = AppConfig.shared.baseURLDEV;

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  late List<dynamic>? driverInfos = [];
  String userId = GlobalAccess.userID;
  File? _profileImage;
  String updatename =
      MyStore.prefs.getString('username') ?? GlobalAccess.userID;
  bool isLoading = false;

  DriverProfile req = DriverProfile(
      syskey: MyStore.prefs.getString('userid') ?? GlobalAccess.driverID,
      // MyStore.prefs.getString('userid'),
      name: MyStore.prefs.getString('username') ?? '',
      vehicleno: MyStore.prefs.getString('vehicleno') ?? 'Unknown Number',
      vehicle: MyStore.prefs.getString('vehicle') ?? 'Unknown Vehicle');
  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadProfileData();
  }

  Future<void> fetchProfileData() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiDataServiceFlaxi().driverProfile(req);

      if (response['status'] == 200) {
        // Update SharedPreferences with new data
        await MyStore.prefs.setString('username', req.name);
        await MyStore.prefs.setString('userid', req.syskey);
        await MyStore.prefs.setString('vehicleno', req.vehicleno);
        await MyStore.prefs.setString('vehicle', req.vehicle);

        await loadProfileData();

        logger.i('Profile updated successfully.');
      } else {
        logger.i('Failed to fetch profile data: ${response.statusCode}');
      }
    } catch (e) {
      logger.i('Error fetching profile data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadProfileData() async {
    setState(() => isLoading = true);
    String? image = await MyStore.prefs.getString('profileImage');
    if (image != null) {
      setState(() {
        _profileImage = File(image);
      });
    }
    // Fetch user profile details from SharedPreferences
    final syskey = MyStore.prefs.getString('userid') ?? GlobalAccess.driverID;

    final name = MyStore.prefs.getString('username') ?? '';
    final vehicle = MyStore.prefs.getString('vehicle') ?? '';
    final vehicleno = MyStore.prefs.getString('vehicleno') ?? '';

    setState(() {
      DriverProfile req = DriverProfile(
          syskey: syskey, name: name, vehicleno: vehicleno, vehicle: vehicle);
      req.syskey = syskey;
      req.name = name;
      req.vehicle = vehicle;
      req.vehicleno = vehicleno;
      isLoading = false;
    });
  }

  Future<void> requestPermissions() async {
    // Request permissions

    final status = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    if (status[Permission.camera]!.isDenied ||
        status[Permission.storage]!.isDenied) {
    } else {}
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    final myNotifier = Provider.of<MyNotifier>(context, listen: false);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    try {
      if (pickedFile != null) {
        final croppedFile = await ImageCropper()
            .cropImage(sourcePath: pickedFile.path, uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.blue,
            initAspectRatio: CropAspectRatioPreset.original,
            activeControlsWidgetColor: Colors.blue,
            cropFrameColor: Colors.blue,
            cropStyle: CropStyle.rectangle,
            showCropGrid: true,
            lockAspectRatio: false,
          )
        ]);
        if (croppedFile != null) {
          myNotifier.updateImage(File(croppedFile.path));

          setState(() {
            _profileImage = File(croppedFile.path);
            MyStore.prefs.setString('profileImage', croppedFile.path);
          });
        } else {
          myNotifier.updateImage(File(pickedFile.path));

          await MyStore.prefs.setString('profileImage', pickedFile.path);
          setState(() {
            _profileImage = File(pickedFile.path);
            MyStore.prefs.setString('profileImage', pickedFile.path);
          });
        }
      }
    } catch (e) {
      LogService.writeLog(LogModel(
          errorMessage: e.toString(),
          stackTrace: 'PickImage (View Transaction)',
          timestamp: DateTime.now().toString()));
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(children: [
        ListTile(
          leading: const Icon(Icons.camera_alt, color: Colors.blueGrey),
          title: const Text('Camera'),
          onTap: () {
            Navigator.pop(context);
            pickImage(ImageSource.camera, context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_album, color: Colors.blueGrey),
          title: const Text('Gallery'),
          onTap: () {
            Navigator.pop(context);
            pickImage(ImageSource.gallery, context);
          },
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<MyNotifier>(
        builder: (BuildContext context, MyNotifier value, Widget? child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12.0),
              const Text('Profile'),
              const SizedBox(height: 2.0),
              Text(
                AppConfig.shared.appVersion,
                style: const TextStyle(fontSize: 9.0, color: Colors.yellow),
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25.0, bottom: 10, top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.05),
                      Align(
                        alignment: Alignment.topCenter,
                        child: InkWell(
                          onTap: () => _showImageOptions(context),
                          borderRadius: BorderRadius.circular(100),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: value.profileImage != null
                                    ? FileImage(value.profileImage!)
                                    : _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                child: _profileImage == null &&
                                        value.profileImage == null
                                    ? Text(
                                        updatename.isNotEmpty
                                            ? updatename[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 24),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 5,
                                right: 1,
                                child: Container(
                                  height: width * 0.06,
                                  width: width * 0.07,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface
                                        .withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface
                                        .withOpacity(0.9),
                                    size: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        updatename,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        initialValue: req.name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) async {
                          setState(() => req.name = newValue);
                          await MyStore.prefs.setString('username', newValue);
                        },
                        onFieldSubmitted: (newValue) async {
                          setState(() => req.name = newValue);
                          await MyStore.prefs.setString('username', newValue);
                        },
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        initialValue: req.vehicleno, // Display current name
                        decoration: const InputDecoration(
                          labelText: 'Vehicle No',
                          hintText: 'Enter your vehicle no',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) async {
                          setState(() {
                            req.vehicleno =
                                newValue; // Update the name in the request object
                          });
                          await MyStore.prefs.setString('vehicleno', newValue);
                        },
                        onFieldSubmitted: (newValue) async {
                          setState(() {
                            req.vehicleno = newValue; // Finalize name on submit
                          });
                          await MyStore.prefs.setString(
                              'vehicleno', newValue); // Persist name locally
                        },
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        initialValue: req.vehicle, // Display current name
                        decoration: const InputDecoration(
                          labelText: 'vehicle',
                          hintText: 'Enter your vehicle',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (newValue) async {
                          setState(() {
                            req.vehicle =
                                newValue; // Update the name in the request object
                          });
                          await MyStore.prefs.setString('vehicle', newValue);
                        },
                        onFieldSubmitted: (newValue) async {
                          setState(() {
                            req.vehicle = newValue; // Finalize name on submit
                          });
                          await MyStore.prefs.setString(
                              'vehicle', newValue); // Persist name locally
                        },
                      ),
                      SizedBox(height: height * 0.03),
                      Center(
                          child: CircleAvatar(
                        radius: 35,
                        child: IconButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                                GlobalAccess.updateUnameToken(req.name);
                              });

                              await fetchProfileData();
                              Navigator.pushNamedAndRemoveUntil(context,
                                  RootPage.routeName, ModalRoute.withName('/'));
                              MyHelpers.msg(
                                message: "Profile updated successfully!! ",
                              );
                            },
                            icon: const Center(
                              child: Icon(
                                Icons.done_sharp,
                                size: 45,
                              ),
                            )),
                      ))
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
