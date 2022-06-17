import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'quantupi_method_channel.dart';

abstract class QuantupiPlatform extends PlatformInterface {
  /// Constructs a QuantupiPlatform.
  QuantupiPlatform() : super(token: _token);

  static final Object _token = Object();

  static QuantupiPlatform _instance = MethodChannelQuantupi();

  /// The default instance of [QuantupiPlatform] to use.
  ///
  /// Defaults to [MethodChannelQuantupi].
  static QuantupiPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QuantupiPlatform] when
  /// they register themselves.
  static set instance(QuantupiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
