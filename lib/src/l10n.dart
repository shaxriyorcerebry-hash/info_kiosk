/// Lightweight three-language localisation (Uzbek / Russian / English).
///
/// Strings are stored as `[uz, ru, en]` triples and resolved by [Lang.index],
/// mirroring the original kiosk content one-to-one.
library;

enum Lang { uz, ru, en }

extension LangLabel on Lang {
  /// Short label shown on the language switch.
  String get label => switch (this) {
        Lang.uz => "O'Z",
        Lang.ru => 'РУ',
        Lang.en => 'EN',
      };
}

/// Translated UI strings for a single language.
class Tr {
  const Tr(this.lang);
  final Lang lang;

  String _p(List<String> v) => v[lang.index];

  /// Full official name of the office, shown as the main header title.
  String get orgFullName => _p(const [
        "O'zbekiston Respublikasi Prezidentining Toshkent viloyatidagi Xalq qabulxonasi",
        'Народная приёмная Президента Республики Узбекистан в Ташкентской области',
        "People's Reception of the President of the Republic of Uzbekistan in the Tashkent region",
      ]);
  String get home => _p(const ['Bosh sahifa', 'Главная', 'Home']);
  String get back => _p(const ['Orqaga', 'Назад', 'Back']);
  String get homeTitle => _p(const [
        "Kerakli bo'limni tanlang",
        'Выберите нужный раздел',
        'Choose a section',
      ]);
  String get footerHint => _p(const [
        'Ekranga tegib boshqaring',
        'Управляйте касанием экрана',
        'Touch the screen to navigate',
      ]);

  String get qabulStepsTitle =>
      _p(const ['Qabul bosqichlari', 'Этапы приёма', 'Reception steps']);
  String get qabulDocsTitle => _p(const [
        'Kerakli hujjatlar',
        'Необходимые документы',
        'Required documents',
      ]);
  String get qabulNote => _p(const [
        "Eslatma: anonim murojaatlar, shuningdek haqoratli so'zlar bo'lgan murojaatlar ko'rib chiqilmaydi.",
        'Примечание: анонимные обращения, а также обращения с оскорбительными выражениями не рассматриваются.',
        'Note: anonymous appeals, as well as appeals containing offensive language, are not considered.',
      ]);

  String get workTitle => _p(const ['Ish vaqti', 'Режим работы', 'Working hours']);
  String get receptionTitle => _p(const [
        'Rahbariyat qabul jadvali',
        'График приёма руководства',
        'Leadership reception schedule',
      ]);
  String get receptionNote => _p(const [
        "Qabulga oldindan yozilish tavsiya etiladi. Yozilish uchun qabulxona xodimiga yoki ishonch telefoniga murojaat qiling.",
        'Рекомендуется предварительная запись на приём. Для записи обратитесь к сотруднику приёмной или по телефону доверия.',
        'Advance booking is recommended. To book, contact the reception staff or call the helpline.',
      ]);

  String get arizaTitle => _p(const [
        'Ariza topshirish tartibi',
        'Порядок подачи заявления',
        'How to submit an application',
      ]);
  String get arizaText => _p(const [
        "Arizani qabulxonaga shaxsan, pochta orqali yoki elektron shaklda topshirish mumkin. Ariza ro'yxatga olingach, sizga ro'yxat raqami beriladi — u orqali murojaat holatini kuzatib borishingiz mumkin.",
        'Заявление можно подать лично в приёмную, по почте или в электронной форме. После регистрации вам выдаётся регистрационный номер, по которому можно отслеживать статус обращения.',
        'You can submit an application in person, by mail, or electronically. After registration you receive a registration number to track the status of your appeal.',
      ]);

  String get aiIntro => _p(const [
        "Assalomu alaykum! Men qabulxonaning AI maslahatchisiman. Qabul tartibi, hujjatlar va xizmatlar bo'yicha savollaringizga javob beraman. Savolingizni yozing yoki tayyor savollardan birini tanlang.",
        'Здравствуйте! Я AI-консультант приёмной. Отвечу на вопросы о порядке приёма, документах и услугах. Напишите свой вопрос или выберите один из готовых.',
        "Hello! I'm the reception's AI advisor. I can answer questions about reception procedures, documents and services. Type your question or pick one of the suggestions.",
      ]);
  String get aiPlaceholder => _p(const [
        'Savolingizni yozing...',
        'Напишите ваш вопрос...',
        'Type your question...',
      ]);
  String get send => _p(const ['Yuborish', 'Отправить', 'Send']);
  String get aiReady => _p(const [
        'Savolingizga javob berishga tayyorman',
        'Готов ответить на ваш вопрос',
        'Ready to answer your question',
      ]);
  String get aiThinking =>
      _p(const ["O'ylayapman...", 'Думаю...', 'Thinking...']);
  String get orbHint => _p(const [
        "Suhbatni boshlash uchun savol yozing",
        'Напишите вопрос, чтобы начать диалог',
        'Type a question to start the conversation',
      ]);
  String get aiOffline => _p(const [
        "Kechirasiz, bu savolga aniq javob topa olmadim. Iltimos, boshqacha yozing yoki qabulxona xodimiga murojaat qiling. Qabulxona ish vaqti: Dushanba–Juma 9:00–18:00.",
        'Извините, я не нашёл точного ответа на этот вопрос. Пожалуйста, переформулируйте или обратитесь к сотруднику приёмной. Режим работы: Пн–Пт 9:00–18:00.',
        'Sorry, I could not find a precise answer. Please rephrase or contact the reception staff. Working hours: Mon–Fri 9:00–18:00.',
      ]);

  String get addressLabel => _p(const ['Manzil', 'Адрес', 'Address']);
  String get phoneLabel => _p(const ['Telefon', 'Телефон', 'Phone']);
  String get trustLabel =>
      _p(const ['Ishonch telefoni', 'Телефон доверия', 'Helpline']);
  String get hoursLabel =>
      _p(const ['Ish vaqti', 'Режим работы', 'Working hours']);
  String get hoursValue => _p(const [
        'Du–Ju 9:00–18:00, tushlik 13:00–14:00',
        'Пн–Пт 9:00–18:00, обед 13:00–14:00',
        'Mon–Fri 9:00–18:00, lunch 13:00–14:00',
      ]);

  String get mapPlaceholder =>
      _p(const ['Joylashuv', 'Расположение', 'Location']);
}
