import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;
  const WebViewPage({super.key, required this.url, this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _loading = true;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController (required for webview_flutter 4.x+)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            // Only allow http/https URLs
            if (request.url.startsWith('http')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'WebView'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Center(
                child: SizedBox(
                  width: TSizes.v18,
                  height: TSizes.v18,
                  child: CircularProgressIndicator(strokeWidth: TSizes.v2),
                ),
              ),
            )
        ],
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
