import 'package:flutter/material.dart';

class BioLinkItemIcone {
  static const whatsapp = 'WHATSAPP';
  static const instagram = 'INSTAGRAM';
  static const tiktok = 'TIKTOK';
  static const youtube = 'YOUTUBE';
  static const facebook = 'FACEBOOK';
  static const linkedin = 'LINKEDIN';
  static const x = 'X';
  static const telegram = 'TELEGRAM';
  static const discord = 'DISCORD';
  static const spotify = 'SPOTIFY';
  static const pinterest = 'PINTEREST';
  static const threads = 'THREADS';
  static const snapchat = 'SNAPCHAT';
  static const twitch = 'TWITCH';
  static const github = 'GITHUB';
  static const behance = 'BEHANCE';
  static const dribbble = 'DRIBBBLE';
  static const medium = 'MEDIUM';
  static const substack = 'SUBSTACK';
  static const googleMaps = 'GOOGLE_MAPS';
  static const outros = 'OUTROS';

  static const valores = [
    whatsapp,
    instagram,
    tiktok,
    youtube,
    facebook,
    linkedin,
    x,
    telegram,
    discord,
    spotify,
    pinterest,
    threads,
    snapchat,
    twitch,
    github,
    behance,
    dribbble,
    medium,
    substack,
    googleMaps,
    outros,
  ];

  static String? fromJson(dynamic value) {
    if (value == null) return null;
    final texto = value.toString().trim();
    if (texto.isEmpty) return null;
    if (valores.contains(texto)) return texto;
    return null;
  }

  static String label(String icone) {
    switch (icone) {
      case whatsapp:
        return 'WhatsApp';
      case instagram:
        return 'Instagram';
      case tiktok:
        return 'TikTok';
      case youtube:
        return 'YouTube';
      case facebook:
        return 'Facebook';
      case linkedin:
        return 'LinkedIn';
      case x:
        return 'X (Twitter)';
      case telegram:
        return 'Telegram';
      case discord:
        return 'Discord';
      case spotify:
        return 'Spotify';
      case pinterest:
        return 'Pinterest';
      case threads:
        return 'Threads';
      case snapchat:
        return 'Snapchat';
      case twitch:
        return 'Twitch';
      case github:
        return 'GitHub';
      case behance:
        return 'Behance';
      case dribbble:
        return 'Dribbble';
      case medium:
        return 'Medium';
      case substack:
        return 'Substack';
      case googleMaps:
        return 'Google Maps';
      case outros:
        return 'Outros / link genérico';
      default:
        return icone;
    }
  }

  static String abreviacao(String icone) {
    switch (icone) {
      case whatsapp:
        return 'WA';
      case instagram:
        return 'IG';
      case tiktok:
        return 'TT';
      case youtube:
        return 'YT';
      case facebook:
        return 'FB';
      case linkedin:
        return 'IN';
      case x:
        return 'X';
      case telegram:
        return 'TG';
      case discord:
        return 'DC';
      case spotify:
        return 'SP';
      case pinterest:
        return 'PI';
      case threads:
        return 'TH';
      case snapchat:
        return 'SC';
      case twitch:
        return 'TW';
      case github:
        return 'GH';
      case behance:
        return 'BE';
      case dribbble:
        return 'DR';
      case medium:
        return 'MD';
      case substack:
        return 'SS';
      case googleMaps:
        return 'GM';
      case outros:
        return 'LK';
      default:
        return '?';
    }
  }

  static Color cor(String icone) {
    switch (icone) {
      case whatsapp:
        return const Color(0xFF25D366);
      case instagram:
        return const Color(0xFFE4405F);
      case tiktok:
        return const Color(0xFF000000);
      case youtube:
        return const Color(0xFFFF0000);
      case facebook:
        return const Color(0xFF1877F2);
      case linkedin:
        return const Color(0xFF0A66C2);
      case x:
        return const Color(0xFF000000);
      case telegram:
        return const Color(0xFF0088CC);
      case discord:
        return const Color(0xFF5865F2);
      case spotify:
        return const Color(0xFF1DB954);
      case pinterest:
        return const Color(0xFFE60023);
      case threads:
        return const Color(0xFF000000);
      case snapchat:
        return const Color(0xFFFFFC00);
      case twitch:
        return const Color(0xFF9146FF);
      case github:
        return const Color(0xFF181717);
      case behance:
        return const Color(0xFF1769FF);
      case dribbble:
        return const Color(0xFFEA4C89);
      case medium:
        return const Color(0xFF000000);
      case substack:
        return const Color(0xFFFF6719);
      case googleMaps:
        return const Color(0xFF4285F4);
      case outros:
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static Color corTexto(String icone) {
    if (icone == snapchat) return Colors.black;
    return Colors.white;
  }
}
