import 'package:oyaroo/core/brand.dart';
// Rate: 100 rupaye = 43 lakh ${Brand.coinName}. Server (functions/index.js) mein bhi same values hain.
class RechargePackage {
  final int amount; // rupaye
  final int coins;
  final int frame; // milestone (1..20) jo frame theme milta hai
  const RechargePackage(this.amount, this.coins, this.frame);

  int get bonus => coins * 10 ~/ 100; // 10% bonus
}

class RechargePackages {
  static const all = <RechargePackage>[
    RechargePackage(100, 4300000, 1),
    RechargePackage(500, 21500000, 10),
    RechargePackage(1000, 43000000, 20),
  ];

  static RechargePackage? byAmount(int amount) {
    for (final p in all) {
      if (p.amount == amount) return p;
    }
    return null;
  }
}
