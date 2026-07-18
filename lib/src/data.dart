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
      Lang.uz: 'Rahbariyat qabul kunlari va soatlari',
      Lang.ru: 'Дни и часы приёма руководства',
      Lang.en: 'Leadership reception days and hours',
    }),
    CardDef(Screen.bolimlar, Icons.apartment_outlined, {
      Lang.uz: "Bo'limlar va xodimlar",
      Lang.ru: 'Отделы и сотрудники',
      Lang.en: 'Departments & staff',
    }, {
      Lang.uz: "Bo'limlar, mas'ul shaxslar, xona va telefon raqamlari",
      Lang.ru: 'Отделы, ответственные лица, кабинеты и телефоны',
      Lang.en: 'Departments, responsible persons, rooms and phones',
    }),
    CardDef(Screen.xizmatlar, Icons.description_outlined, {
      Lang.uz: 'Xizmatlar',
      Lang.ru: 'Услуги',
      Lang.en: 'Services',
    }, {
      Lang.uz: "Ko'rsatiladigan xizmatlar va ariza topshirish tartibi",
      Lang.ru: 'Оказываемые услуги и порядок подачи заявлений',
      Lang.en: 'Available services and how to apply',
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
      Lang.uz: "Sun'iy intellekt yordamchisi bilan suhbat",
      Lang.ru: 'Диалог с помощником на базе ИИ',
      Lang.en: 'Chat with the AI assistant',
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

  /// [label, value]
  static const Map<Lang, List<List<String>>> workRows = {
    Lang.uz: [
      ['Dushanba – Juma', '9:00 – 18:00'],
      ['Tushlik', '13:00 – 14:00'],
      ['Shanba, Yakshanba', 'Dam olish kuni'],
    ],
    Lang.ru: [
      ['Понедельник – Пятница', '9:00 – 18:00'],
      ['Обеденный перерыв', '13:00 – 14:00'],
      ['Суббота, Воскресенье', 'Выходной'],
    ],
    Lang.en: [
      ['Monday – Friday', '9:00 – 18:00'],
      ['Lunch break', '13:00 – 14:00'],
      ['Saturday, Sunday', 'Closed'],
    ],
  };

  /// [position, days, hours]
  static const Map<Lang, List<List<String>>> jadval = {
    Lang.uz: [
      ['Qabulxona rahbari', 'Dushanba, Chorshanba', '10:00–13:00'],
      ["Rahbar o'rinbosari", 'Seshanba, Payshanba', '14:00–17:00'],
      ["Bo'lim mas'ullari", 'Har ish kuni', '9:00–17:00'],
    ],
    Lang.ru: [
      ['Руководитель приёмной', 'Понедельник, Среда', '10:00–13:00'],
      ['Заместитель руководителя', 'Вторник, Четверг', '14:00–17:00'],
      ['Ответственные отделов', 'Каждый рабочий день', '9:00–17:00'],
    ],
    Lang.en: [
      ['Head of Reception', 'Monday, Wednesday', '10:00–13:00'],
      ['Deputy Head', 'Tuesday, Thursday', '14:00–17:00'],
      ['Department officers', 'Every working day', '9:00–17:00'],
    ],
  };

  /// [name, person, room, phone]
  static const Map<Lang, List<List<String>>> bolimlar = {
    Lang.uz: [
      ['Murojaatlarni qabul qilish bo\'limi', 'A. Karimov', '101-xona', '(71) 200-00-01'],
      ['Yuridik maslahat bo\'limi', 'N. Rahimova', '102-xona', '(71) 200-00-02'],
      ['Ijtimoiy masalalar bo\'limi', 'S. Tosheva', '201-xona', '(71) 200-00-03'],
      ['Nazorat va ijro bo\'limi', 'B. Yusupov', '202-xona', '(71) 200-00-04'],
      ['Axborot xizmati', 'D. Alimov', '105-xona', '(71) 200-00-05'],
    ],
    Lang.ru: [
      ['Отдел приёма обращений', 'А. Каримов', 'каб. 101', '(71) 200-00-01'],
      ['Отдел юридических консультаций', 'Н. Рахимова', 'каб. 102', '(71) 200-00-02'],
      ['Отдел социальных вопросов', 'С. Тошева', 'каб. 201', '(71) 200-00-03'],
      ['Отдел контроля и исполнения', 'Б. Юсупов', 'каб. 202', '(71) 200-00-04'],
      ['Информационная служба', 'Д. Алимов', 'каб. 105', '(71) 200-00-05'],
    ],
    Lang.en: [
      ['Appeals Intake Department', 'A. Karimov', 'Room 101', '(71) 200-00-01'],
      ['Legal Advice Department', 'N. Rahimova', 'Room 102', '(71) 200-00-02'],
      ['Social Affairs Department', 'S. Tosheva', 'Room 201', '(71) 200-00-03'],
      ['Control & Execution Department', 'B. Yusupov', 'Room 202', '(71) 200-00-04'],
      ['Information Service', 'D. Alimov', 'Room 105', '(71) 200-00-05'],
    ],
  };

  /// [title, description]
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

  static String formatTime(DateTime d) {
    String p(int n) => n < 10 ? '0$n' : '$n';
    return '${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }
}
