import 'package:flutter_test/flutter_test.dart';
import 'package:quantupi/quantupi.dart';
import 'package:quantupi/quantupi_platform_interface.dart';
import 'package:quantupi/quantupi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockQuantupiPlatform
    with MockPlatformInterfaceMixin
    implements QuantupiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final QuantupiPlatform initialPlatform = QuantupiPlatform.instance;

  test('$MethodChannelQuantupi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelQuantupi>());
  });

  test('getPlatformVersion', () async {
    Quantupi quantupiPlugin = Quantupi(
      receiverUpiId: 'upi@pay',
      receiverName: 'Tester',
      transactionRefId: 'TestingId',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.00,
    );
    MockQuantupiPlatform fakePlatform = MockQuantupiPlatform();
    QuantupiPlatform.instance = fakePlatform;

    expect(await quantupiPlugin.getPlatformVersion(), '42');
  });
}
