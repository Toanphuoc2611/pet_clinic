import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewVnpayScreen extends StatefulWidget {
  final String paymentUrl;
  final String invoiceCode;

  const WebviewVnpayScreen({
    Key? key,
    required this.paymentUrl,
    required this.invoiceCode,
  }) : super(key: key);

  @override
  State<WebviewVnpayScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<WebviewVnpayScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {},
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
                _checkPaymentResult(url);
              },
              onNavigationRequest: (NavigationRequest request) {
                _checkPaymentResult(request.url);
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentResult(String url) {
    if (url.contains('vnp_ResponseCode')) {
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];

      if (responseCode == '00') {
        _showPaymentResult(true, 'Thanh toán thành công!');
      } else {
        _showPaymentResult(false, 'Thanh toán thất bại!');
      }
    }
  }

  void _showPaymentResult(bool isSuccess, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSuccess ? 'Thành công' : 'Thất bại'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(isSuccess);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán VNPay'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _showCancelDialog();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải trang thanh toán...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hủy thanh toán'),
          content: Text('Bạn có chắc chắn muốn hủy thanh toán?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.pop(false); // Return false to indicate cancellation
              },
              child: Text('Có'),
            ),
          ],
        );
      },
    );
  }
}
