import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:intl/intl.dart';

/// Pure-Dart formatting and normalization helpers for timezones and dates.
abstract final class TimezoneFormatter {
  static String sanitizeRawZoneId(String raw) {
    return raw.replaceAll('[', '').replaceAll(' ', '');
  }

  static String formatDisplayLocation(String timeZoneId) {
    return timeZoneId.replaceAll('/', ', ').replaceAll('_', ' ');
  }

  static bool isDaytimeHour(int hour) {
    return hour > 6 && hour < 19;
  }

  static int computeSecondsUntilNextMinute(int currentSecond) {
    final int remaining = 60 - currentSecond;
    return remaining.clamp(1, 60);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd-MMM-yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static String flagAssetForCountryCode(String? countryCode) {
    if (countryCode == null) {
      return '';
    }
    final String normalized = countryCode.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return '';
    }
    return InputValidator.normalizeFlagAssetPath(
      'icons/flags/png100px/$normalized.png',
    );
  }

  /// Resolves an IANA timezone ID (including aliases and sub-regions) to its ISO country code.
  static String? resolveCountryCode(
    String zoneId,
    Map<String, String> countryCodes,
  ) {
    final String? direct = countryCodes[zoneId];
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    final String? aliasCode = _aliasCountryCodes[zoneId];
    if (aliasCode != null) {
      return aliasCode;
    }

    for (final MapEntry<String, String> prefixEntry
        in _prefixCountryCodes.entries) {
      if (zoneId.startsWith(prefixEntry.key)) {
        return prefixEntry.value;
      }
    }
    return null;
  }

  static const Map<String, String> _prefixCountryCodes = <String, String>{
    'America/Argentina/': 'AR',
    'America/Indiana/': 'US',
    'America/Kentucky/': 'US',
    'America/North_Dakota/': 'US',
    'Australia/': 'AU',
    'Brazil/': 'BR',
    'Canada/': 'CA',
    'Chile/': 'CL',
    'Mexico/': 'MX',
    'US/': 'US',
  };

  static const Map<String, String> _aliasCountryCodes = <String, String>{
    'Africa/Asmara': 'ER',
    'Africa/Asmera': 'ER',
    'Africa/Timbuktu': 'ML',
    'America/Atka': 'US',
    'America/Buenos_Aires': 'AR',
    'America/Catamarca': 'AR',
    'America/Ciudad_Juarez': 'MX',
    'America/Coral_Harbour': 'CA',
    'America/Cordoba': 'AR',
    'America/Ensenada': 'MX',
    'America/Fort_Wayne': 'US',
    'America/Godthab': 'GL',
    'America/Indianapolis': 'US',
    'America/Jujuy': 'AR',
    'America/Knox_IN': 'US',
    'America/Louisville': 'US',
    'America/Mendoza': 'AR',
    'America/Montreal': 'CA',
    'America/Nuuk': 'GL',
    'America/Porto_Acre': 'BR',
    'America/Rosario': 'AR',
    'America/Santa_Isabel': 'MX',
    'America/Shiprock': 'US',
    'America/Virgin': 'VI',
    'Antarctica/South_Pole': 'AQ',
    'Asia/Ashkhabad': 'TM',
    'Asia/Calcutta': 'IN',
    'Asia/Chongqing': 'CN',
    'Asia/Chungking': 'CN',
    'Asia/Dacca': 'BD',
    'Asia/Harbin': 'CN',
    'Asia/Istanbul': 'TR',
    'Asia/Kashgar': 'CN',
    'Asia/Katmandu': 'NP',
    'Asia/Macao': 'MO',
    'Asia/Qostanay': 'KZ',
    'Asia/Rangoon': 'MM',
    'Asia/Saigon': 'VN',
    'Asia/Tel_Aviv': 'IL',
    'Asia/Thimbu': 'BT',
    'Asia/Ujung_Pandang': 'ID',
    'Asia/Ulan_Bator': 'MN',
    'Atlantic/Faeroe': 'FO',
    'Atlantic/Jan_Mayen': 'SJ',
    'Cuba': 'CU',
    'Egypt': 'EG',
    'Eire': 'IE',
    'Europe/Belfast': 'GB',
    'Europe/Kiev': 'UA',
    'Europe/Kyiv': 'UA',
    'Europe/Nicosia': 'CY',
    'Europe/Tiraspol': 'MD',
    'Europe/Uzhgorod': 'UA',
    'Europe/Zaporozhye': 'UA',
    'GB': 'GB',
    'GB-Eire': 'GB',
    'Hongkong': 'HK',
    'Iceland': 'IS',
    'Iran': 'IR',
    'Israel': 'IL',
    'Jamaica': 'JM',
    'Japan': 'JP',
    'Kwajalein': 'MH',
    'Libya': 'LY',
    'NZ': 'NZ',
    'NZ-CHAT': 'NZ',
    'Navajo': 'US',
    'PRC': 'CN',
    'Pacific/Enderbury': 'KI',
    'Pacific/Johnston': 'UM',
    'Pacific/Kanton': 'KI',
    'Pacific/Ponape': 'FM',
    'Pacific/Samoa': 'AS',
    'Pacific/Truk': 'FM',
    'Pacific/Yap': 'FM',
    'Poland': 'PL',
    'Portugal': 'PT',
    'ROC': 'TW',
    'ROK': 'KR',
    'Singapore': 'SG',
    'Turkey': 'TR',
  };
}
