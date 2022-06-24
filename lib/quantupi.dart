import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Quantupi {
  static const MethodChannel _channel = MethodChannel('quantupi');

  final String receiverUpiId;
  final String receiverName;
  final String transactionNote;
  final double amount;
  final String? transactionRefId;
  final String? currency;
  final String? url;
  final String? merchantId;
  final QuantUPIPaymentApps? appname;

  Quantupi({
    required this.receiverUpiId,
    required this.receiverName,
    required this.transactionNote,
    required this.amount,
    this.transactionRefId,
    this.currency = "INR",
    this.url,
    this.merchantId,
    this.appname,
  })  : assert(receiverUpiId.contains(RegExp(r'\w+@\w+'))),
        assert(amount >= 0 && amount.isFinite),
        assert(currency == "INR"), // For now
        assert((merchantId != null && transactionRefId != null) ||
            merchantId == null);

  Future<String> startTransaction() async {
    try {
      if (Platform.isAndroid) {
        final String response =
            await _channel.invokeMethod('startTransaction', {
          'receiverUpiId': receiverUpiId,
          'receiverName': receiverName,
          'transactionRefId': transactionRefId,
          'transactionNote': transactionNote,
          'amount': amount.toString(),
          'currency': currency,
          'merchantId': merchantId,
        });
        return response;
      } else if (Platform.isIOS) {
        final result = await _channel.invokeMethod(
          'launch',
          {
            'uri': transactiondetailstostring(
              payeeAddress: receiverUpiId,
              payeeName: receiverName,
              transactionNote: transactionNote,
              transactionRef: transactionRefId,
              amount: amount,
              currency: currency,
              merchantId: merchantId,
              appname: appname,
            ),
          },
        );
        return result == true
            ? "Successfully Launched App!"
            : "Something went wrong!";
      } else {
        throw PlatformException(
          code: 'ERROR',
          message: 'Platform not supported!',
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }
}

String transactiondetailstostring({
  QuantUPIPaymentApps? appname,
  required String payeeAddress,
  required String payeeName,
  String? transactionRef,
  String? transactionNote,
  required double amount,
  String? currency = 'INR',
  String? merchantId,
}) {
  String prefixuri = 'upi://pay';
  if (appname != null) {
    if (appname == QuantUPIPaymentApps.amazonpay) {
      prefixuri = 'amazonToAlipay://pay';
    } else if (appname == QuantUPIPaymentApps.bhimupi) {
      prefixuri = 'upi://pay';
    } else if (appname == QuantUPIPaymentApps.googlepay) {
      prefixuri = 'gpay://pay';
    } else if (appname == QuantUPIPaymentApps.mipay) {
      prefixuri = 'mipay://pay';
    } else if (appname == QuantUPIPaymentApps.mobikwik) {
      prefixuri = 'mobikwik://pay';
    } else if (appname == QuantUPIPaymentApps.myairtelupi) {
      prefixuri = 'myairtelupi://pay';
    } else if (appname == QuantUPIPaymentApps.paytm) {
      prefixuri = 'paytm://pay';
    } else if (appname == QuantUPIPaymentApps.phonepe) {
      prefixuri = 'phonepe://pay';
    } else if (appname == QuantUPIPaymentApps.sbiupi) {
      prefixuri = 'sbiupi://pay';
    }
  }
  String uri = '$prefixuri'
      '?pa=$payeeAddress'
      '&pn=${Uri.encodeComponent(payeeName)}'
      '&tr=$transactionRef'
      '&tn=${Uri.encodeComponent(transactionNote!)}'
      '&am=${amount.toString()}'
      '&cu=$currency';
  // if (url != null && url!.isNotEmpty) {
  // uri +=
  // '&url=${Uri.encodeComponent('com.google.android.apps.nbu.paisa.user')}';
  // }
  if (merchantId != null && merchantId.isNotEmpty) {
    uri += '&mc=${Uri.encodeComponent(merchantId)}';
  }
  return uri;
}

enum QuantUPIPaymentApps {
  amazonpay,
  bhimupi,
  googlepay,
  mipay,
  mobikwik,
  myairtelupi,
  paytm,
  phonepe,
  sbiupi,
}

class QuantupiResponse {
  String? transactionId;
  String? responseCode;
  String? approvalRefNo;

  /// DO NOT use the string directly. Instead use [QuantupiResponseStatus]
  String? status;
  String? transactionRefId;

  QuantupiResponse(String responseString) {
    List<String> parts = responseString.split('&');

    for (int i = 0; i < parts.length; ++i) {
      String key = parts[i].split('=')[0];
      String value = parts[i].split('=')[1];
      if (key.toLowerCase() == "txnid") {
        transactionId = value;
      } else if (key.toLowerCase() == "responsecode") {
        responseCode = value;
      } else if (key.toLowerCase() == "approvalrefno") {
        approvalRefNo = value;
      } else if (key.toLowerCase() == "status") {
        if (value.toLowerCase() == "success") {
          status = "success";
        } else if (value.toLowerCase().contains("fail")) {
          status = "failure";
        } else if (value.toLowerCase().contains("submit")) {
          status = "submitted";
        } else {
          status = "other";
        }
      } else if (key.toLowerCase() == "txnref") {
        transactionRefId = value;
      }
    }
  }
}

// This class is to match the status of transaction.
// It is advised to use this class to compare the status rather than doing string comparision.
class QuantupiResponseStatus {
  /// SUCCESS occurs when transaction completes successfully.
  static const String success = 'success';

  /// SUBMITTED occurs when transaction remains in pending state.
  static const String submitted = 'submitted';

  /// Deprecated! Don't use it. Use FAILURE instead.
  static const String failed = 'failure';

  /// FAILURE occurs when transaction fails or user cancels it in the middle.
  static const String failure = 'failure';

  /// In case status is not any of the three accepted value (by chance).
  static const String other = 'other';
}

// Class that contains error responses that must be used to check for errors.
class QuantupiResponseError {
  /// When user selects app to make transaction but the app is not installed.
  static const String appnotinstalled = 'app_not_installed';

  /// When the parameters of UPI request is/are invalid or app cannot proceed with the payment.
  static const String invalidparameter = 'invalid_parameters';

  /// Failed to receive any response from the invoked activity.
  static const String nullresponse = 'null_response';

  /// User cancelled the transaction.
  static const String usercanceled = 'user_canceled';
}
