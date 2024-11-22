import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/src/shared/app_config.dart';
import '/src/widgets/connection_require_dialog.dart';

class WebviewSocial extends StatefulWidget {
  final Uri authorizationUrl;

  const WebviewSocial({super.key, required this.authorizationUrl});

  @override
  State<WebviewSocial> createState() => _WebviewSocialState();
}

class _WebviewSocialState extends State<WebviewSocial> {
  late WebViewController _webViewController;
  bool _isLoading = false;
  static String redirectURL = AppConfig.shared.openIDBaseURL;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("random")
      ..clearCache()
      ..clearLocalStorage()
      ..setNavigationDelegate(_createNavigationDelegate())
      ..loadRequest(widget.authorizationUrl);
  }

  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) {
        setState(() => _isLoading = false);
        if (request.url.startsWith(redirectURL)) {
          Navigator.pop(context, Uri.parse(request.url));
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        setState(() => _isLoading = true);
        if (url.contains("rejected")) {
          Navigator.pop(context);
          connectionRequireDialog(context);
        }
      },
      onPageFinished: (String url) {
        setState(() => _isLoading = false);
      },
      onWebResourceError: (WebResourceError error) {
        setState(() => _isLoading = false);
        if (error.errorType != WebResourceErrorType.unknown &&
            error.errorType.toString() != 'null') {
          Navigator.pop(context);
          connectionRequireDialog(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'),),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
