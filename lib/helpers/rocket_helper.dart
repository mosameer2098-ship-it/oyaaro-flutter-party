import 'package:oyaroo/core/rockets.dart';
import 'package:oyaroo/helpers/coin_helper.dart';

class RocketHelper {
  static RocketSpec? specOf(String id) => Rockets.byId(id);

  static int? priceOf(String id) => Rockets.byId(id)?.price;

  static String priceLabel(RocketSpec r) => CoinHelper.label(r.price);
}
