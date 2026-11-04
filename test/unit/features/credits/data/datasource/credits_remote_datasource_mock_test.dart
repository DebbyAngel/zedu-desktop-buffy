import '../../../../../helpers/helpers.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class MockApiBaseService extends Mock implements ApiBaseService {}

void main() {
  group('CreditsRemoteDataSourceImpl mock verification', () {
    late MockApiBaseService api;

    setUp(() {
      api = MockApiBaseService();
    });

    CreditsRemoteDataSourceImpl source() => CreditsRemoteDataSourceImpl(
      config: AppConfig(
        apiBaseUrl: 'https://api.example.com',
        usesMockData: true,
      ),
      apiBaseService: api,
    );

    test(
      'verifyPayment updates the mock balance instead of throwing',
      () async {
        final datasource = source();
        final before = await datasource.getUsage('org-1');

        await datasource.verifyPayment(sessionId: 'sess_mock');
        final after = await datasource.getUsage('org-1');

        expect(after.balance, before.balance + 1000);
        expect(after.totalPurchased, before.totalPurchased + 1000);
      },
    );

    test('a second mock verification adds credits again', () async {
      final datasource = source();
      final before = await datasource.getUsage('org-1');

      await datasource.verifyPayment(sessionId: 'sess_one');
      await datasource.verifyPayment(sessionId: 'sess_two');
      final after = await datasource.getUsage('org-1');

      expect(after.balance, before.balance + 2000);
    });

    test('never calls the live payment endpoint in mock mode', () async {
      await source().verifyPayment(sessionId: 'sess_mock');

      verifyNever(
        () => api.post<Map<String, dynamic>>(
          path: any(named: 'path'),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          headers: any(named: 'headers'),
        ),
      );
    });
  });
}
