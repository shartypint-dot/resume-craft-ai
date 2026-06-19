import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/domain/entities/user_entity.dart';

enum SubscriptionStatus { active, expired, cancelled, notPurchased }

class SubscriptionInfo {
  final SubscriptionStatus status;
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final bool isTrialActive;
  final String? productId;
  final bool willRenew;

  const SubscriptionInfo({
    required this.status,
    required this.tier,
    this.expirationDate,
    this.isTrialActive = false,
    this.productId,
    this.willRenew = false,
  });

  bool get isPro => tier == SubscriptionTier.pro;

  static const free = SubscriptionInfo(
    status: SubscriptionStatus.notPurchased,
    tier: SubscriptionTier.free,
  );
}

class RevenueCatService {
  static bool _isInitialized = false;
  static final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      final apiKey = Platform.isIOS
          ? AppConstants.revenueCatApiKeyIos
          : AppConstants.revenueCatApiKeyAndroid;

      if (apiKey.isEmpty) {
        debugPrint('RevenueCat: API key not configured — running in offline mode');
        return;
      }

      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener(_customerInfoController.add);
      _isInitialized = true;
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
    }
  }

  static Future<void> identifyUser(String userId) async {
    if (!_isInitialized) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat identify error: $e');
    }
  }

  static Future<void> logOut() async {
    if (!_isInitialized) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logOut error: $e');
    }
  }

  static Future<SubscriptionInfo> getSubscriptionInfo() async {
    if (!_isInitialized) return SubscriptionInfo.free;

    try {
      final info = await Purchases.getCustomerInfo();
      return _parseCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat getSubscriptionInfo error: $e');
      return SubscriptionInfo.free;
    }
  }

  static Future<List<Package>> getAvailablePackages() async {
    if (!_isInitialized) return [];

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];
      return current.availablePackages;
    } catch (e) {
      debugPrint('RevenueCat getOfferings error: $e');
      return [];
    }
  }

  static Future<SubscriptionResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      return SubscriptionResult.error('Service not initialized');
    }

    try {
      final info = await Purchases.purchasePackage(package);
      final subscriptionInfo = _parseCustomerInfo(info);
      return SubscriptionResult.success(subscriptionInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return SubscriptionResult.cancelled();
      }
      return SubscriptionResult.error(_getErrorMessage(e));
    } catch (e) {
      return SubscriptionResult.error(e.toString());
    }
  }

  static Future<SubscriptionResult> restorePurchases() async {
    if (!_isInitialized) {
      return SubscriptionResult.error('Service not initialized');
    }

    try {
      final info = await Purchases.restorePurchases();
      final subscriptionInfo = _parseCustomerInfo(info);

      if (subscriptionInfo.isPro) {
        return SubscriptionResult.success(subscriptionInfo);
      }
      return SubscriptionResult.noPurchasesFound();
    } catch (e) {
      return SubscriptionResult.error(e.toString());
    }
  }

  static Stream<CustomerInfo> get customerInfoStream {
    if (!_isInitialized) return const Stream.empty();
    return _customerInfoController.stream;
  }

  static SubscriptionInfo _parseCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[AppConstants.revenueCatEntitlementId];

    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionInfo.free;
    }

    final expDate = entitlement.expirationDate != null
        ? DateTime.tryParse(entitlement.expirationDate!)
        : null;

    return SubscriptionInfo(
      status: SubscriptionStatus.active,
      tier: SubscriptionTier.pro,
      expirationDate: expDate,
      isTrialActive: entitlement.periodType == PeriodType.trial,
      productId: entitlement.productIdentifier,
      willRenew: entitlement.willRenew,
    );
  }

  static String _getErrorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'The purchase is invalid. Please try again.';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.insufficientPermissionsError:
        return 'Insufficient permissions for this purchase.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Payment is pending. You\'ll be notified when it completes.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This product is not available for purchase in your region.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class SubscriptionResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool isNoPurchasesFound;
  final SubscriptionInfo? subscriptionInfo;
  final String? errorMessage;

  const SubscriptionResult._({
    required this.isSuccess,
    this.isCancelled = false,
    this.isNoPurchasesFound = false,
    this.subscriptionInfo,
    this.errorMessage,
  });

  factory SubscriptionResult.success(SubscriptionInfo info) => SubscriptionResult._(
    isSuccess: true,
    subscriptionInfo: info,
  );

  factory SubscriptionResult.cancelled() => const SubscriptionResult._(
    isSuccess: false,
    isCancelled: true,
  );

  factory SubscriptionResult.noPurchasesFound() => const SubscriptionResult._(
    isSuccess: false,
    isNoPurchasesFound: true,
  );

  factory SubscriptionResult.error(String message) => SubscriptionResult._(
    isSuccess: false,
    errorMessage: message,
  );
}
