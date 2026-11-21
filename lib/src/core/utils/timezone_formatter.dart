import 'package:flutter_clock/src/core/security/input_validator.dart';
import 'package:intl/intl.dart';

/// Pure-Dart formatting and normalization helpers for timezones and dates.
abstract final class TimezoneFormatter {
  static String sanitizeRawZoneId(String raw) {
    return raw.replaceAll('[', '').replaceAll(' ', '');
  }

  static String formatDisplayLocation(
    String timeZoneId, {
    String? countryCode,
  }) {
    final List<String> segments = timeZoneId
        .split('/')
        .map((String s) => s.replaceAll('_', ' ').trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    if (segments.isEmpty) {
      return timeZoneId.replaceAll('_', ' ');
    }

    final String? resolvedCode =
        (countryCode != null && countryCode.trim().isNotEmpty)
        ? countryCode.trim().toUpperCase()
        : resolveCountryCode(timeZoneId, const <String, String>{});
    final String? countryName = resolvedCode != null
        ? _countryNamesByCode[resolvedCode]
        : null;

    if (countryName != null && countryName.isNotEmpty) {
      final String cityOrSubregion = _extractCityOrSubregion(
        segments,
        countryName,
      );
      if (cityOrSubregion.isEmpty ||
          cityOrSubregion.toLowerCase() == countryName.toLowerCase()) {
        return countryName;
      }
      return '$countryName, $cityOrSubregion';
    }

    if (segments.length >= 3) {
      return segments.sublist(1).join(', ');
    }
    return segments.join(', ');
  }

  static String _extractCityOrSubregion(
    List<String> segments,
    String countryName,
  ) {
    if (segments.length == 1) {
      return segments.first;
    }
    final List<String> tail = segments.sublist(1);
    if (tail.first.toLowerCase() == countryName.toLowerCase() &&
        tail.length > 1) {
      return tail.sublist(1).join(', ');
    }
    return tail.join(', ');
  }

  static String? countryCodeFromFlagAssetPath(String flagAssetPath) {
    final RegExpMatch? match = RegExp(
      r'/([a-z]{2})\.(?:png|svg)$',
    ).firstMatch(flagAssetPath.trim().toLowerCase());
    return match?.group(1)?.toUpperCase();
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

  static const Map<String, String> _countryNamesByCode = <String, String>{
    'AD': 'Andorra',
    'AE': 'United Arab Emirates',
    'AF': 'Afghanistan',
    'AG': 'Antigua and Barbuda',
    'AI': 'Anguilla',
    'AL': 'Albania',
    'AM': 'Armenia',
    'AO': 'Angola',
    'AQ': 'Antarctica',
    'AR': 'Argentina',
    'AS': 'American Samoa',
    'AT': 'Austria',
    'AU': 'Australia',
    'AW': 'Aruba',
    'AX': 'Aland Islands',
    'AZ': 'Azerbaijan',
    'BA': 'Bosnia and Herzegovina',
    'BB': 'Barbados',
    'BD': 'Bangladesh',
    'BE': 'Belgium',
    'BF': 'Burkina Faso',
    'BG': 'Bulgaria',
    'BH': 'Bahrain',
    'BI': 'Burundi',
    'BJ': 'Benin',
    'BL': 'Saint Barthelemy',
    'BM': 'Bermuda',
    'BN': 'Brunei',
    'BO': 'Bolivia',
    'BQ': 'Caribbean Netherlands',
    'BR': 'Brazil',
    'BS': 'Bahamas',
    'BT': 'Bhutan',
    'BW': 'Botswana',
    'BY': 'Belarus',
    'BZ': 'Belize',
    'CA': 'Canada',
    'CC': 'Cocos Islands',
    'CD': 'DR Congo',
    'CF': 'Central African Republic',
    'CG': 'Congo',
    'CH': 'Switzerland',
    'CI': 'Ivory Coast',
    'CK': 'Cook Islands',
    'CL': 'Chile',
    'CM': 'Cameroon',
    'CN': 'China',
    'CO': 'Colombia',
    'CR': 'Costa Rica',
    'CU': 'Cuba',
    'CV': 'Cape Verde',
    'CW': 'Curacao',
    'CX': 'Christmas Island',
    'CY': 'Cyprus',
    'CZ': 'Czechia',
    'DE': 'Germany',
    'DJ': 'Djibouti',
    'DK': 'Denmark',
    'DM': 'Dominica',
    'DO': 'Dominican Republic',
    'DZ': 'Algeria',
    'EC': 'Ecuador',
    'EE': 'Estonia',
    'EG': 'Egypt',
    'EH': 'Western Sahara',
    'ER': 'Eritrea',
    'ES': 'Spain',
    'ET': 'Ethiopia',
    'FI': 'Finland',
    'FJ': 'Fiji',
    'FK': 'Falkland Islands',
    'FM': 'Micronesia',
    'FO': 'Faroe Islands',
    'FR': 'France',
    'GA': 'Gabon',
    'GB': 'United Kingdom',
    'GD': 'Grenada',
    'GE': 'Georgia',
    'GF': 'French Guiana',
    'GG': 'Guernsey',
    'GH': 'Ghana',
    'GI': 'Gibraltar',
    'GL': 'Greenland',
    'GM': 'Gambia',
    'GN': 'Guinea',
    'GP': 'Guadeloupe',
    'GQ': 'Equatorial Guinea',
    'GR': 'Greece',
    'GS': 'South Georgia',
    'GT': 'Guatemala',
    'GU': 'Guam',
    'GW': 'Guinea-Bissau',
    'GY': 'Guyana',
    'HK': 'Hong Kong',
    'HN': 'Honduras',
    'HR': 'Croatia',
    'HT': 'Haiti',
    'HU': 'Hungary',
    'ID': 'Indonesia',
    'IE': 'Ireland',
    'IL': 'Israel',
    'IM': 'Isle of Man',
    'IN': 'India',
    'IO': 'British Indian Ocean Territory',
    'IQ': 'Iraq',
    'IR': 'Iran',
    'IS': 'Iceland',
    'IT': 'Italy',
    'JE': 'Jersey',
    'JM': 'Jamaica',
    'JO': 'Jordan',
    'JP': 'Japan',
    'KE': 'Kenya',
    'KG': 'Kyrgyzstan',
    'KH': 'Cambodia',
    'KI': 'Kiribati',
    'KM': 'Comoros',
    'KN': 'Saint Kitts and Nevis',
    'KP': 'North Korea',
    'KR': 'South Korea',
    'KW': 'Kuwait',
    'KY': 'Cayman Islands',
    'KZ': 'Kazakhstan',
    'LA': 'Laos',
    'LB': 'Lebanon',
    'LC': 'Saint Lucia',
    'LI': 'Liechtenstein',
    'LK': 'Sri Lanka',
    'LR': 'Liberia',
    'LS': 'Lesotho',
    'LT': 'Lithuania',
    'LU': 'Luxembourg',
    'LV': 'Latvia',
    'LY': 'Libya',
    'MA': 'Morocco',
    'MC': 'Monaco',
    'MD': 'Moldova',
    'ME': 'Montenegro',
    'MF': 'Saint Martin',
    'MG': 'Madagascar',
    'MH': 'Marshall Islands',
    'MK': 'North Macedonia',
    'ML': 'Mali',
    'MM': 'Myanmar',
    'MN': 'Mongolia',
    'MO': 'Macau',
    'MP': 'Northern Mariana Islands',
    'MQ': 'Martinique',
    'MR': 'Mauritania',
    'MS': 'Montserrat',
    'MT': 'Malta',
    'MU': 'Mauritius',
    'MV': 'Maldives',
    'MW': 'Malawi',
    'MX': 'Mexico',
    'MY': 'Malaysia',
    'MZ': 'Mozambique',
    'NA': 'Namibia',
    'NC': 'New Caledonia',
    'NE': 'Niger',
    'NF': 'Norfolk Island',
    'NG': 'Nigeria',
    'NI': 'Nicaragua',
    'NL': 'Netherlands',
    'NO': 'Norway',
    'NP': 'Nepal',
    'NR': 'Nauru',
    'NU': 'Niue',
    'NZ': 'New Zealand',
    'OM': 'Oman',
    'PA': 'Panama',
    'PE': 'Peru',
    'PF': 'French Polynesia',
    'PG': 'Papua New Guinea',
    'PH': 'Philippines',
    'PK': 'Pakistan',
    'PL': 'Poland',
    'PM': 'Saint Pierre and Miquelon',
    'PN': 'Pitcairn Islands',
    'PR': 'Puerto Rico',
    'PS': 'Palestine',
    'PT': 'Portugal',
    'PW': 'Palau',
    'PY': 'Paraguay',
    'QA': 'Qatar',
    'RE': 'Reunion',
    'RO': 'Romania',
    'RS': 'Serbia',
    'RU': 'Russia',
    'RW': 'Rwanda',
    'SA': 'Saudi Arabia',
    'SB': 'Solomon Islands',
    'SC': 'Seychelles',
    'SD': 'Sudan',
    'SE': 'Sweden',
    'SG': 'Singapore',
    'SH': 'Saint Helena',
    'SI': 'Slovenia',
    'SJ': 'Svalbard and Jan Mayen',
    'SK': 'Slovakia',
    'SL': 'Sierra Leone',
    'SM': 'San Marino',
    'SN': 'Senegal',
    'SO': 'Somalia',
    'SR': 'Suriname',
    'SS': 'South Sudan',
    'ST': 'Sao Tome and Principe',
    'SV': 'El Salvador',
    'SX': 'Sint Maarten',
    'SY': 'Syria',
    'SZ': 'Eswatini',
    'TC': 'Turks and Caicos Islands',
    'TD': 'Chad',
    'TF': 'French Southern Territories',
    'TG': 'Togo',
    'TH': 'Thailand',
    'TJ': 'Tajikistan',
    'TK': 'Tokelau',
    'TL': 'Timor-Leste',
    'TM': 'Turkmenistan',
    'TN': 'Tunisia',
    'TO': 'Tonga',
    'TR': 'Turkey',
    'TT': 'Trinidad and Tobago',
    'TV': 'Tuvalu',
    'TW': 'Taiwan',
    'TZ': 'Tanzania',
    'UA': 'Ukraine',
    'UG': 'Uganda',
    'UM': 'U.S. Outlying Islands',
    'US': 'United States',
    'UY': 'Uruguay',
    'UZ': 'Uzbekistan',
    'VA': 'Vatican City',
    'VC': 'Saint Vincent and the Grenadines',
    'VE': 'Venezuela',
    'VG': 'British Virgin Islands',
    'VI': 'U.S. Virgin Islands',
    'VN': 'Vietnam',
    'VU': 'Vanuatu',
    'WF': 'Wallis and Futuna',
    'WS': 'Samoa',
    'YE': 'Yemen',
    'YT': 'Mayotte',
    'ZA': 'South Africa',
    'ZM': 'Zambia',
    'ZW': 'Zimbabwe',
  };
}
