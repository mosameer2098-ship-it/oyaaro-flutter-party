HELPER MAP (har helper ka ek kaam; neeche wale upar wale ko call karte hain)

Basic:
  formatters.dart       -> number ko 1,000 jaisa dikhana
  coin_helper.dart      -> coin label, bonus, cut, balance check (formatters ko call karta hai)
  validation_helper.dart-> naam, User ID, positive number ki check
  error_helper.dart     -> error ko user message banana (core/app_error ko call)
  feedback_helper.dart  -> snackbar messages (error_helper aur core/ui ko call)
  frame_helper.dart     -> frame ka naam aur milestone check

Feature:
  gift_helper.dart      -> gift lookup, price, tier, animation time (coin_helper ko call)
  rocket_helper.dart    -> rocket lookup, price (coin_helper ko call)
  game_helper.dart      -> bet check (validation_helper aur coin_helper ko call)
  vip_helper.dart       -> VIP khareedne ki check (coin_helper ko call)
  level_helper.dart     -> level progress, reward text (coin_helper aur frame_helper ko call)
  cp_helper.dart        -> CP level progress, title, color
  family_helper.dart    -> family naam check (validation_helper ko call)

Visual:
  particle_painter.dart -> gift ke particles
  rocket_painter.dart   -> rocket drawing (helpers/ mein)
  frame_ring.dart       -> avatar frame
  menu_page.dart        -> menu pages aur rows

Flow: screen -> handler -> helper -> service. Helper Firebase ko seedha nahi chhoota.
