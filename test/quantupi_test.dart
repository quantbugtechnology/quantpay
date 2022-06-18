import 'package:flutter_test/flutter_test.dart';
import 'package:quantupi/quantupi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Connectivity',
    () {
      late Quantupi quantupi;
      setUp(() async {
        quantupi = Quantupi(
          receiverUpiId: 'upi@test',
          receiverName: 'Test',
          transactionNote: 'Test',
          amount: 1.0,
        );
      });

      test('receiverupi', () {
        expect('upi@test', quantupi.receiverUpiId);
      });

      test('receivername', () {
        expect('Test', quantupi.receiverName);
      });

      test('receiverupi', () {
        expect('upi@test', quantupi.receiverUpiId);
      });

      test('transactionnote', () {
        expect('Test', quantupi.transactionNote);
      });

      test('transactionnote', () {
        expect(1.0, quantupi.amount);
      });
    },
  );
}
