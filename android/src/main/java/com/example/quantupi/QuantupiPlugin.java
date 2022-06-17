package com.example.quantupi;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;


/** QuantupiPlugin */
public class QuantupiPlugin implements FlutterPlugin, MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

    int uniqueRequestCode = 3498;
    MethodChannel.Result finalResult;
    boolean exception = false;
    Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "quantupi");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("startTransaction")) {
            finalResult = result;
            String receiverUpiId = call.argument("receiverUpiId");
            String receiverName = call.argument("receiverName");
            String transactionRefId = call.argument("transactionRefId");
            String transactionNote = call.argument("transactionNote");
            String amount = call.argument("amount");
            String currency = call.argument("currency");
            String url = call.argument("url");
            String merchantId = call.argument("merchantId");

            try {
                exception = false;
                Uri.Builder uriBuilder = new Uri.Builder();
                uriBuilder.scheme("upi").authority("pay");
                uriBuilder.appendQueryParameter("pa", receiverUpiId);
                uriBuilder.appendQueryParameter("pn", receiverName);
                uriBuilder.appendQueryParameter("tn", transactionNote);
                uriBuilder.appendQueryParameter("am", amount);
                if (transactionRefId != null) {
                    uriBuilder.appendQueryParameter("tr", transactionRefId);
                }
                if (currency == null) {
                    uriBuilder.appendQueryParameter("cr", "INR");
                } else
                    uriBuilder.appendQueryParameter("cu", currency);
                if (url != null) {
                    uriBuilder.appendQueryParameter("url", url);
                }
                if (merchantId != null) {
                    uriBuilder.appendQueryParameter("mc", merchantId);
                }

                Uri uri = uriBuilder.build();

                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(uri);
                activity.startActivityForResult(intent, uniqueRequestCode);
            } catch (Exception ex) {
                exception = true;
                result.error("FAILED", "invalid_parameters", null);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    // On receiving the response.
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (uniqueRequestCode == requestCode && finalResult != null) {
            if (data != null) {
                try {
                    String response =data.getStringExtra("response");

                    if (!exception) finalResult.success(response);
                } catch (Exception ex) {
                    if (!exception) finalResult.success("null_response");
                }
            } else {
                Log.d("Quantupi NOTE: ", "Received NULL, User cancelled the transaction.");
                if (!exception) finalResult.success("user_canceled");
            }
        }
        return true;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();
        binding.addActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}
