import 'package:provider/provider.dart';
import 'src/maintabs/trip_details.dart';
import 'src/modules/flaxi/api_data_models/dashboard_models.dart';
import 'src/modules/flaxi/views/extra_list_view.dart';
import 'src/modules/flaxi/views/rate_scheme_view.dart';
import 'src/signin/models/auth_models.dart';
import 'src/providers/localization.dart';
import 'src/signin/openid/forgot_password_keycloak.dart';
import 'src/signin/type_a/forgot_password.dart';
import 'src/signin/type_a/signin.dart';
import 'src/signin/type_a/signup.dart';
import 'src/signin/type_b/user_singup.dart';
import 'src/signin/type_b/verify_otp.dart';
import 'src/signin/type_b/signin_otp.dart';
import 'src/signin/openid/sigin_social.dart';
import 'src/geolocation/map_view.dart';
import 'src/shared/app_config.dart';
import 'src/signin/openid/signin_keycloak.dart';
import 'src/signin/openid/signup_keycloak.dart';
import 'src/sqflite/trip_model.dart';
import 'src/views/view_dashboard_details.dart';
import 'src/views/view_dashboard_page.dart';
import 'src/views/view_driver_group_list.dart';
import 'src/views/view_logs.dart';
import 'src/views/view_profile.dart';
import 'src/views/view_transactions.dart';
import 'src/views/view_userinput_fromto.dart';
import 'src/views/views_form01.dart';
import 'src/views/view_data_details.dart';
import 'src/views/view_data_list.dart';
import 'src/views/view_sample_details.dart';
import 'src/views/view_sample_list.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_view.dart';
import 'src/loading_page.dart';
import 'src/root_page.dart';
import 'src/views/view_data.dart';
import 'src/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/xpass/view/view_xpass.dart';
import 'src/xpass/view/view_xpass_edit_register.dart';
import 'src/xpass/view/view_xpass_logs_details.dart';
import 'src/xpass/view/view_xpass_logs_list.dart';
import 'src/xpass/view/view_xpass_register.dart';

//  -------------------------------------    My App (Property of Nirvasoft.com)
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });
  final SettingsController settingsController;
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // navigatorObservers: [
          //   ChuckerFlutter.navigatorObserver,
          // ],
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(0.9)),
                child: child!);
          },
          restorationScopeId: 'app',
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('my', ''), // Myanmar
            Locale('th', ''),
            Locale('zh', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
                color: AppConfig.shared.primaryColor,
                centerTitle: true,
                titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: AppConfig.shared.primaryColor),
            tabBarTheme: TabBarTheme(
              labelColor: AppConfig.shared.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppConfig.shared.primaryColor,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings, // Route Settings
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case ViewTransactions.routeName:
                    return const ViewTransactions();
                  case ViewProfile.routeName:
                    return const ViewProfile();
                  case ViewDashboardDetails.routeName:
                    final dashBoardDetailsReq =
                        routeSettings.arguments as DriverDashBoardDetailsReq;
                    return ViewDashboardDetails(
                      dashBoardDetailsReq: dashBoardDetailsReq,
                    );
                  case ViewDashboard.routeName:
                    return const ViewDashboard();
                  case ViewLogs.routeName:
                    return const ViewLogs();
                  case ViewDriverGroupList.routeName:
                    return const ViewDriverGroupList();
                  case UserInputFromTo.routename:
                    return const UserInputFromTo();
                  case VerifyOtp.routename:
                    final otpresponse = routeSettings.arguments as OtpResponse;
                    return VerifyOtp(
                      otpResponse: otpresponse,
                    );
                  case UserSingup.routeName:
                    final userId = routeSettings.arguments as String;
                    return UserSingup(
                      userid: userId,
                    );
                  case SignInotp.routename:
                    return const SignInotp();
                  case Signup.routeName:
                    return const Signup();
                  case SignIn.routeName:
                    return const SignIn();
                  case SignInSocial.routeName:
                    return const SignInSocial();
                  case SignInKeycloak.routeName:
                    return const SignInKeycloak();
                  case SignupKeycloak.routeName:
                    return const SignupKeycloak();
                  case ForgotPassword.routeName:
                    return const ForgotPassword();
                  case ForgotPasswordKeycloak.routeName:
                    return const ForgotPasswordKeycloak();
                  case RootPage.routeName:
                    return RootPage(
                      settingsController: settingsController,
                    );
                  case SettingsView.routeName:
                    return const SettingsView();
                  case ViewDetails.routeName:
                    return const ViewDetails();
                  case View001.routeName:
                    return const View001();
                  case ViewList.routeName:
                    return const ViewList();
                  case ViewData.routeName:
                    return const ViewData();
                  case ViewSSForm01.routeName:
                    return const ViewSSForm01();
                  case ViewDataList.routeName:
                    return const ViewDataList();
                  case ViewDataDetails.routeName:
                    return const ViewDataDetails();
                  case MapView.routeName:
                    return const MapView();
                  case Tripdetails.routeName:
                    final trip = routeSettings.arguments as TripModel;
                    return Tripdetails(trip: trip);
                  case ExtraListView.routeName:
                    return const ExtraListView();
                  case RateSchemeView.routeName:
                    return const RateSchemeView();
                  case ViewXpass.routeName:
                    return const ViewXpass();
                  case ViewXpassLogsList.routeName:
                    return const ViewXpassLogsList();
                  case ViewXpassEditRegister.routeName:
                    return const ViewXpassEditRegister();
                  case ViewXpassRegister.routeName:
                    return const ViewXpassRegister();
                  case ViewXpassLogsDetails.routeName:
                    return const ViewXpassLogsDetails();
                  default:
                    return const LoadingPage();
                }
              },
            );
          },
        );
      },
    );
  }
}
