import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'quantupi_platform_interface.dart';

/// An implementation of [QuantupiPlatform] that uses method channels.
class MethodChannelQuantupi extends QuantupiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('quantupi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
