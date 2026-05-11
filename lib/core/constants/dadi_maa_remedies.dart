import 'dart:math';

class DadiMaaRemedy {
  final String id;
  final String titleGu;
  final String descriptionGu;
  final String titleEn;
  final String descriptionEn;
  final String category;
  const DadiMaaRemedy({
    required this.id,
    required this.titleGu,
    required this.descriptionGu,
    required this.titleEn,
    required this.descriptionEn,
    required this.category,
  });
}

class DadiMaaRemedies {
  static const List<DadiMaaRemedy> all = [
    DadiMaaRemedy(
      id: 'r1',
      titleGu: 'અજમાનું પાણી',
      descriptionGu: '1 ચમચી અજમો ગરમ પાણીમાં રાતભર પલાળો. સવારે ખાલી પેટે પીવો. પેટની ગેસ અને અપચામાં રાહત મળે.',
      titleEn: 'Ajwain Water',
      descriptionEn: 'Soak 1 tsp Ajwain in warm water overnight. Drink first thing in the morning for digestion.',
      category: 'Digestion',
    ),
    DadiMaaRemedy(
      id: 'r2',
      titleGu: 'તુલસી-આદુ ઉકાળો',
      descriptionGu: 'તુલસીના 5-6 પાન, આદુ અને મરી ઉકાળો. મધ ઉમેરીને પીવો. ગળાના દુખાવામાં ફાયદો.',
      titleEn: 'Tulsi-Ginger Kadha',
      descriptionEn: 'Boil 5-6 Tulsi leaves with ginger and black pepper. Add honey before drinking.',
      category: 'Immunity',
    ),
    DadiMaaRemedy(
      id: 'r3',
      titleGu: 'હળદર-દૂધ',
      descriptionGu: 'રાત્રે ગરમ દૂધમાં 1/2 ચમચી હળદર મિક્સ કરો. રોગપ્રતિકારક શક્તિ વધે.',
      titleEn: 'Turmeric Milk',
      descriptionEn: 'Mix 1/2 tsp turmeric in warm milk at night. Boosts immunity.',
      category: 'Immunity',
    ),
    DadiMaaRemedy(
      id: 'r4',
      titleGu: 'લીમડાનો લેપ',
      descriptionGu: 'લીમડાના પાન વાટીને ગુલાબજળ સાથે લેપ બનાવો. 15 મિનિટ ચહેરા પર લગાવો. ખીલ દૂર થાય.',
      titleEn: 'Neem Face Pack',
      descriptionEn: 'Apply a paste of neem leaves and rose water for 15 minutes. Clears acne.',
      category: 'Skin',
    ),
    DadiMaaRemedy(
      id: 'r5',
      titleGu: 'વરિયાળી ચાવવી',
      descriptionGu: 'ભોજન પછી 1/2 ચમચી શેકેલી વરિયાળી ચાવો. પેટ ફૂલવાની સમસ્યા દૂર થાય.',
      titleEn: 'Fennel Seeds',
      descriptionEn: 'Chew half a teaspoon of roasted fennel seeds after every meal. Reduces bloating.',
      category: 'Digestion',
    ),
    DadiMaaRemedy(
      id: 'r6',
      titleGu: 'બદામ-અખરોટ',
      descriptionGu: 'રાત્રે 4-5 બદામ પલાળો. સવારે 1 અખરોટ સાથે ખાઓ. દિમાગ તેજ થાય.',
      titleEn: 'Soaked Almonds',
      descriptionEn: 'Soak 4-5 almonds overnight. Eat with 1 walnut in the morning. Boosts brain power.',
      category: 'Energy',
    ),
    DadiMaaRemedy(
      id: 'r7',
      titleGu: 'સરસવ તેલ માલિશ',
      descriptionGu: 'ગરમ સરસવના તેલમાં લસણની 2-3 કળી નાખીને સાંધા પર માલિશ કરો. દુખાવો ઓછો થાય.',
      titleEn: 'Mustard Oil Massage',
      descriptionEn: 'Massage joints with warm mustard oil infused with garlic cloves. Reduces pain.',
      category: 'Joint Pain',
    ),
    DadiMaaRemedy(
      id: 'r8',
      titleGu: 'ઘી-પગ માલિશ',
      descriptionGu: 'સૂતા પહેલા પગના તળિયે ગરમ ઘી ઘસો. સારી ઊંઘ આવે.',
      titleEn: 'Ghee Foot Massage',
      descriptionEn: 'Rub warm ghee on the soles of your feet before bed. Promotes deep sleep.',
      category: 'Sleep',
    ),
    DadiMaaRemedy(
      id: 'r9',
      titleGu: 'મેથીનું પાણી',
      descriptionGu: '1 ચમચી મેથી દાણા રાત્રે પાણીમાં પલાળો. સવારે પીવો. ડાયાબિટીસ કંટ્રોલમાં મદદ.',
      titleEn: 'Fenugreek Water',
      descriptionEn: 'Soak 1 tsp fenugreek seeds overnight. Drink in the morning. Helps control blood sugar.',
      category: 'Diabetes',
    ),
    DadiMaaRemedy(
      id: 'r10',
      titleGu: 'નાળિયેર તેલ-કઢીપત્તા',
      descriptionGu: 'ગરમ નાળિયેર તેલમાં કઢીપત્તા ઉકાળો. અઠવાડિયે 2 વાર વાળમાં લગાવો. વાળ ખરતા અટકે.',
      titleEn: 'Coconut Oil Hair Mask',
      descriptionEn: 'Heat coconut oil with curry leaves. Apply to scalp twice a week. Stops hair fall.',
      category: 'Hair',
    ),
    DadiMaaRemedy(
      id: 'r11',
      titleGu: 'જીરું-લીંબુ પાણી',
      descriptionGu: 'ગ્લાસ પાણીમાં 1 ચમચી જીરું અને લીંબુ રસ નાખો. સવારે પીવો. વજન ઘટાડવામાં મદદ.',
      titleEn: 'Cumin-Lemon Water',
      descriptionEn: 'Add cumin and lemon juice to a glass of warm water. Drink in the morning. Aids weight loss.',
      category: 'Weight Loss',
    ),
    DadiMaaRemedy(
      id: 'r12',
      titleGu: 'ત્રિફળા ચૂર્ણ',
      descriptionGu: 'રાત્રે 1/2 ચમચી ત્રિફળા ચૂર્ણ ગરમ પાણી સાથે લો. કબજિયાત દૂર થાય.',
      titleEn: 'Triphala Churna',
      descriptionEn: 'Take 1/2 tsp Triphala churna with warm water at night. Relieves constipation.',
      category: 'Digestion',
    ),
    DadiMaaRemedy(
      id: 'r13',
      titleGu: 'આમળા-મધ',
      descriptionGu: '1 ચમચી આમળા રસમાં મધ ઉમેરીને ખાલી પેટે લો. રોગપ્રતિકારક શક્તિ વધે.',
      titleEn: 'Amla-Honey',
      descriptionEn: 'Take 1 tsp amla juice with honey on empty stomach. Supercharges immunity.',
      category: 'Immunity',
    ),
    DadiMaaRemedy(
      id: 'r14',
      titleGu: 'ગુલકંદ',
      descriptionGu: '1 ચમચી ગુલકંદ ઠંડા દૂધ સાથે લો. શરીરની ગરમી ઓછી થાય.',
      titleEn: 'Gulkand',
      descriptionEn: 'Take 1 tsp Gulkand with cold milk. Reduces body heat.',
      category: 'Cooling',
    ),
    DadiMaaRemedy(
      id: 'r15',
      titleGu: 'અશ્વગંધા દૂધ',
      descriptionGu: 'રાત્રે ગરમ દૂધમાં 1/4 ચમચી અશ્વગંધા પાવડર મિક્સ કરો. તણાવ ઘટે અને ઊંઘ સારી આવે.',
      titleEn: 'Ashwagandha Milk',
      descriptionEn: 'Mix 1/4 tsp Ashwagandha powder in warm milk at night. Reduces stress and improves sleep.',
      category: 'Stress',
    ),
  ];

  static String _lastShownId = '';

  static DadiMaaRemedy getRandomRemedy() {
    final random = Random();
    DadiMaaRemedy remedy;
    do {
      remedy = all[random.nextInt(all.length)];
    } while (remedy.id == _lastShownId && all.length > 1);
    _lastShownId = remedy.id;
    return remedy;
  }
}