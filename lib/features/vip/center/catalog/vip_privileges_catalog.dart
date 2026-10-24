import 'package:flutter/material.dart';

import '../models/vip_privilege.dart';

/// Privileges, har ek ka minLevel. Level badhne par list lamba hota hai.
class VipPrivilegesCatalog {
  const VipPrivilegesCatalog._();

  static const all = <VipPrivilege>[
    VipPrivilege(id: 'view_visitors', title: 'View visitor records', minLevel: 1, icon: Icons.visibility_outlined),
    VipPrivilege(id: 'vip_gift', title: 'VIP gift', minLevel: 1, icon: Icons.card_giftcard),
    VipPrivilege(id: 'room_on_top', title: 'Room online list on top', minLevel: 1, icon: Icons.vertical_align_top),
    VipPrivilege(id: 'room_pictures', title: 'Send room pictures', minLevel: 1, icon: Icons.image_outlined),
    VipPrivilege(id: 'profile_bg', title: 'Profile background', minLevel: 1, icon: Icons.portrait),
    VipPrivilege(id: 'msg_pictures', title: 'Send message pictures', minLevel: 1, icon: Icons.photo_library_outlined),
    VipPrivilege(id: 'priority_mic', title: 'Priority mic request', minLevel: 2, icon: Icons.mic_none),
    VipPrivilege(id: 'multi_profile_bg', title: 'Multiple profile backgrounds', minLevel: 3, icon: Icons.collections_outlined),
    VipPrivilege(id: 'exp_boost', title: 'EXP speed up', minLevel: 3, icon: Icons.rocket_launch_outlined),
    VipPrivilege(id: 'hide_visits', title: 'Hide visit records', minLevel: 3, icon: Icons.visibility_off_outlined),
    VipPrivilege(id: 'custom_theme', title: 'Customized theme', minLevel: 3, icon: Icons.palette_outlined),
    VipPrivilege(id: 'golden_name', title: 'Golden name', minLevel: 3, icon: Icons.auto_awesome),
    VipPrivilege(id: 'hide_online', title: 'Hide online status', minLevel: 4, icon: Icons.person_off_outlined),
    VipPrivilege(id: 'id_six', title: '6-digit special ID', minLevel: 4, icon: Icons.tag),
    VipPrivilege(id: 'avoid_disturb', title: 'Avoid disturbing', minLevel: 5, icon: Icons.notifications_off_outlined),
    VipPrivilege(id: 'cant_kick', title: "Can't be kicked", minLevel: 5, icon: Icons.shield_outlined),
    VipPrivilege(id: 'dynamic_avatar', title: 'Dynamic avatar', minLevel: 6, icon: Icons.gif_box_outlined),
    VipPrivilege(id: 'cant_ban_chat', title: "Can't be banned in public chat", minLevel: 6, icon: Icons.chat_bubble_outline),
    VipPrivilege(id: 'id_five', title: '5-digit special ID', minLevel: 7, icon: Icons.confirmation_number_outlined),
    VipPrivilege(id: 'unban_once', title: 'Unban account (1 time)', minLevel: 7, icon: Icons.lock_open_outlined),
    VipPrivilege(id: 'private_badge', title: 'Private room badge', minLevel: 8, icon: Icons.workspace_premium_outlined),
    VipPrivilege(id: 'entry_priority', title: 'Entry priority', minLevel: 8, icon: Icons.flash_on),
    VipPrivilege(id: 'concierge', title: 'Personal VIP support', minLevel: 9, icon: Icons.support_agent),
    VipPrivilege(id: 'gift_discount', title: 'Gift discount 5%', minLevel: 9, icon: Icons.percent),
  ];
}
