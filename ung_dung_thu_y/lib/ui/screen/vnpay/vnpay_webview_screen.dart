import 'package:flutter/material.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class VnPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String invoiceCode;

  const VnPayWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.invoiceCode,
  }) : super(key: key);

  @override
  State<VnPayWebViewScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<VnPayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentProcessed = false;

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
              onWebResourceError: (WebResourceError error) {
                print('Web resource error: ${error.description}');
                setState(() {
                  _isLoading = false;
                });
              },
              onNavigationRequest: (NavigationRequest request) {
                print('Navigation request: ${request.url}');

                if (request.url.contains('vnp_ResponseCode')) {
                  _checkPaymentResult(request.url);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentResult(String url) {
    print('Checking URL: $url');

    // Check if the URL contains VNPay return parameters and payment hasn't been processed yet
    if (url.contains('vnp_ResponseCode') && !_paymentProcessed) {
      _paymentProcessed = true; // Prevent multiple processing

      setState(() {
        _isLoading = false; // Stop loading since we got the result
      });

      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      final transactionStatus = uri.queryParameters['vnp_TransactionStatus'];

      print('Response Code: $responseCode');

      if (responseCode == '00' && transactionStatus == '00') {
        _showPaymentResult(true, 'Thanh toán thành công!');
      } else {
        String errorMessage = 'Thanh toán thất bại!';
        if (responseCode == '24') {
          errorMessage = 'Giao dịch bị hủy bởi người dùng';
        } else if (responseCode == '51') {
          errorMessage = 'Tài khoản không đủ số dư';
        } else if (responseCode != null) {
          errorMessage = 'Thanh toán thất bại (Mã lỗi: $responseCode)';
        }
        _showPaymentResult(false, errorMessage);
      }
    }
  }

  void _showPaymentResult(bool isSuccess, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(isSuccess ? 'Thành công' : 'Thất bại'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (isSuccess) ...[
                SizedBox(height: 8),
                Text(
                  'Bạn sẽ được chuyển về trang chính.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(isSuccess);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        backgroundColor: TColor.primary,
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
                Navigator.of(context).pop();
              },
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(false);
              },
              child: Text('Có'),
            ),
          ],
        );
      },
    );
  }
}
