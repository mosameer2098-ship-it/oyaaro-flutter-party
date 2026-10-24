import 'package:oyaroo/core/app_exception.dart';

// Online payment ka interface. Razorpay / Cashfree / Stripe ka SDK yahan wire karein.
// pay() successful hone par paymentId deta hai, cancel par null.
abstract class PaymentGateway {
  Future<String?> pay(int amount);
}

// Jab tak gateway configure na ho, ye saaf message dikhata hai
class UnconfiguredGateway implements PaymentGateway {
  @override
  Future<String?> pay(int amount) =>
      throw const AppException('Online payment gateway abhi configure nahi hai');
}
