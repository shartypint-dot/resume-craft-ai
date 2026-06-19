import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../services/subscription/revenue_cat_service.dart';

enum SubscriptionLoadState { initial, loading, loaded, error }

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionInfo _info = SubscriptionInfo.free;
  SubscriptionLoadState _state = SubscriptionLoadState.initial;
  List<Package> _packages = [];
  String? _errorMessage;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  StreamSubscription<CustomerInfo>? _customerInfoSub;

  SubscriptionInfo get info => _info;
  SubscriptionLoadState get state => _state;
  List<Package> get packages => _packages;
  String? get errorMessage => _errorMessage;
  bool get isPurchasing => _isPurchasing;
  bool get isRestoring => _isRestoring;
  bool get isPro => _info.isPro;
  bool get isLoading => _state == SubscriptionLoadState.loading;

  Package? get monthlyPackage {
    for (final p in _packages) {
      if (p.packageType == PackageType.monthly) return p;
    }
    return null;
  }

  Package? get annualPackage {
    for (final p in _packages) {
      if (p.packageType == PackageType.annual) return p;
    }
    return null;
  }

  Future<void> initialize(String userId) async {
    _state = SubscriptionLoadState.loading;
    notifyListeners();

    try {
      await RevenueCatService.identifyUser(userId);
      await _loadData();
      _listenToCustomerInfo();
      _state = SubscriptionLoadState.loaded;
    } catch (e) {
      _state = SubscriptionLoadState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      RevenueCatService.getSubscriptionInfo(),
      RevenueCatService.getAvailablePackages(),
    ]);
    _info = results[0] as SubscriptionInfo;
    _packages = results[1] as List<Package>;
  }

  void _listenToCustomerInfo() {
    _customerInfoSub?.cancel();
    _customerInfoSub = RevenueCatService.customerInfoStream.listen((customerInfo) {
      // Re-fetch parsed info on stream update
      RevenueCatService.getSubscriptionInfo().then((info) {
        _info = info;
        notifyListeners();
      });
    });
  }

  Future<SubscriptionResult> purchase(Package package) async {
    _isPurchasing = true;
    _errorMessage = null;
    notifyListeners();

    final result = await RevenueCatService.purchasePackage(package);

    if (result.isSuccess && result.subscriptionInfo != null) {
      _info = result.subscriptionInfo!;
    } else if (result.errorMessage != null) {
      _errorMessage = result.errorMessage;
    }

    _isPurchasing = false;
    notifyListeners();
    return result;
  }

  Future<SubscriptionResult> restore() async {
    _isRestoring = true;
    _errorMessage = null;
    notifyListeners();

    final result = await RevenueCatService.restorePurchases();

    if (result.isSuccess && result.subscriptionInfo != null) {
      _info = result.subscriptionInfo!;
    } else if (result.errorMessage != null) {
      _errorMessage = result.errorMessage;
    }

    _isRestoring = false;
    notifyListeners();
    return result;
  }

  Future<void> refresh() async {
    _info = await RevenueCatService.getSubscriptionInfo();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _customerInfoSub?.cancel();
    super.dispose();
  }
}
