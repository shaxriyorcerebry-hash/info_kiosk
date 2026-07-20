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
        "Quyidagi murojaatlar ko'rib chiqilmaydi:\n"
            "•  anonim murojaatlar;\n"
            "•  jismoniy va yuridik shaxslarning vakillari orqali berilgan murojaatlar, ularning vakolatini tasdiqlovchi hujjatlar mavjud bo'lmagan taqdirda;\n"
            "•  mazkur Qonunda belgilangan boshqa talablarga muvofiq bo'lmagan murojaatlar.\n\n"
            "Murojaatlar ko'rmay qoldirilganda tegishli xulosa tuziladi, u davlat organining, tashkilotning rahbari yoki ularning vakolat berilgan mansabdor shaxsi tomonidan tasdiqlanadi.\n\n"
            "Jismoniy va yuridik shaxs vakilining vakolatini tasdiqlovchi hujjatlar mavjud emasligi sababli murojaatlar ko'rmay qoldirilganligi to'g'risida murojaat qiluvchi tegishli tartibda xabardor qilinadi.",
        'Не подлежат рассмотрению следующие обращения:\n'
            '•  анонимные обращения;\n'
            '•  обращения, поданные через представителей физических и юридических лиц, при отсутствии документов, подтверждающих их полномочия;\n'
            '•  обращения, не соответствующие иным требованиям, установленным настоящим Законом.\n\n'
            'При оставлении обращения без рассмотрения составляется соответствующее заключение, которое утверждается руководителем государственного органа, организации либо их уполномоченным должностным лицом.\n\n'
            'Об оставлении обращения без рассмотрения в связи с отсутствием документов, подтверждающих полномочия представителя физического или юридического лица, обратившееся лицо уведомляется в соответствующем порядке.',
        'The following appeals shall not be considered:\n'
            '•  anonymous appeals;\n'
            '•  appeals submitted through representatives of individuals or legal entities where documents confirming their authority are absent;\n'
            '•  appeals that do not meet other requirements established by this Law.\n\n'
            'When an appeal is left without consideration, a corresponding conclusion is drawn up and approved by the head of the state body or organisation, or by their authorised official.\n\n'
            'The applicant is duly notified when an appeal is left without consideration due to the absence of documents confirming the authority of the representative of an individual or legal entity.',
      ]);

  String get jadvalPersonal => _p(const [
        'Shaxsiy qabul',
        'Личный приём граждан',
        'In-person reception',
      ]);
  String get jadvalMobile => _p(const [
        'Sayyor qabul',
        'Выездной приём',
        'Mobile reception',
      ]);
  String get shaxsiyDesc => _p(const [
        "Hokim va hokim o'rinbosarlari qabul jadvali",
        'График приёма хокима и заместителей',
        'Governor and deputies reception schedule',
      ]);
  String get shaxsiyIntro => _p(const [
        "Toshkent viloyati hokimi va viloyat hokimi o'rinbosarlari tomonidan Toshkent viloyati Xalq qabulxonasi binosida jismoniy va yuridik shaxslarni qabul qilish jadvali",
        'График приёма физических и юридических лиц хокимом Ташкентской области и заместителями хокима в здании Народной приёмной Ташкентской области',
        "Schedule of reception of individuals and legal entities by the governor of Tashkent region and deputy governors at the People's Reception building",
      ]);
  String get shaxsiyNote => _p(const [
        "Qabullar har haftaning belgilangan kuni va vaqtida o'tkaziladi. Murojaat uchun telefonlar: (71) 230-24-30, (71) 230-24-31.",
        'Приёмы проводятся каждую неделю в установленные день и время. Телефоны для обращений: (71) 230-24-30, (71) 230-24-31.',
        'Receptions are held weekly on the designated day and time. Phones for appeals: (71) 230-24-30, (71) 230-24-31.',
      ]);
  String get chooseOrg => _p(const [
        'Tashkilotni tanlang',
        'Выберите организацию',
        'Choose an organisation',
      ]);

  /// "N mobile receptions" label used on org buttons and the modal header.
  String sayyorCount(int n) => switch (lang) {
        Lang.uz => '$n ta sayyor qabul',
        Lang.ru => 'Выездных приёмов: $n',
        Lang.en => '$n mobile receptions',
      };

  /// Intro line above the organisation grid of the mobile reception section.
  String get sayyorHint => _p(const [
        "Tashkilotni tanlang — sayyor qabul o'tkaziladigan tuman yoki shahar, "
            "sana va MFY ro'yxati ko'rsatiladi.",
        'Выберите организацию — будут показаны район или город, дата и МФЙ '
            'проведения выездного приёма.',
        'Choose an organisation to see the district or city, the date and '
            'the mahalla (MFY) of each mobile reception.',
      ]);

  /// Intro line above the direction grid of the issues section.
  String get masalalarIntro => _p(const [
        "Fuqarolar eng ko'p murojaat qilgan yo'nalishlar. Yo'nalishni tanlang — unga oid asosiy masalalar va har biriga qonunchilik asosida beriladigan huquqiy javob ko'rsatiladi.",
        'Направления, по которым поступает больше всего обращений. Выберите направление — будут показаны основные вопросы и правовой ответ по каждому из них.',
        'The subjects citizens appeal about most. Choose one to see the main issues raised and the legal answer required for each.',
      ]);
  String get masalalarChooseOrg => _p(const [
        "Murojaat yo'nalishini tanlang",
        'Выберите направление обращения',
        'Choose the subject of your appeal',
      ]);
  String get huquqiyJavob => _p(const [
        'Huquqiy asos va beriladigan javob',
        'Правовое основание и ответ',
        'Legal basis and the answer given',
      ]);
  String get masalalarTapHint => _p(const [
        "Huquqiy javobni ko'rish uchun masalaga tegining",
        'Коснитесь вопроса, чтобы увидеть правовой ответ',
        'Touch an issue to see the legal answer',
      ]);
  String get umumiyIzohTitle => _p(const [
        'Umumiy huquqiy izoh',
        'Общее правовое разъяснение',
        'General legal notes',
      ]);

  String get aiIntro => _p(const [
        "Assalomu alaykum! Men qabulxonaning AI maslahatchisiman. Qabul tartibi, hujjatlar va xizmatlar bo'yicha savollaringizga javob beraman. Mikrofonga tegib, savolingizni ovoz bilan ayting yoki tayyor savollardan birini tanlang.",
        'Здравствуйте! Я AI-консультант приёмной. Отвечу на вопросы о порядке приёма, документах и услугах. Коснитесь микрофона и задайте вопрос голосом или выберите один из готовых.',
        "Hello! I'm the reception's AI advisor. I can answer questions about reception procedures, documents and services. Touch the microphone and ask your question aloud, or pick one of the suggestions.",
      ]);
  String get aiTapToSpeak => _p(const [
        'Gapirish uchun mikrofonga tegining',
        'Коснитесь микрофона, чтобы говорить',
        'Touch the microphone to speak',
      ]);
  String get aiListening => _p(const [
        'Eshitmoqdaman — gapiring',
        'Слушаю — говорите',
        'Listening — please speak',
      ]);
  String get aiSpeaking => _p(const [
        'Javob aytilmoqda...',
        'Озвучиваю ответ...',
        'Speaking the answer...',
      ]);
  String get aiNoSpeech => _p(const [
        "Ovoz eshitilmadi — qayta urinib ko'ring",
        'Речь не распознана — попробуйте ещё раз',
        'No speech detected — please try again',
      ]);
  String get aiMicUnavailable => _p(const [
        'Mikrofon mavjud emas — quyidagi tayyor savollardan foydalaning',
        'Микрофон недоступен — используйте готовые вопросы ниже',
        'Microphone unavailable — use the quick questions below',
      ]);
  String get aiQuickTitle => _p(const [
        'Tayyor savollar',
        'Готовые вопросы',
        'Quick questions',
      ]);
  String get aiThinking =>
      _p(const ["O'ylayapman...", 'Думаю...', 'Thinking...']);
  String get aiOffline => _p(const [
        "Kechirasiz, bu savolga aniq javob topa olmadim. Iltimos, boshqacha yozing yoki qabulxona xodimiga murojaat qiling. Qabulxona ish vaqti: Dushanba–Juma 9:00–18:00.",
        'Извините, я не нашёл точного ответа на этот вопрос. Пожалуйста, переформулируйте или обратитесь к сотруднику приёмной. Режим работы: Пн–Пт 9:00–18:00.',
        'Sorry, I could not find a precise answer. Please rephrase or contact the reception staff. Working hours: Mon–Fri 9:00–18:00.',
      ]);

  /// Shown while the live voice session is being opened.
  String get aiConnecting => _p(const [
        'Ulanmoqda...',
        'Подключение...',
        'Connecting...',
      ]);

  /// The opening line the live advisor is told to say, verbatim, when a
  /// conversation starts — a fixed greeting keeps the kiosk from launching
  /// into a monologue.
  String get aiGreetingPrompt => _p(const [
        'Aynan quyidagi jumlani, so\'zma-so\'z, boshqa hech narsa qo\'shmasdan ayting: "Assalomu alaykum! Men Xalq qabulxonasining maslahatchisiman. Savolingizni ayting."',
        'Скажите ровно следующую фразу, дословно, ничего не добавляя: "Здравствуйте! Я консультант Народной приёмной. Задайте ваш вопрос."',
        'Say exactly the following sentence, word for word, adding nothing: "Hello! I am the People\'s Reception advisor. Please ask your question."',
      ]);

  String get addressLabel => _p(const ['Manzil', 'Адрес', 'Address']);
  String get phoneLabel => _p(const ['Telefon', 'Телефон', 'Phone']);
  String get trustLabel =>
      _p(const ['Ishonch telefoni', 'Телефон доверия', 'Helpline']);
  String get hoursLabel =>
      _p(const ['Ish vaqti', 'Режим работы', 'Working hours']);
  String get hoursValue => _p(const [
        'Dushanba–Juma 9:00–18:00, tushlik 13:00–14:00',
        'Понедельник–Пятница 9:00–18:00, обед 13:00–14:00',
        'Monday–Friday 9:00–18:00, lunch 13:00–14:00',
      ]);

  /// Legal citation shown at the trailing edge of the footer.
  String get lawRef => _p(const [
        "O'zbekiston Respublikasining Qonuni 445-son, 29-modda",
        'Закон Республики Узбекистан № 445, статья 29',
        'Law of the Republic of Uzbekistan No. 445, Article 29',
      ]);
}
