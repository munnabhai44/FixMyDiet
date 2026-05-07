
class AppTranslations {
  static const Map<String, Map<String, String>> dict = {
    'Hindi': {
      'Your Health Plan': 'आपकी स्वास्थ्य योजना',
      '7-Day Plan': '7-दिन की योजना',
      'Ayurveda': 'आयुर्वेद',
      'Grocery': 'किराना',
      'What Can I Cook?': 'मैं क्या बना सकता हूँ?',
      'Change Language': 'भाषा बदलें',
      'Logout': 'लॉग आउट',
      'Account Profile': 'प्रोफ़ाइल',
      'Reset Profile': 'प्रोफ़ाइल रीसेट करें',
      'Feeling Sick?': 'बीमार महसूस कर रहे हैं?'
    },
    'Gujarati': {
      'Your Health Plan': 'તમારી સ્વાસ્થ્ય યોજના',
      '7-Day Plan': '7-દિવસની યોજના',
      'Ayurveda': 'આયુર્વેદ',
      'Grocery': 'કરિયાણું',
      'What Can I Cook?': 'હું શું બનાવી શકું?',
      'Change Language': 'ભાષા બદલો',
      'Logout': 'લૉગ આઉટ',
      'Account Profile': 'પ્રોફાઇલ',
      'Reset Profile': 'પ્રોફાઇલ રીસેટ કરો',
      'Feeling Sick?': 'બીમાર અનુભવો છો?'
    },
    'Marathi': {
      'Your Health Plan': 'तुमची आरोग्य योजना',
      '7-Day Plan': '7-दिवसांची योजना',
      'Ayurveda': 'आयुर्वेद',
      'Grocery': 'किराणा',
      'What Can I Cook?': 'मी काय बनवू शकतो?',
      'Change Language': 'भाषा बदला',
      'Logout': 'लॉग आउट',
      'Account Profile': 'प्रोफाइल',
      'Reset Profile': 'प्रोफाइल रीसेट करा',
      'Feeling Sick?': 'आजारी वाटत आहे?'
    }
  };

  static String t(String key, String lang) {
    if (dict.containsKey(lang) && dict[lang]!.containsKey(key)) {
      return dict[lang]![key]!;
    }
    return key;
  }
}
