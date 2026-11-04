import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

/// A credits repository whose checkout call completes only when the test says
/// so, so the notifier's in-flight behaviour can be exercised.
class ControllableCreditsRepository implements CreditsRepository {
  Completer<CreditCheckoutSession>? purchaseGate;
  int purchaseCalls = 0;

  @override
  Future<Result<List<CreditPackage>>> getPackages() async =>
      const Success<List<CreditPackage>>(<CreditPackage>[]);

  @override
  Future<Result<CreditUsage>> getUsage(String orgId) async =>
      const Success<CreditUsage>(CreditUsage.empty);

  @override
  Future<Result<CreditUsageReport>> getUsageReport(String orgId) async =>
      const Success<CreditUsageReport>(CreditUsageReport.empty);

  @override
  Future<Result<List<CreditTransaction>>> getTransactions(String orgId) async =>
      const Success<List<CreditTransaction>>(<CreditTransaction>[]);

  @override
  Future<Result<CreditCheckoutSession>> purchaseCredits({
    required String planId,
    required String email,
  }) {
    purchaseCalls++;
    final gate = Completer<CreditCheckoutSession>();
    purchaseGate = gate;
    return gate.future.then<Result<CreditCheckoutSession>>(
      Success<CreditCheckoutSession>.new,
    );
  }

  @override
  Future<Result<void>> verifyPayment({required String sessionId}) async =>
      const Success<void>(null);
}

const paidPackage = CreditPackage(
  id: 'pkg_pro',
  name: 'Pro',
  description: 'Paid plan',
  price: 5,
  credits: 100,
  benefits: <String>[],
);

void main() {
  late ControllableCreditsRepository repository;
  late ProviderContainer container;
  late CreditsNotifier notifier;

  setUp(() {
    repository = ControllableCreditsRepository();
    container = ProviderContainer(
      overrides: [creditsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    notifier = container.read(creditsNotifierProvider.notifier);
  });

  group('purchasePackage in-flight guard', () {
    test(
      'a second purchase while one is pending does not start another',
      () async {
        final first = notifier.purchasePackage(
          package: paidPackage,
          email: 'ada@example.com',
        );

        final second = await notifier.purchasePackage(
          package: paidPackage,
          email: 'ada@example.com',
        );

        expect(second, isNull, reason: 'the guard returns null, no session');
        expect(repository.purchaseCalls, 1);
        expect(
          container.read(creditsNotifierProvider).status,
          CreditsStatus.purchasing,
        );

        repository.purchaseGate!.complete(
          const CreditCheckoutSession(
            checkoutSessionId: 'cs_1',
            checkoutSessionUrl: 'https://pay.example.com/cs_1',
          ),
        );
        await first;
      },
    );

    test('once the pending purchase finishes a new one is allowed', () async {
      final first = notifier.purchasePackage(
        package: paidPackage,
        email: 'ada@example.com',
      );
      repository.purchaseGate!.complete(
        const CreditCheckoutSession(
          checkoutSessionId: 'cs_1',
          checkoutSessionUrl: 'https://pay.example.com/cs_1',
        ),
      );
      await first;

      notifier.purchasePackage(package: paidPackage, email: 'ada@example.com');

      expect(repository.purchaseCalls, 2);
    });

    test('a free package never starts a checkout', () async {
      const freePackage = CreditPackage(
        id: 'pkg_free',
        name: 'Free',
        description: 'Free plan',
        price: 0,
        credits: 0,
        benefits: <String>[],
      );

      expect(
        await notifier.purchasePackage(
          package: freePackage,
          email: 'ada@example.com',
        ),
        isNull,
      );
      expect(repository.purchaseCalls, 0);
    });
  });
}
