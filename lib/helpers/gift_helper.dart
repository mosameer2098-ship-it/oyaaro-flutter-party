import 'package:oyaroo/core/event_config.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/helpers/coin_helper.dart';

class GiftHelper {
  static List<GiftSpec> get all => GiftCatalog.all;

  static GiftSpec? find(String name) => GiftCatalog.byName(name);

  static int? priceOf(String name) => find(name)?.price;

  static String priceLabel(GiftSpec g) =>
      g.price == 0 ? 'Free' : CoinHelper.label(g.price);

  static List<GiftSpec> inCategory(GiftCategory c) => GiftCatalog.byCategory(c);

  static String categoryName(GiftCategory c) => switch (c) {
        GiftCategory.normal => 'Gifts',
        GiftCategory.vip => 'VIP',
        GiftCategory.free => 'Free',
        GiftCategory.event => 'Event',
        GiftCategory.cp => 'CP',
        GiftCategory.friend => 'Friends',
      };

  // null = gift bheja ja sakta hai, warna wajah
  static String? lockReason(GiftSpec g, int vip) {
    if (g.category == GiftCategory.event && !EventConfig.isActive()) {
      return 'Event abhi active nahi hai';
    }
    if (g.minVip > 0 && vip < g.minVip) return 'VIP ${g.minVip} chahiye';
    return null;
  }

  static String tierName(GiftTier t) => switch (t) {
        GiftTier.small => 'Small',
        GiftTier.medium => 'Medium',
        GiftTier.big => 'Big',
        GiftTier.legendary => 'Legendary',
      };

  static int durationMs(GiftTier t) => switch (t) {
        GiftTier.small => 2000,
        GiftTier.medium => 3000,
        GiftTier.big => 4000,
        GiftTier.legendary => 5500,
      };

  static int particleCount(GiftTier t) => switch (t) {
        GiftTier.small => 16,
        GiftTier.medium => 28,
        GiftTier.big => 45,
        GiftTier.legendary => 70,
      };
}
