import 'package:flutter/material.dart';

import 'l10n.dart';
import 'screen.dart';

/// A home-screen card / section descriptor.
class CardDef {
  const CardDef(this.id, this.icon, this.title, this.desc);
  final Screen id;
  final IconData icon;
  final Map<Lang, String> title;
  final Map<Lang, String> desc;
}

/// An official receiving citizens in person at the People's Reception:
/// full name (Latin, with a Cyrillic variant shown for Russian), localised
/// position, weekly reception slot and contact phone.
class QabulOfficial {
  const QabulOfficial(
    this.name,
    this.position,
    this.day,
    this.time,
    this.phone, {
    this.location = '',
    this.scheduled,
  });
  final Map<Lang, String> name;
  final Map<Lang, String> position;
  final Map<Lang, String> day;
  final String time;
  final String phone;

  /// Where the reception is held — set only for the governor's dated
  /// reception. Empty hides the line.
  final String location;

  /// The date of the reception when it is set rather than weekly — only the
  /// governor's. [day] still carries the same date as one line of text.
  final ScheduledReception? scheduled;
}

/// A reception on a set date (the governor's), for the card that draws the
/// date large rather than as a line of text.
class ScheduledReception {
  const ScheduledReception(this.at, {this.withYear = false});

  /// Start, on the Tashkent wall clock.
  final DateTime at;

  /// The date is not in the current year, so the year is written out.
  final bool withYear;
}

/// Whether [official] is the governor rather than a deputy.
///
/// Read from the Uzbek position: `hokimi` / `hokim` as a whole word. A
/// deputy's "viloyat hokim**ining** … o'rinbosari" contains `hokimi` too, so
/// the word boundary and the `o'rinbosar` check are both needed.
bool isHokimOfficial(QabulOfficial official) {
  final p = (official.position[Lang.uz] ?? '')
      .toLowerCase()
      .replaceAll(RegExp("['`‘’ʻʼ]"), '');
  return RegExp(r'\bhokimi?\b').hasMatch(p) && !p.contains('orinbosar');
}

/// All localised, office-agnostic content shown by the kiosk.
class AppData {
  const AppData._();

  static const List<CardDef> cards = [
    CardDef(Screen.qabul, Icons.assignment_outlined, {
      Lang.uz: 'Qabul tartibi',
      Lang.ru: 'Порядок приёма',
      Lang.en: 'Reception procedure',
    }, {
      Lang.uz: 'Fuqarolarni qabul qilish qoidalari va kerakli hujjatlar',
      Lang.ru: 'Правила приёма граждан и необходимые документы',
      Lang.en: 'Rules for receiving citizens and required documents',
    }),
    CardDef(Screen.jadval, Icons.schedule_outlined, {
      Lang.uz: 'Ish vaqti va qabul jadvali',
      Lang.ru: 'Режим работы и график приёма',
      Lang.en: 'Hours & reception schedule',
    }, {
      Lang.uz: "Shaxsiy qabul va sayyor qabul bo'limlari",
      Lang.ru: 'Личный приём граждан и выездной приём',
      Lang.en: 'In-person and mobile reception sections',
    }),
    CardDef(Screen.masalalar, Icons.account_balance_outlined, {
      Lang.uz: 'Tashkilot va masalalar',
      Lang.ru: 'Организации и вопросы',
      Lang.en: 'Organisations & issues',
    }, {
      Lang.uz: "Ko'p so'raladigan masalalar va ularning huquqiy yechimi",
      Lang.ru: 'Часто поднимаемые вопросы и их правовое решение',
      Lang.en: 'Most-raised issues and their legal resolution',
    }),
    CardDef(Screen.faq, Icons.help_outline, {
      Lang.uz: "Ko'p beriladigan savollar",
      Lang.ru: 'Частые вопросы',
      Lang.en: 'FAQ',
    }, {
      Lang.uz: "Eng ko'p so'raladigan savollarga javoblar",
      Lang.ru: 'Ответы на самые частые вопросы',
      Lang.en: 'Answers to the most common questions',
    }),
    CardDef(Screen.ai, Icons.smart_toy_outlined, {
      Lang.uz: 'AI Maslahatchi',
      Lang.ru: 'AI Консультант',
      Lang.en: 'AI Advisor',
    }, {
      Lang.uz: "Sun'iy intellekt maslahatchisi bilan ovozli suhbat",
      Lang.ru: 'Голосовой диалог с ИИ-консультантом',
      Lang.en: 'Voice conversation with the AI advisor',
    }),
    CardDef(Screen.contact, Icons.call_outlined, {
      Lang.uz: "Bog'lanish",
      Lang.ru: 'Контакты',
      Lang.en: 'Contact',
    }, {
      Lang.uz: 'Manzil, telefon, ishonch telefoni va xarita',
      Lang.ru: 'Адрес, телефон, телефон доверия и карта',
      Lang.en: 'Address, phone, helpline and map',
    }),
  ];

  static const Map<Lang, List<String>> qabulSteps = {
    Lang.uz: [
      "Qabulxona xodimiga murojaat qiling va shaxsingizni tasdiqlovchi hujjatni ko'rsating.",
      "Murojaatingiz ro'yxatga olinadi va sizga navbat raqami beriladi.",
      "Mas'ul xodim yoki rahbar qabuliga yo'naltirilasiz.",
      "Murojaat natijasi bo'yicha belgilangan muddatda yozma yoki og'zaki javob olasiz.",
    ],
    Lang.ru: [
      'Обратитесь к сотруднику приёмной и предъявите документ, удостоверяющий личность.',
      'Ваше обращение регистрируется, вам выдаётся номер очереди.',
      'Вас направляют на приём к ответственному сотруднику или руководителю.',
      'В установленный срок вы получаете письменный или устный ответ по результатам обращения.',
    ],
    Lang.en: [
      'Approach the reception staff and present an identity document.',
      'Your appeal is registered and you receive a queue number.',
      'You are directed to the responsible officer or a manager.',
      'You receive a written or verbal response within the established period.',
    ],
  };

  static const Map<Lang, List<String>> qabulDocs = {
    Lang.uz: [
      "Pasport yoki ID-karta (shaxsni tasdiqlovchi hujjat)",
      "Yozma murojaat matni (ariza, shikoyat yoki taklif)",
      "Vakil orqali murojaatda — ishonchnoma",
      "Avvalgi murojaatlarga oid hujjatlar (mavjud bo'lsa)",
    ],
    Lang.ru: [
      'Паспорт или ID-карта (документ, удостоверяющий личность)',
      'Текст письменного обращения (заявление, жалоба или предложение)',
      'При обращении через представителя — доверенность',
      'Документы по предыдущим обращениям (при наличии)',
    ],
    Lang.en: [
      'Passport or ID card (identity document)',
      'Written appeal text (application, complaint or proposal)',
      'If applying via a representative — power of attorney',
      'Documents related to previous appeals (if any)',
    ],
  };

  /// In-person reception schedule: the governor of Tashkent region and the
  /// deputy governors, received weekly at the People's Reception building.
  static const List<QabulOfficial> shaxsiyQabul = [
    QabulOfficial(
      {
        Lang.uz: 'Mirzayev Zoyir Toirovich',
        Lang.ru: 'Мирзаев Зоир Тоирович',
        Lang.en: 'Mirzayev Zoyir Toirovich',
      },
      {
        Lang.uz: 'Toshkent viloyati hokimi',
        Lang.ru: 'Хоким Ташкентской области',
        Lang.en: 'Governor of Tashkent region',
      },
      _wednesday,
      '10:00 – 14:00',
      '71-232-80-73',
    ),
    QabulOfficial(
      {
        Lang.uz: "Tursunov Otabek Ravshanbek o'g'li",
        Lang.ru: 'Турсунов Отабек Равшанбек ўғли',
        Lang.en: "Tursunov Otabek Ravshanbek o'g'li",
      },
      {
        Lang.uz: "Viloyat hokimining moliya-iqtisod va kambag'allikni "
            "qisqartirish masalalari bo'yicha birinchi o'rinbosari",
        Lang.ru: 'Первый заместитель хокима области по финансово-'
            'экономическим вопросам и сокращению бедности',
        Lang.en: 'First deputy governor for finance, economy and poverty '
            'reduction',
      },
      _tuesday,
      '14:00 – 16:00',
      '71-232-80-71',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Qoraboyev Xurshid Abdivahobovich',
        Lang.ru: 'Қорабоев Хуршид Абдивахобович',
        Lang.en: 'Qoraboyev Xurshid Abdivahobovich',
      },
      {
        Lang.uz: "Viloyat hokimining qishloq va suv xo'jaligi masalalari "
            "bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по вопросам сельского и '
            'водного хозяйства',
        Lang.en: 'Deputy governor for agriculture and water management',
      },
      _friday,
      '15:00 – 17:00',
      '71-232-80-44',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Mahmudov Shukurulla Nasimxonovich',
        Lang.ru: 'Махмудов Шукурулла Насимхонович',
        Lang.en: 'Mahmudov Shukurulla Nasimxonovich',
      },
      {
        Lang.uz: "Viloyat hokimining qurilish, kommunikatsiyalar, kommunal "
            "xo'jalik, ekologiya va ko'kalamzorlashtirish masalalari "
            "bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по вопросам строительства, '
            'коммуникаций, коммунального хозяйства, экологии и озеленения',
        Lang.en: 'Deputy governor for construction, communications, '
            'utilities, ecology and landscaping',
      },
      _tuesday,
      '10:00 – 12:00',
      '71-232-80-42',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Mamajonov Jahongir Anvarjonovich',
        Lang.ru: 'Мамажонов Жаҳонгир Анваржонович',
        Lang.en: 'Mamajonov Jahongir Anvarjonovich',
      },
      {
        Lang.uz: "Viloyat hokimining investitsiyalar, sanoat va savdo "
            "masalalari bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по вопросам инвестиций, '
            'промышленности и торговли',
        Lang.en: 'Deputy governor for investment, industry and trade',
      },
      _monday,
      '14:00 – 16:00',
      '99-301-19-90',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Sultanbekov Otabek Sabirovich',
        Lang.ru: 'Султанбеков Отабек Сабирович',
        Lang.en: 'Sultanbekov Otabek Sabirovich',
      },
      {
        Lang.uz: "Viloyat hokimining yoshlar siyosati, ijtimoiy "
            "rivojlantirish va ma'naviy-ma'rifiy ishlar bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по молодёжной политике, '
            'социальному развитию и духовно-просветительской работе',
        Lang.en: 'Deputy governor for youth policy, social development and '
            'spiritual-educational affairs',
      },
      _friday,
      '9:00 – 11:00',
      '71-232-80-87',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Babajanov Djamshid Xakimovich',
        Lang.ru: 'Бабажанов Джамшид Хакимович',
        Lang.en: 'Babajanov Djamshid Xakimovich',
      },
      {
        Lang.uz: "Viloyat hokimining turizm, madaniyat, madaniy meros va "
            "ommaviy kommunikatsiyalar masalalari bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по вопросам туризма, культуры, '
            'культурного наследия и массовых коммуникаций',
        Lang.en: 'Deputy governor for tourism, culture, cultural heritage '
            'and mass communications',
      },
      _thursday,
      '15:00 – 17:00',
      '99-313-43-99',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Arzikulov Ilxomjon Nizomiddinovich',
        Lang.ru: 'Арзикулов Илхомжон Низомиддинович',
        Lang.en: 'Arzikulov Ilxomjon Nizomiddinovich',
      },
      {
        Lang.uz: "Viloyat hokimining jamoat va diniy tashkilotlar bilan "
            "aloqalar bo'yicha o'rinbosari",
        Lang.ru: 'Заместитель хокима области по связям с общественными и '
            'религиозными организациями',
        Lang.en: 'Deputy governor for relations with public and religious '
            'organisations',
      },
      _monday,
      '11:00 – 13:00',
      '71-232-80-30',
    ),
    QabulOfficial(
      {
        Lang.uz: 'Normirzayeva Nilufar Anvarjanovna',
        Lang.ru: 'Нормирзаева Нилуфар Анваржановна',
        Lang.en: 'Normirzayeva Nilufar Anvarjanovna',
      },
      {
        Lang.uz: "Viloyat hokimining o'rinbosari — oila va xotin-qizlar "
            "boshqarmasi boshlig'i",
        Lang.ru: 'Заместитель хокима области — начальник управления по '
            'делам семьи и женщин',
        Lang.en: 'Deputy governor — head of the family and women’s affairs '
            'department',
      },
      _thursday,
      '10:00 – 12:00',
      '71-232-80-71',
    ),
  ];

  // Weekly reception day labels shared by the officials above.
  static const Map<Lang, String> _monday = {
    Lang.uz: 'Har haftaning dushanba kuni',
    Lang.ru: 'Каждый понедельник',
    Lang.en: 'Every Monday',
  };
  static const Map<Lang, String> _tuesday = {
    Lang.uz: 'Har haftaning seshanba kuni',
    Lang.ru: 'Каждый вторник',
    Lang.en: 'Every Tuesday',
  };
  static const Map<Lang, String> _wednesday = {
    Lang.uz: 'Har haftaning chorshanba kuni',
    Lang.ru: 'Каждую среду',
    Lang.en: 'Every Wednesday',
  };
  static const Map<Lang, String> _thursday = {
    Lang.uz: 'Har haftaning payshanba kuni',
    Lang.ru: 'Каждый четверг',
    Lang.en: 'Every Thursday',
  };
  static const Map<Lang, String> _friday = {
    Lang.uz: 'Har haftaning juma kuni',
    Lang.ru: 'Каждую пятницу',
    Lang.en: 'Every Friday',
  };


  /// [title, description] — no longer a visible section; kept as knowledge
  /// for the offline AI advisor, which answers service questions from it.
  static const Map<Lang, List<List<String>>> xizmatlar = {
    Lang.uz: [
      ['Yozma murojaatlarni qabul qilish', 'Ariza, shikoyat va takliflarni ro\'yxatga olish'],
      ['Og\'zaki qabulga yozish', 'Rahbariyat qabuliga navbatga yozilish'],
      ['Murojaat holatini tekshirish', 'Ro\'yxat raqami bo\'yicha ma\'lumot berish'],
      ['Yuridik maslahat', 'Fuqarolarga bepul huquqiy maslahat berish'],
      ['Davlat xizmatlariga yo\'naltirish', 'Tegishli idoralarga yo\'naltirish va tushuntirish'],
      ['Ishonch telefoni', 'Telefon orqali murojaatlarni qabul qilish'],
    ],
    Lang.ru: [
      ['Приём письменных обращений', 'Регистрация заявлений, жалоб и предложений'],
      ['Запись на устный приём', 'Запись в очередь на приём к руководству'],
      ['Проверка статуса обращения', 'Информация по регистрационному номеру'],
      ['Юридическая консультация', 'Бесплатные правовые консультации гражданам'],
      ['Направление в госорганы', 'Направление в соответствующие ведомства и разъяснения'],
      ['Телефон доверия', 'Приём обращений по телефону'],
    ],
    Lang.en: [
      ['Written appeals intake', 'Registration of applications, complaints and proposals'],
      ['Booking an in-person reception', 'Queue registration for leadership reception'],
      ['Appeal status check', 'Information by registration number'],
      ['Legal advice', 'Free legal consultations for citizens'],
      ['Referral to state bodies', 'Referral to relevant agencies with guidance'],
      ['Helpline', 'Receiving appeals by phone'],
    ],
  };

  /// [question, answer]
  static const Map<Lang, List<List<String>>> faq = {
    Lang.uz: [
      ['Qabulga qanday yozilaman?', 'Qabulxonaga shaxsan kelib, ishonch telefoni orqali yoki qabulxona xodimi yordamida navbatga yozilishingiz mumkin. O\'zingiz bilan pasport yoki ID-karta olib keling.'],
      ['Murojaatim qancha muddatda ko\'rib chiqiladi?', 'Murojaatlar qonunchilikka muvofiq 15 kun ichida, qo\'shimcha o\'rganish talab etilsa 1 oy ichida ko\'rib chiqiladi.'],
      ['Qanday hujjatlar kerak?', 'Shaxsni tasdiqlovchi hujjat (pasport yoki ID-karta) va yozma murojaat matni. Vakil orqali murojaatda ishonchnoma talab etiladi.'],
      ['Anonim murojaat qilsam bo\'ladimi?', 'Yo\'q, anonim murojaatlar ko\'rib chiqilmaydi. Murojaatda F.I.Sh. va aloqa ma\'lumotlari ko\'rsatilishi shart.'],
      ['Murojaat holatini qanday bilaman?', 'Ro\'yxatga olishda berilgan raqam bo\'yicha qabulxona telefoniga qo\'ng\'iroq qilib yoki shaxsan kelib bilishingiz mumkin.'],
      ['Onlayn murojaat yuborsam bo\'ladimi?', 'Ha, murojaatni elektron shaklda ham yuborish mumkin. Batafsil ma\'lumot uchun qabulxona xodimiga murojaat qiling.'],
    ],
    Lang.ru: [
      ['Как записаться на приём?', 'Вы можете записаться лично в приёмной, по телефону доверия или с помощью сотрудника приёмной. Возьмите с собой паспорт или ID-карту.'],
      ['В какой срок рассматривается обращение?', 'Обращения рассматриваются в течение 15 дней, а при необходимости дополнительного изучения — в течение 1 месяца.'],
      ['Какие документы нужны?', 'Документ, удостоверяющий личность (паспорт или ID-карта), и текст письменного обращения. При обращении через представителя — доверенность.'],
      ['Можно ли обратиться анонимно?', 'Нет, анонимные обращения не рассматриваются. В обращении обязательно указываются Ф.И.О. и контактные данные.'],
      ['Как узнать статус обращения?', 'По номеру, выданному при регистрации, — позвонив в приёмную или обратившись лично.'],
      ['Можно ли отправить обращение онлайн?', 'Да, обращение можно направить и в электронной форме. За подробностями обратитесь к сотруднику приёмной.'],
    ],
    Lang.en: [
      ['How do I book an appointment?', 'You can register in person at the reception, via the helpline, or with the help of reception staff. Bring your passport or ID card.'],
      ['How long does a review take?', 'Appeals are reviewed within 15 days, or within 1 month if additional study is required.'],
      ['What documents are required?', 'An identity document (passport or ID card) and the written appeal text. A power of attorney is required when applying via a representative.'],
      ['Can I apply anonymously?', 'No, anonymous appeals are not considered. The appeal must include your full name and contact details.'],
      ['How do I check my appeal status?', 'Using the number issued at registration — by calling the reception or visiting in person.'],
      ['Can I submit an appeal online?', 'Yes, appeals can also be submitted electronically. Ask the reception staff for details.'],
    ],
  };

  static const Map<Lang, List<String>> chips = {
    Lang.uz: [
      'Qabulga qanday yozilaman?',
      'Qanday hujjatlar kerak?',
      "Murojaat qancha vaqtda ko'riladi?",
      'Qabul kunlari qachon?',
    ],
    Lang.ru: [
      'Как записаться на приём?',
      'Какие документы нужны?',
      'Сколько рассматривается обращение?',
      'Когда дни приёма?',
    ],
    Lang.en: [
      'How do I book an appointment?',
      'What documents are required?',
      'How long does a review take?',
      'When are reception days?',
    ],
  };

  static const Map<Lang, List<String>> months = {
    Lang.uz: ['yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun', 'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'],
    Lang.ru: ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
    Lang.en: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
  };

  static const Map<Lang, List<String>> weekdays = {
    Lang.uz: ['Yakshanba', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'],
    Lang.ru: ['Воскресенье', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота'],
    Lang.en: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  };

  /// Localised date string, mirroring the source formatting per language.
  static String formatDate(DateTime d, Lang lang) {
    final wd = weekdays[lang]![d.weekday % 7];
    final mo = months[lang]![d.month - 1];
    return switch (lang) {
      Lang.en => '$wd, $mo ${d.day}, ${d.year}',
      Lang.ru => '$wd, ${d.day} $mo ${d.year}',
      Lang.uz => '$wd, ${d.day}-$mo ${d.year}',
    };
  }

  /// A reception date: `24-sentabr` · `24 сентября` · `24 September`, with
  /// the year only when asked.
  static String receptionDay(DateTime d, Lang lang, {bool withYear = false}) {
    final mo = months[lang]![d.month - 1];
    return switch (lang) {
      Lang.uz => withYear ? '${d.year}-yil ${d.day}-$mo' : '${d.day}-$mo',
      Lang.ru => withYear ? '${d.day} $mo ${d.year} г.' : '${d.day} $mo',
      Lang.en => withYear ? '${d.day} $mo ${d.year}' : '${d.day} $mo',
    };
  }

  /// `payshanba` · `четверг` · `Thursday` — lower-case where the language
  /// writes a weekday so after a date.
  static String weekdayName(DateTime d, Lang lang) {
    final wd = weekdays[lang]![d.weekday % 7];
    return lang == Lang.en ? wd : wd.toLowerCase();
  }

  /// The two above as one line: `24-sentabr, payshanba` ·
  /// `24 сентября, четверг` · `Thursday, 24 September`.
  static String receptionDate(DateTime d, Lang lang, {bool withYear = false}) {
    final day = receptionDay(d, lang, withYear: withYear);
    final wd = weekdayName(d, lang);
    return lang == Lang.en ? '$wd, $day' : '$day, $wd';
  }

  static String formatTime(DateTime d) {
    String p(int n) => n < 10 ? '0$n' : '$n';
    return '${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }
}
