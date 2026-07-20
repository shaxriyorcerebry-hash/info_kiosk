import 'package:flutter/material.dart';

import 'l10n.dart';

/// One issue raised by citizens at an organisation, with the legal grounds
/// and the answer that must be given. All user-visible text is trilingual
/// (Uzbek Latin / Russian / English), keyed by [Lang].
class Masala {
  const Masala(this.title, this.answer);

  /// The raised issue, as worded in the source analysis.
  final Map<Lang, String> title;

  /// Legal basis and the answer the organisation is required to give.
  final Map<Lang, String> answer;
}

/// A subject citizens appeal about, with the issues most often raised under
/// it.
///
/// Each entry corresponds to exactly one organisation — the body that answers
/// for that subject — but the kiosk names it by the subject rather than by the
/// institution, because a visitor knows their problem, not which ministry owns
/// it. The type keeps its original name so the section's code stays one
/// vocabulary; only what the visitor reads changed.
class Tashkilot {
  const Tashkilot(this.name, this.icon, this.masalalar);

  final Map<Lang, String> name;
  final IconData icon;
  final List<Masala> masalalar;
}

/// The subjects citizens of the Tashkent region appeal about most, the issues
/// raised under each and the legally required answers, from the People's
/// Reception analysis for the first half of 2026.
///
/// The source document is in Uzbek Cyrillic; the Uzbek wording is preserved
/// unchanged and transliterated into the Uzbek Latin alphabet used across
/// the kiosk, with faithful Russian and English translations added. Appeal
/// volumes and resolution percentages from the source are deliberately not
/// shown here — the section presents the issues and their legal answers,
/// not statistics.
class MasalalarData {
  const MasalalarData._();

  /// Reporting period, shown under the section title.
  static const Map<Lang, String> period = {
    Lang.uz: '2026 yil, birinchi yarim yillik',
    Lang.ru: '2026 год, первое полугодие',
    Lang.en: 'First half of 2026',
  };

  static const List<Tashkilot> tashkilotlar = [
    Tashkilot(
      {
        Lang.uz: "Ijtimoiy himoya va nafaqa masalalari",
        Lang.ru: "Вопросы социальной защиты и пособий",
        Lang.en: "Social protection and allowances",
      },
      Icons.volunteer_activism_outlined,
      [
        Masala(
          {
            Lang.uz: "18 yoshgacha bolalar nafaqasi",
            Lang.ru: "Пособие на детей до 18 лет",
            Lang.en: "Childcare allowance for children under 18",
          },
          {
            Lang.uz:
                "«Oila, onalik va bolalikni davlat tomonidan qo'llab-quvvatlash to'g'risida»gi Qonun hamda Prezidentning «Ijtimoiy himoya yagona reyestri» (PQ-232) talablari asosida fuqaro oilasining daromadi «muhtojlik mezoni»dan oshmasa, nafaqa tayinlanadi. Ariza «Ijtimoiy himoya yagona reyestri» orqali rasmiylashtirilib, rad etilsa — asos yozma ko'rsatilishi va «Ma'muriy tartib-taomillar to'g'risida»gi Qonun 46-moddasiga muvofiq ustidan shikoyat qilish huquqi tushuntirilishi shart.",
            Lang.ru:
                "На основании Закона «О государственной поддержке семьи, материнства и детства» и требований постановления Президента о «Едином реестре социальной защиты» (PQ-232) пособие назначается, если доход семьи гражданина не превышает «критерий нуждаемости». Заявление оформляется через «Единый реестр социальной защиты»; в случае отказа основание должно быть указано письменно, а также разъяснено право на обжалование в соответствии со статьёй 46 Закона «Об административных процедурах».",
            Lang.en:
                "Under the Law \"On State Support of the Family, Motherhood and Childhood\" and the requirements of the Presidential Resolution on the \"Unified Register of Social Protection\" (PQ-232), the allowance is granted if the family's income does not exceed the \"need criterion\". The application is processed through the \"Unified Register of Social Protection\"; if refused, the grounds must be stated in writing and the right to appeal under Article 46 of the Law \"On Administrative Procedures\" must be explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Muhtojlarga bir martalik moddiy yordam",
            Lang.ru: "Единовременная материальная помощь нуждающимся",
            Lang.en: "One-time financial assistance for those in need",
          },
          {
            Lang.uz:
                "«Xotin-qizlar daftari», «Temir daftar» va «Yoshlar daftari» doirasidagi mablag'lar «Mahalla» jamg'armasi/mahalliy byudjetdan ajratiladi. Ariza ko'rilib, komissiya qarori bilan hal etiladi; muhtojlik tasdiqlanmasa, rad asosi va boshqa ijtimoiy yordam turlari (ish bilan ta'minlash, subsidiya) bo'yicha yo'naltirish beriladi.",
            Lang.ru:
                "Средства в рамках «Женской тетради», «Железной тетради» и «Молодёжной тетради» выделяются из фонда «Махалля»/местного бюджета. Заявление рассматривается и решается на основании решения комиссии; если нуждаемость не подтверждается, сообщается основание отказа и даётся направление по другим видам социальной помощи (трудоустройство, субсидия).",
            Lang.en:
                "Funds under the \"Women's Notebook\", \"Iron Notebook\" and \"Youth Notebook\" programmes are allocated from the \"Mahalla\" Fund or the local budget. The application is reviewed and decided by a commission; if need is not confirmed, the grounds for refusal are given together with referral to other types of social assistance (employment, subsidies).",
          },
        ),
        Masala(
          {
            Lang.uz: "«Ijtimoiy himoya yagona reyestri»ga kiritish",
            Lang.ru: "Включение в «Единый реестр социальной защиты»",
            Lang.en: "Inclusion in the \"Unified Register of Social Protection\"",
          },
          {
            Lang.uz:
                "PQ-232 va Vazirlar Mahkamasining tegishli qarori asosida ariza reyestr operatoriga yo'naltirilib, oila a'zolari daromadi va mulkiy holati tekshiriladi. Mezonga mos kelsa — 15 ish kuni ichida kiritiladi; mos kelmasa rad sababi rasmiy xat bilan bildiriladi va qayta ariza berish tartibi tushuntiriladi.",
            Lang.ru:
                "На основании PQ-232 и соответствующего постановления Кабинета Министров заявление направляется оператору реестра, проверяются доходы и имущественное положение членов семьи. При соответствии критерию семья включается в реестр в течение 15 рабочих дней; при несоответствии причина отказа сообщается официальным письмом и разъясняется порядок повторной подачи заявления.",
            Lang.en:
                "Based on PQ-232 and the relevant resolution of the Cabinet of Ministers, the application is forwarded to the register operator, and the income and property status of family members are verified. If the criterion is met, the family is included within 15 working days; otherwise, the reason for refusal is communicated by official letter and the procedure for reapplying is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Nogironlik guruhini o'zgartirish (tiklash)",
            Lang.ru: "Изменение (восстановление) группы инвалидности",
            Lang.en: "Changing (restoring) a disability group",
          },
          {
            Lang.uz:
                "«Nogironligi bo'lgan shaxslarning huquqlari to'g'risida»gi Qonun asosida masala tibbiy-mehnat ekspertizasi (TME) vakolatiga kiradi. Fuqaro TMEga yo'naltiriladi; xulosadan norozi bo'lsa, yuqori turuvchi TME komissiyasiga yoki sudga shikoyat qilish huquqi tushuntiriladi.",
            Lang.ru:
                "На основании Закона «О правах лиц с инвалидностью» вопрос относится к компетенции медико-трудовой экспертизы (МТЭК). Гражданин направляется в МТЭК; при несогласии с заключением разъясняется право обжалования в вышестоящую комиссию МТЭК или в суд.",
            Lang.en:
                "Under the Law \"On the Rights of Persons with Disabilities\", the matter falls within the competence of the medical-labour expert commission (MLEC). The citizen is referred to the MLEC; if they disagree with its conclusion, the right to appeal to a higher MLEC commission or to court is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Davolanish uchun moddiy yordam",
            Lang.ru: "Материальная помощь на лечение",
            Lang.en: "Financial assistance for medical treatment",
          },
          {
            Lang.uz:
                "Ariza tibbiy hujjatlar (xulosa, smeta) bilan ko'rilib, «Saxovat va ko'mak» yoki sog'liqni saqlash yo'nalishidagi mablag'lardan ajratiladi. Ajratib bo'lmasa — bepul/imtiyozli davolash kvotasi, xayriya jamg'armalari va boshqa manbalarga yo'naltirish ko'rsatilishi lozim.",
            Lang.ru:
                "Заявление рассматривается с медицинскими документами (заключение, смета), средства выделяются из фонда «Саховат ва кўмак» или средств по направлению здравоохранения. Если выделение невозможно — должны быть указаны квота на бесплатное/льготное лечение, благотворительные фонды и направление к другим источникам.",
            Lang.en:
                "The application is reviewed together with medical documents (conclusion, cost estimate), and funds are allocated from the \"Sakhovat va Ko'mak\" fund or healthcare-related resources. If allocation is not possible, a quota for free or subsidised treatment, charitable foundations and referral to other sources must be indicated.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Oila va xotin-qizlar masalalari",
        Lang.ru: "Вопросы семьи и женщин",
        Lang.en: "Family and women's issues",
      },
      Icons.diversity_3_outlined,
      [
        Masala(
          {
            Lang.uz: "Xotin-qizlarga bir martalik moddiy yordam",
            Lang.ru: "Единовременная материальная помощь женщинам",
            Lang.en: "One-time financial assistance for women",
          },
          {
            Lang.uz:
                "«Xotin-qizlar daftari» doirasida mahalla va tuman komissiyasi xulosasi asosida ajratiladi. Ariza muhtojlik darajasini aniqlash uchun ko'rilib, ijobiy hal etiladi yoki rad asosi va muqobil yordam turlari yozma bildiriladi.",
            Lang.ru:
                "Выделяется в рамках «Женской тетради» на основании заключения махаллинской и районной комиссии. Заявление рассматривается для определения степени нуждаемости и решается положительно, либо письменно сообщаются основание отказа и альтернативные виды помощи.",
            Lang.en:
                "Allocated under the \"Women's Notebook\" programme based on the conclusion of the mahalla and district commission. The application is reviewed to determine the degree of need and is either approved, or the grounds for refusal and alternative types of assistance are communicated in writing.",
          },
        ),
        Masala(
          {
            Lang.uz: "Xotin-qizlar uy-joylarini ta'mirlash",
            Lang.ru: "Ремонт жилья женщин",
            Lang.en: "Repair of women's housing",
          },
          {
            Lang.uz:
                "Prezidentning xotin-qizlarni qo'llab-quvvatlash dasturlari asosida «Xotin-qizlar daftari»dagi muhtoj ayollar uyini ta'mirlash mablag'i ajratiladi. Mahalla ko'rigi dalolatnomasi bilan navbat belgilanadi; mablag' yetishmasa — navbat va muddat rasmiy ko'rsatilishi shart.",
            Lang.ru:
                "На основании президентских программ поддержки женщин выделяются средства на ремонт жилья нуждающихся женщин, включённых в «Женскую тетрадь». Очередь определяется по акту осмотра махалли; при нехватке средств очередь и срок должны быть официально указаны.",
            Lang.en:
                "Under presidential programmes supporting women, funds are allocated to repair the homes of women in need listed in the \"Women's Notebook\". Priority is set based on the mahalla inspection report; if funds are insufficient, the place in the queue and the timeframe must be officially stated.",
          },
        ),
        Masala(
          {
            Lang.uz: "«Ayollar daftari»ga kiritish va yordam",
            Lang.ru: "Включение в «Женскую тетрадь» и помощь",
            Lang.en: "Inclusion in the \"Women's Notebook\" and assistance",
          },
          {
            Lang.uz:
                "Daftarga kiritish mezonlari VM qarori bilan belgilangan. Ariza mahalla faoli/komissiya tomonidan o'rganilib, mezonga mos kelsa kiritiladi. Rad etilsa — sabab va qayta murojaat tartibi «Ma'muriy tartib-taomillar to'g'risida»gi Qonunga ko'ra tushuntiriladi.",
            Lang.ru:
                "Критерии включения в тетрадь установлены постановлением Кабинета Министров. Заявление изучается активом махалли/комиссией; при соответствии критериям заявительница включается в тетрадь. В случае отказа причина и порядок повторного обращения разъясняются в соответствии с Законом «Об административных процедурах».",
            Lang.en:
                "The criteria for inclusion in the notebook are set by a resolution of the Cabinet of Ministers. The application is studied by the mahalla activists/commission and, if the criteria are met, the applicant is included. In case of refusal, the reason and the procedure for reapplying are explained in accordance with the Law \"On Administrative Procedures\".",
          },
        ),
        Masala(
          {
            Lang.uz: "Uy-joyga muhtoj xotin-qizlarni ta'minlash",
            Lang.ru: "Обеспечение жильём нуждающихся женщин",
            Lang.en: "Providing housing for women in need",
          },
          {
            Lang.uz:
                "«Aholini uy-joy bilan ta'minlash» dasturlari va ijtimoiy ijara mexanizmi asosida ko'riladi. Muhtojlik tasdiqlansa, ipoteka subsidiyasi yoki ijtimoiy uy-joy navbatiga qo'yiladi; shartlarga mos kelmasa, muqobil imkoniyatlar ko'rsatiladi.",
            Lang.ru:
                "Рассматривается на основании программ «Обеспечение населения жильём» и механизма социальной аренды. При подтверждении нуждаемости предоставляется ипотечная субсидия либо постановка в очередь на социальное жильё; при несоответствии условиям указываются альтернативные возможности.",
            Lang.en:
                "Considered under the \"Providing the Population with Housing\" programmes and the social rental mechanism. If need is confirmed, a mortgage subsidy is granted or the applicant is placed on the social housing waiting list; if the conditions are not met, alternative options are indicated.",
          },
        ),
        Masala(
          {
            Lang.uz: "Oilaviy nizolar va kelishmovchiliklar",
            Lang.ru: "Семейные споры и разногласия",
            Lang.en: "Family disputes and disagreements",
          },
          {
            Lang.uz:
                "«Oilani mustahkamlash» va xotin-qizlarni himoya qilish mexanizmi doirasida psixolog, huquqshunos va muruvvat xodimi jalb etilib, yarashuv ishlari olib boriladi. Zo'ravonlik belgilari bo'lsa — «Xotin-qizlarni tazyiq va zo'ravonlikdan himoya qilish to'g'risida»gi Qonun asosida himoya orderi rasmiylashtirilib, IIBga yo'naltiriladi.",
            Lang.ru:
                "В рамках механизма «Укрепление семьи» и защиты женщин привлекаются психолог, юрист и социальный работник, проводится примирительная работа. При признаках насилия — на основании Закона «О защите женщин от притеснения и насилия» оформляется охранный ордер и материалы направляются в органы внутренних дел.",
            Lang.en:
                "Within the \"Strengthening the Family\" mechanism and the system for protecting women, a psychologist, a lawyer and a social worker are engaged and reconciliation work is carried out. If there are signs of violence, a protection order is issued under the Law \"On the Protection of Women from Harassment and Violence\" and the case is referred to the internal affairs bodies.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Tadbirkorlik, bank va kredit masalalari",
        Lang.ru: "Вопросы предпринимательства, банков и кредитов",
        Lang.en: "Business, banking and credit",
      },
      Icons.account_balance_outlined,
      [
        Masala(
          {
            Lang.uz: "Kredit to'lovi va penyaning noto'g'ri hisoblanishi",
            Lang.ru: "Неправильное начисление платежей по кредиту и пени",
            Lang.en: "Incorrect calculation of loan payments and penalties",
          },
          {
            Lang.uz:
                "«Banklar va bank faoliyati to'g'risida»gi hamda «Iste'mol krediti to'g'risida»gi Qonunlar asosida bank kredit shartnomasi va to'lov grafigini qayta tekshirishga majbur. Xatolik tasdiqlansa — qayta hisob-kitob qilinib, ortiqcha undirilgan penya qaytariladi; bank rad etsa, Markaziy bank nazorat tartibida ko'radi.",
            Lang.ru:
                "На основании законов «О банках и банковской деятельности» и «О потребительском кредите» банк обязан перепроверить кредитный договор и график платежей. При подтверждении ошибки производится перерасчёт и излишне взысканная пеня возвращается; если банк отказывает, Центральный банк рассматривает вопрос в порядке надзора.",
            Lang.en:
                "Under the Laws \"On Banks and Banking Activities\" and \"On Consumer Credit\", the bank is obliged to re-examine the loan agreement and payment schedule. If an error is confirmed, a recalculation is made and any excess penalty collected is refunded; if the bank refuses, the Central Bank reviews the matter through its supervisory procedure.",
          },
        ),
        Masala(
          {
            Lang.uz: "Kredit foizini tushirish yoki muddatini uzaytirish",
            Lang.ru: "Снижение процентной ставки или продление срока кредита",
            Lang.en: "Reducing the loan interest rate or extending the loan term",
          },
          {
            Lang.uz:
                "Foiz va muddat taraflarning kelishuvi asosida (FK 363-368-moddalari, shartnoma erkinligi) o'zgartiriladi. Qarzdorning moliyaviy ahvoli yomonlashsa, bank restrukturizatsiya imkonini ko'rib chiqishi tavsiya etiladi; biroq bir tomonlama majburlab pasaytirish talab qilib bo'lmasligi tushuntiriladi.",
            Lang.ru:
                "Процентная ставка и срок изменяются по соглашению сторон (статьи 363–368 ГК, свобода договора). При ухудшении финансового положения заёмщика банку рекомендуется рассмотреть возможность реструктуризации; однако разъясняется, что требовать одностороннего принудительного снижения нельзя.",
            Lang.en:
                "The interest rate and term may be changed by agreement of the parties (Articles 363–368 of the Civil Code, freedom of contract). If the borrower's financial situation worsens, the bank is advised to consider restructuring; however, it is explained that a unilateral forced reduction cannot be demanded.",
          },
        ),
        Masala(
          {
            Lang.uz: "Bank kartasini ochish, bloklash yoki almashtirish",
            Lang.ru: "Открытие, блокировка или замена банковской карты",
            Lang.en: "Opening, blocking or replacing a bank card",
          },
          {
            Lang.uz:
                "«To'lov va to'lov tizimlari to'g'risida»gi Qonun va MB yo'riqnomalari asosida karta operatsiyalari amalga oshiriladi. Shubhali operatsiya yoki sud/ijro qarori bo'lmasa, kartani asossiz bloklash mumkin emas; bloklansa — sababi yozma bildirilib, yechimi muddati ko'rsatiladi.",
            Lang.ru:
                "Карточные операции осуществляются на основании Закона «О платежах и платёжных системах» и инструкций Центрального банка. Без подозрительной операции либо решения суда/исполнительного органа необоснованная блокировка карты недопустима; при блокировке причина сообщается письменно с указанием срока решения вопроса.",
            Lang.en:
                "Card operations are governed by the Law \"On Payments and Payment Systems\" and Central Bank regulations. A card may not be blocked without grounds unless there is a suspicious transaction or a court/enforcement decision; if blocked, the reason must be communicated in writing together with the timeframe for resolution.",
          },
        ),
        Masala(
          {
            Lang.uz: "Kredit to'lovini kartadan ushlab qolish",
            Lang.ru: "Удержание кредитных платежей с карты",
            Lang.en: "Withholding loan payments from a card",
          },
          {
            Lang.uz:
                "Ushlab qolish faqat shartnomada aktseptsiz undiruv sharti yoki sud/ijro hujjati bo'lganda qonuniy. Aliment, nafaqa kabi ijtimoiy to'lovlarni ushlash FPK va ijro qonunchiligi bilan cheklangan; qonunsiz ushlangan mablag' qaytarilishi lozim.",
            Lang.ru:
                "Удержание законно только при наличии в договоре условия о безакцептном списании либо судебного/исполнительного документа. Удержание социальных выплат, таких как алименты и пособия, ограничено ГПК и законодательством об исполнении; незаконно удержанные средства подлежат возврату.",
            Lang.en:
                "Withholding is lawful only where the agreement provides for direct debit without acceptance or where there is a court/enforcement document. Withholding social payments such as alimony and allowances is restricted by the Civil Procedure Code and enforcement legislation; unlawfully withheld funds must be returned.",
          },
        ),
        Masala(
          {
            Lang.uz: "Bank xodimi xatti-harakatlari",
            Lang.ru: "Действия сотрудников банка",
            Lang.en: "Conduct of bank employees",
          },
          {
            Lang.uz:
                "Xodim odob-axloq qoidalari va xizmat ko'rsatish standartlarini buzsa, bankning ichki xizmat tekshiruvi o'tkazilib, natija arizachiga bildiriladi. Huquqbuzarlik bo'lsa — intizomiy chora ko'rilib, zarur holda MB va huquq-tartibot organlariga material yuboriladi.",
            Lang.ru:
                "Если сотрудник нарушает правила этики и стандарты обслуживания, проводится внутренняя служебная проверка банка, результат сообщается заявителю. При правонарушении принимаются дисциплинарные меры, при необходимости материалы направляются в Центральный банк и правоохранительные органы.",
            Lang.en:
                "If an employee violates the code of conduct or service standards, the bank conducts an internal review and informs the applicant of the outcome. In case of an offence, disciplinary measures are taken and, where necessary, materials are sent to the Central Bank and law enforcement agencies.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Surishtiruv, tergov va huquqbuzarlikka oid masalalar",
        Lang.ru: "Вопросы дознания, следствия и правонарушений",
        Lang.en: "Inquiry, investigation and offences",
      },
      Icons.gavel_outlined,
      [
        Masala(
          {
            Lang.uz: "Surishtiruv va tergov harakatlariga oid masalalar",
            Lang.ru: "Вопросы, связанные с дознанием и следственными действиями",
            Lang.en: "Issues related to inquiry and investigative actions",
          },
          {
            Lang.uz:
                "«Prokuratura to'g'risida»gi Qonun va JPK asosida prokuror surishtiruv/tergov qonuniyligini nazorat qiladi. Murojaat tekshirilib, protsessual qaror ustidan JPK 336-338-moddalariga ko'ra shikoyat ko'riladi; qonunbuzarlik aniqlansa — qaror bekor qilinib, ko'rsatma beriladi.",
            Lang.ru:
                "На основании Закона «О прокуратуре» и УПК прокурор осуществляет надзор за законностью дознания/следствия. Обращение проверяется, жалоба на процессуальное решение рассматривается в соответствии со статьями 336–338 УПК; при выявлении нарушения закона решение отменяется и даётся указание.",
            Lang.en:
                "Under the Law \"On the Prosecutor's Office\" and the Criminal Procedure Code, the prosecutor supervises the legality of inquiry and investigation. The appeal is examined, and complaints against procedural decisions are considered under Articles 336–338 of the CPC; if a violation of the law is found, the decision is annulled and instructions are issued.",
          },
        ),
        Masala(
          {
            Lang.uz: "Sodir etilgan huquqbuzarlikka oid masalalar",
            Lang.ru: "Вопросы, связанные с совершёнными правонарушениями",
            Lang.en: "Issues related to committed offences",
          },
          {
            Lang.uz:
                "Ariza vakolatli organga (IIB, soliq, nazorat idorasi) yuzasidan tekshiruv uchun yo'naltiriladi yoki prokuratura to'g'ridan-to'g'ri tekshiruv tashkil etadi. Jinoyat/ma'muriy buzilish belgilari bo'lsa — tegishli ish qo'zg'atilib, natija «Jismoniy va yuridik shaxslarning murojaatlari to'g'risida»gi Qonun muddatlarida bildiriladi.",
            Lang.ru:
                "Заявление направляется для проверки в уполномоченный орган (ОВД, налоговые, контрольные органы) либо прокуратура организует проверку непосредственно. При признаках преступления/административного правонарушения возбуждается соответствующее дело, результат сообщается в сроки, установленные Законом «Об обращениях физических и юридических лиц».",
            Lang.en:
                "The application is forwarded for verification to the competent body (internal affairs, tax or supervisory authority), or the prosecutor's office arranges the inspection directly. If there are signs of a crime or administrative offence, the appropriate proceedings are initiated and the result is communicated within the time limits set by the Law \"On Appeals of Individuals and Legal Entities\".",
          },
        ),
        Masala(
          {
            Lang.uz: "Jinoyatlarga (firibgarlikka) oid xabarlar",
            Lang.ru: "Сообщения о преступлениях (мошенничестве)",
            Lang.en: "Reports of crimes (fraud)",
          },
          {
            Lang.uz:
                "JK 168-moddasi (firibgarlik) belgilari bo'yicha xabar JPK 329-330-moddalariga ko'ra ro'yxatga olinib, dosledstven tekshir o'tkaziladi. Asos bo'lsa jinoyat ishi qo'zg'atiladi; bo'lmasa — rad qarori chiqarilib, ustidan shikoyat huquqi tushuntiriladi.",
            Lang.ru:
                "Сообщение по признакам статьи 168 УК (мошенничество) регистрируется в соответствии со статьями 329–330 УПК, проводится доследственная проверка. При наличии оснований возбуждается уголовное дело; при их отсутствии выносится постановление об отказе и разъясняется право его обжалования.",
            Lang.en:
                "A report showing signs of Article 168 of the Criminal Code (fraud) is registered under Articles 329–330 of the CPC and a pre-investigation check is carried out. If grounds exist, a criminal case is opened; otherwise a refusal decision is issued and the right to appeal it is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Shartnoma shartlari bajarilmaganligi",
            Lang.ru: "Неисполнение условий договора",
            Lang.en: "Failure to fulfil contract terms",
          },
          {
            Lang.uz:
                "Bu fuqarolik-huquqiy nizo bo'lib, asosan sud vakolatiga kiradi (FK 234, 324-moddalari). Arizachiga da'vo tartibida sudga murojaat qilish tushuntiriladi; firibgarlik belgilari bo'lsa — prokuratura jinoiy-huquqiy baho beradi.",
            Lang.ru:
                "Это гражданско-правовой спор, относящийся в основном к компетенции суда (статьи 234, 324 ГК). Заявителю разъясняется порядок обращения в суд в исковом порядке; при признаках мошенничества прокуратура даёт уголовно-правовую оценку.",
            Lang.en:
                "This is a civil-law dispute that mainly falls within the competence of the courts (Articles 234 and 324 of the Civil Code). The applicant is advised to file a claim in court; if there are signs of fraud, the prosecutor's office gives a criminal-law assessment.",
          },
        ),
        Masala(
          {
            Lang.uz: "Bosh prokuror (o'rinbosari) qabuli so'rovi",
            Lang.ru: "Запрос на приём к Генеральному прокурору (заместителю)",
            Lang.en: "Request for an appointment with the Prosecutor General (deputy)",
          },
          {
            Lang.uz:
                "«Jismoniy va yuridik shaxslarning murojaatlari to'g'risida»gi Qonun 26-moddasi asosida shaxsiy qabul jadval bo'yicha tashkil etiladi. Masala avval quyi bo'g'inda ko'rilishi, hal bo'lmasa yuqoriga yo'naltirilishi tartibi tushuntiriladi.",
            Lang.ru:
                "На основании статьи 26 Закона «Об обращениях физических и юридических лиц» личный приём организуется по графику. Разъясняется порядок: вопрос сначала рассматривается в нижестоящем звене, а при нерешении направляется выше.",
            Lang.en:
                "Under Article 26 of the Law \"On Appeals of Individuals and Legal Entities\", personal reception is organised according to a schedule. It is explained that the issue must first be considered at the lower level and, if unresolved, referred upwards.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Elektr ta'minoti masalalari",
        Lang.ru: "Вопросы электроснабжения",
        Lang.en: "Electricity supply",
      },
      Icons.bolt_outlined,
      [
        Masala(
          {
            Lang.uz: "Elektr ta'minotidagi uzilishlar",
            Lang.ru: "Перебои в электроснабжении",
            Lang.en: "Power supply interruptions",
          },
          {
            Lang.uz:
                "«Elektr energetikasi to'g'risida»gi Qonun va VM «Elektr energiyasidan foydalanish qoidalari» asosida ta'minlovchi uzluksiz ta'minlashga majbur. Ariza bo'yicha uzilish sababi (avariya, rejali ishlar, tarmoq eskirishi) aniqlanib, tiklash muddati ko'rsatiladi; ta'minlovchi aybi bilan zarar yetsa — qoplash talab qilish huquqi bor.",
            Lang.ru:
                "На основании Закона «Об электроэнергетике» и утверждённых Кабинетом Министров «Правил пользования электрической энергией» поставщик обязан обеспечивать бесперебойное снабжение. По заявлению устанавливается причина отключения (авария, плановые работы, износ сети) и указывается срок восстановления; если ущерб причинён по вине поставщика, есть право требовать его возмещения.",
            Lang.en:
                "Under the Law \"On Electric Power\" and the Cabinet of Ministers' \"Rules for the Use of Electric Energy\", the supplier is obliged to provide uninterrupted supply. Upon application, the cause of the outage (accident, planned works, network wear) is determined and the restoration deadline is indicated; if damage is caused through the supplier's fault, compensation may be claimed.",
          },
        ),
        Masala(
          {
            Lang.uz: "Sim ustun, transformator punkti qurish/ta'mirlash",
            Lang.ru: "Строительство/ремонт опор ЛЭП и трансформаторных пунктов",
            Lang.en: "Construction/repair of power poles and transformer substations",
          },
          {
            Lang.uz:
                "Tarmoqni rivojlantirish va ta'mirlash investitsiya dasturi asosida navbat bilan amalga oshiriladi. Ariza «Hududiy elektr tarmoqlari» filialiga yo'naltirilib, texnik ko'rik natijasiga ko'ra ish rejasi va muddati belgilanadi.",
            Lang.ru:
                "Осуществляется поэтапно в рамках инвестиционной программы развития и ремонта сетей. Заявление направляется в филиал «Территориальных электрических сетей», по результатам технического осмотра определяются план работ и сроки.",
            Lang.en:
                "Carried out in stages under the investment programme for network development and repair. The application is forwarded to the \"Regional Electric Networks\" branch; based on a technical inspection, a work plan and timeframe are set.",
          },
        ),
        Masala(
          {
            Lang.uz: "Elektr kuchlanishining pastligi",
            Lang.ru: "Низкое напряжение в электросети",
            Lang.en: "Low voltage in the electricity network",
          },
          {
            Lang.uz:
                "Qoidalarga ko'ra kuchlanish belgilangan me'yor (standart) doirasida bo'lishi shart. O'lchov o'tkazilib, nome'yoriy bo'lsa — transformator quvvati oshirish yoki tarmoqni muvozanatlash choralari ko'riladi; muddati arizachiga bildiriladi.",
            Lang.ru:
                "Согласно правилам напряжение должно находиться в пределах установленной нормы (стандарта). Проводятся замеры; если напряжение вне нормы, принимаются меры по увеличению мощности трансформатора или балансировке сети; срок сообщается заявителю.",
            Lang.en:
                "Under the rules, voltage must remain within the established standard. Measurements are taken; if the voltage is out of range, measures are taken to increase transformer capacity or balance the network, and the deadline is communicated to the applicant.",
          },
        ),
        Masala(
          {
            Lang.uz: "Elektr hisoblagichi nosozliklari, plombalash",
            Lang.ru: "Неисправности электросчётчика, опломбирование",
            Lang.en: "Electricity meter faults and sealing",
          },
          {
            Lang.uz:
                "Hisoblagichni o'rnatish, tekshirish va plombalash ta'minlovchi zimmasida. Ariza bo'yicha nosoz hisoblagich tekshiruvga olinib, metrologiya talablariga mos ravishda almashtiriladi; noto'g'ri hisoblangan iste'mol qayta hisob-kitob qilinadi.",
            Lang.ru:
                "Установка, проверка и опломбирование счётчика — обязанность поставщика. По заявлению неисправный счётчик принимается на проверку и заменяется в соответствии с метрологическими требованиями; неверно начисленное потребление пересчитывается.",
            Lang.en:
                "Installing, checking and sealing the meter is the supplier's responsibility. Upon application, a faulty meter is taken for inspection and replaced in line with metrology requirements; incorrectly calculated consumption is recalculated.",
          },
        ),
        Masala(
          {
            Lang.uz: "Elektr energiyasi to'lovlari va qarzdorlik",
            Lang.ru: "Платежи за электроэнергию и задолженность",
            Lang.en: "Electricity payments and arrears",
          },
          {
            Lang.uz:
                "To'lov tarif va hisoblagich ko'rsatkichi asosida undiriladi. Arizachi bilan solishtirma dalolatnoma tuzilib, xatolik bo'lsa qayta hisoblanadi; qarzdorlik tasdiqlansa — bo'lib to'lash imkoniyati taklif etilishi mumkin, uzib qo'yish esa belgilangan tartibda ogohlantirish bilangina amalga oshiriladi.",
            Lang.ru:
                "Оплата взимается на основании тарифа и показаний счётчика. С заявителем составляется сверочный акт, при ошибке производится перерасчёт; если задолженность подтверждается, может быть предложена рассрочка, а отключение производится только в установленном порядке и с предупреждением.",
            Lang.en:
                "Payment is charged based on the tariff and meter readings. A reconciliation report is drawn up with the applicant, and errors are recalculated; if arrears are confirmed, instalment payment may be offered, while disconnection is carried out only in the prescribed manner and with prior warning.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Aholini gaz bilan ta'minlash masalalari",
        Lang.ru: "Вопросы газоснабжения населения",
        Lang.en: "Gas supply to the population",
      },
      Icons.local_fire_department_outlined,
      [
        Masala(
          {
            Lang.uz: "Tabiiy gaz hisoblagichdagi nosozliklar",
            Lang.ru: "Неисправности счётчика природного газа",
            Lang.en: "Natural gas meter faults",
          },
          {
            Lang.uz:
                "«Gaz ta'minoti to'g'risida»gi Qonun va VM «Tabiiy gazdan foydalanish qoidalari» asosida hisoblagichni o'rnatish, yechish va plombalash ta'minlovchi vakolatida. Ariza bo'yicha xodim chiqib, hisoblagich tekshiruvi va almashtirish belgilangan muddatda amalga oshiriladi.",
            Lang.ru:
                "На основании Закона «О газоснабжении» и утверждённых Кабинетом Министров «Правил пользования природным газом» установка, снятие и опломбирование счётчика относятся к полномочиям поставщика. По заявлению выезжает сотрудник, проверка и замена счётчика выполняются в установленный срок.",
            Lang.en:
                "Under the Law \"On Gas Supply\" and the Cabinet of Ministers' \"Rules for the Use of Natural Gas\", installing, removing and sealing the meter is the supplier's responsibility. Upon application, a technician is dispatched, and the meter inspection and replacement are carried out within the set timeframe.",
          },
        ),
        Masala(
          {
            Lang.uz: "Tabiiy gaz to'lovlari va qarzdorlik",
            Lang.ru: "Платежи за природный газ и задолженность",
            Lang.en: "Natural gas payments and arrears",
          },
          {
            Lang.uz:
                "To'lov hisoblagich yoki norma bo'yicha undiriladi. Solishtirma dalolatnoma orqali tafovut aniqlanib, xatolik qayta hisoblanadi; qarzdorlik bo'lsa, bo'lib-bo'lib to'lash va imtiyozli qatlam uchun subsidiya imkoniyati tushuntiriladi.",
            Lang.ru:
                "Оплата взимается по счётчику или нормативу. Расхождение выявляется через сверочный акт, ошибка пересчитывается; при наличии задолженности разъясняются возможность рассрочки и субсидии для льготных категорий.",
            Lang.en:
                "Payment is charged based on the meter or the standard norm. Discrepancies are identified through a reconciliation report and errors are recalculated; in case of arrears, instalment payment options and subsidies for eligible categories are explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Gaz bosimi va ta'minotidagi muammolar",
            Lang.ru: "Проблемы с давлением газа и газоснабжением",
            Lang.en: "Gas pressure and supply problems",
          },
          {
            Lang.uz:
                "Qoidalarga ko'ra gaz uzluksiz va me'yoriy bosimda yetkazilishi shart. Ariza bo'yicha tarmoq diagnostikasi o'tkazilib, past bosim sababi (tarmoq eskirishi, yuklanish) bartaraf etiladi; muddat va reja arizachiga bildiriladi.",
            Lang.ru:
                "Согласно правилам газ должен подаваться бесперебойно и с нормативным давлением. По заявлению проводится диагностика сети, устраняется причина низкого давления (износ сети, нагрузка); срок и план сообщаются заявителю.",
            Lang.en:
                "Under the rules, gas must be supplied continuously and at standard pressure. Upon application, network diagnostics are carried out and the cause of low pressure (network wear, overload) is eliminated; the timeframe and plan are communicated to the applicant.",
          },
        ),
        Masala(
          {
            Lang.uz: "Turar joyni gaz tarmog'iga ulash va hisob ochish",
            Lang.ru: "Подключение жилья к газовой сети и открытие лицевого счёта",
            Lang.en: "Connecting a home to the gas network and opening an account",
          },
          {
            Lang.uz:
                "Ulash texnik shartlar va loyiha asosida, «davlat xizmatlari» tartibida amalga oshiriladi. Ariza bo'yicha texnik imkoniyat tekshirilib, shartlar beriladi; rad etilsa — texnik asos yozma ko'rsatilib, muqobil yechim taklif etiladi.",
            Lang.ru:
                "Подключение осуществляется на основании технических условий и проекта в порядке «государственных услуг». По заявлению проверяется техническая возможность и выдаются условия; при отказе техническое основание указывается письменно и предлагается альтернативное решение.",
            Lang.en:
                "Connection is carried out based on technical conditions and a design, through the \"public services\" procedure. Upon application, technical feasibility is checked and conditions are issued; if refused, the technical grounds are stated in writing and an alternative solution is proposed.",
          },
        ),
        Masala(
          {
            Lang.uz: "Gaz ballonni to'ldirish va almashtirish",
            Lang.ru: "Заправка и замена газовых баллонов",
            Lang.en: "Filling and replacing gas cylinders",
          },
          {
            Lang.uz:
                "Ballon gaz xavfsizlik talablari asosida vakolatli punktlarda to'ldiriladi. Ariza bo'yicha xizmat ko'rsatish nuqtasi, navbat va xavfsizlik qoidalari tushuntirilib, uzilish bo'lsa ta'minot tiklash chorasi ko'riladi.",
            Lang.ru:
                "Баллоны заправляются в уполномоченных пунктах с соблюдением требований газовой безопасности. По заявлению разъясняются пункт обслуживания, очередь и правила безопасности; при перебоях принимаются меры по восстановлению снабжения.",
            Lang.en:
                "Cylinders are filled at authorised points in compliance with gas safety requirements. Upon application, the service point, queue and safety rules are explained; in case of interruption, measures are taken to restore supply.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Huquqbuzarlik va jinoyatchilik profilaktikasi masalalari",
        Lang.ru: "Вопросы профилактики правонарушений и преступности",
        Lang.en: "Prevention of offences and crime",
      },
      Icons.local_police_outlined,
      [
        Masala(
          {
            Lang.uz: "Sodir etilgan huquqbuzarlikka oid masalalar",
            Lang.ru: "Вопросы, связанные с совершёнными правонарушениями",
            Lang.en: "Issues related to committed offences",
          },
          {
            Lang.uz:
                "«Ichki ishlar organlari to'g'risida»gi Qonun va MJtK asosida ariza ro'yxatga olinib tekshiriladi. Ma'muriy buzilish belgisi bo'lsa — dalolatnoma tuzilib ish ko'riladi; jinoyat belgisi bo'lsa JPK tartibida tekshiruv boshlanadi. Natija qonuniy muddatda bildiriladi.",
            Lang.ru:
                "На основании Закона «Об органах внутренних дел» и КоАО заявление регистрируется и проверяется. При признаках административного правонарушения составляется протокол и дело рассматривается; при признаках преступления начинается проверка в порядке УПК. Результат сообщается в законный срок.",
            Lang.en:
                "Under the Law \"On Internal Affairs Bodies\" and the Code of Administrative Liability, the application is registered and verified. If signs of an administrative offence are found, a report is drawn up and the case is considered; if signs of a crime are found, a check under the Criminal Procedure Code begins. The result is communicated within the legal deadline.",
          },
        ),
        Masala(
          {
            Lang.uz: "Jinoyatlarga, firibgarlikka oid xabarlar",
            Lang.ru: "Сообщения о преступлениях и мошенничестве",
            Lang.en: "Reports of crimes and fraud",
          },
          {
            Lang.uz:
                "Xabar JPK 329-330-moddalariga ko'ra YaXD jurnaliga qayd etilib, dosledstven tekshir o'tkaziladi. Asos bo'lsa jinoyat ishi qo'zg'atiladi; rad etilsa, qaror ustidan prokuror va sudga shikoyat qilish huquqi tushuntiriladi.",
            Lang.ru:
                "Сообщение регистрируется в журнале единого учёта (YaXD) в соответствии со статьями 329–330 УПК, проводится доследственная проверка. При наличии оснований возбуждается уголовное дело; при отказе разъясняется право обжаловать постановление прокурору и в суд.",
            Lang.en:
                "The report is entered in the unified register of reports (YaXD) under Articles 329–330 of the CPC, and a pre-investigation check is carried out. If grounds exist, a criminal case is opened; if refused, the right to appeal the decision to the prosecutor or the court is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Surishtiruv va tergov harakatlariga oid masalalar",
            Lang.ru: "Вопросы, связанные с дознанием и следственными действиями",
            Lang.en: "Issues related to inquiry and investigative actions",
          },
          {
            Lang.uz:
                "Protsessual harakatlar qonuniyligi JPK bilan tartibga solinadi. Norozilik bo'yicha material tekshirilib, harakat/qaror ustidan shikoyat ko'riladi; qonunbuzarlik aniqlansa, bartaraf etilib, arizachiga javob beriladi.",
            Lang.ru:
                "Законность процессуальных действий регулируется УПК. По жалобе материал проверяется, рассматривается жалоба на действие/решение; при выявлении нарушения закона оно устраняется и заявителю даётся ответ.",
            Lang.en:
                "The legality of procedural actions is governed by the Criminal Procedure Code. The material is reviewed upon complaint, and the complaint against an action or decision is considered; if a violation of the law is found, it is remedied and the applicant is given a response.",
          },
        ),
        Masala(
          {
            Lang.uz: "Mol-mulk va pul mablag'larini qaytarmaslik",
            Lang.ru: "Невозврат имущества и денежных средств",
            Lang.en: "Failure to return property and money",
          },
          {
            Lang.uz:
                "Bu asosan fuqarolik-huquqiy nizo; arizachiga da'vo tartibida sudga murojaat qilish tushuntiriladi. Ammo aldash, ishonch suiiste'moli (firibgarlik, JK 168-modda) belgilari bo'lsa — IIB jinoiy-huquqiy tekshiruv o'tkazadi.",
            Lang.ru:
                "Это в основном гражданско-правовой спор; заявителю разъясняется порядок обращения в суд в исковом порядке. Однако при признаках обмана, злоупотребления доверием (мошенничество, статья 168 УК) органы внутренних дел проводят уголовно-правовую проверку.",
            Lang.en:
                "This is mainly a civil-law dispute; the applicant is advised to file a claim in court. However, if there are signs of deception or abuse of trust (fraud, Article 168 of the Criminal Code), the internal affairs bodies conduct a criminal-law investigation.",
          },
        ),
        Masala(
          {
            Lang.uz: "ID karta, pasport, fuqarolik masalalari",
            Lang.ru: "Вопросы ID-карты, паспорта и гражданства",
            Lang.en: "ID card, passport and citizenship issues",
          },
          {
            Lang.uz:
                "«Aholi davlat ro'yxati» va VM hujjatlashtirish qoidalari asosida davlat xizmati tartibida hal etiladi. Ariza bo'yicha hujjat tayyorlash muddati, zarur hujjatlar ro'yxati ko'rsatilib, rad etilsa asos va bartaraf etish yo'li tushuntiriladi.",
            Lang.ru:
                "Решается в порядке государственной услуги на основании «Государственного реестра населения» и правил документирования Кабинета Министров. По заявлению указываются срок оформления документа и перечень необходимых документов; при отказе разъясняются основание и способ его устранения.",
            Lang.en:
                "Resolved as a public service based on the \"State Register of the Population\" and the Cabinet of Ministers' documentation rules. Upon application, the processing time and the list of required documents are indicated; if refused, the grounds and how to remedy them are explained.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz:
            "Sud hujjatlari, sudya va sud xodimlari xatti-harakatlariga oid masalalar",
        Lang.ru:
            "Вопросы судебных актов и действий судей и работников суда",
        Lang.en:
            "Court decisions and conduct of judges and court staff",
      },
      Icons.balance_outlined,
      [
        Masala(
          {
            Lang.uz: "Fuqarolik sud hujjatlari ustidan norozilik",
            Lang.ru: "Несогласие с судебными актами по гражданским делам",
            Lang.en: "Disagreement with civil court decisions",
          },
          {
            Lang.uz:
                "FPK asosida sud hujjati ustidan apellyatsiya, kassatsiya va nazorat tartibida shikoyat beriladi. Arizachiga tegishli instantsiya, muddat va ariza talablari tushuntiriladi; sudya hujjatini ma'muriy tartibda bekor qilish mumkin emasligi izohlanadi (sud mustaqilligi).",
            Lang.ru:
                "На основании ГПК судебный акт обжалуется в апелляционном, кассационном и надзорном порядке. Заявителю разъясняются соответствующая инстанция, сроки и требования к жалобе; поясняется, что судебный акт нельзя отменить в административном порядке (независимость суда).",
            Lang.en:
                "Under the Civil Procedure Code, court decisions may be appealed through appellate, cassation and supervisory procedures. The applicant is informed of the relevant instance, deadlines and filing requirements; it is explained that a judicial act cannot be annulled administratively (judicial independence).",
          },
        ),
        Masala(
          {
            Lang.uz: "Jinoyat sud hujjatlari ustidan norozilik",
            Lang.ru: "Несогласие с судебными актами по уголовным делам",
            Lang.en: "Disagreement with criminal court decisions",
          },
          {
            Lang.uz:
                "JPK asosida hukm ustidan apellyatsiya/kassatsiya tartibida shikoyat ko'riladi. Arizachiga shikoyat muddati, yuqori sud instantsiyasi va protsessual talablar tushuntirilib, ariza tegishli sudga yo'naltiriladi.",
            Lang.ru:
                "На основании УПК приговор обжалуется в апелляционном/кассационном порядке. Заявителю разъясняются срок обжалования, вышестоящая судебная инстанция и процессуальные требования, жалоба направляется в соответствующий суд.",
            Lang.en:
                "Under the Criminal Procedure Code, a verdict may be appealed through appellate or cassation procedures. The applicant is informed of the appeal deadline, the higher court instance and procedural requirements, and the complaint is forwarded to the appropriate court.",
          },
        ),
        Masala(
          {
            Lang.uz: "Fuqarolik sudidagi ish yuzasidan so'rovlar",
            Lang.ru: "Запросы по делам в гражданском суде",
            Lang.en: "Enquiries about civil court cases",
          },
          {
            Lang.uz:
                "Ish holati, ko'rilish sanasi va hujjat harakati bo'yicha ma'lumot sud devonxonasi orqali beriladi. Ish tarafi bo'lmagan shaxsga protsessual ma'lumot maxfiylik doirasida cheklanganligi tushuntiriladi.",
            Lang.ru:
                "Информация о состоянии дела, дате рассмотрения и движении документов предоставляется через канцелярию суда. Лицу, не являющемуся стороной дела, разъясняется, что процессуальная информация ограничена рамками конфиденциальности.",
            Lang.en:
                "Information on case status, hearing dates and document flow is provided through the court registry. A person who is not a party to the case is informed that procedural information is restricted for confidentiality reasons.",
          },
        ),
        Masala(
          {
            Lang.uz: "Da'vo tartibida murojaat qilish",
            Lang.ru: "Обращение в суд в исковом порядке",
            Lang.en: "Filing a claim in court",
          },
          {
            Lang.uz:
                "FPK talablari asosida da'vo arizasi mazmuni, ilova hujjatlar va davlat boji miqdori tushuntiriladi. Tegishli sudga va podsudlikka ko'ra yo'naltirish ko'rsatiladi; tekin yuridik yordam imkoniyati ham eslatiladi.",
            Lang.ru:
                "На основании требований ГПК разъясняются содержание искового заявления, прилагаемые документы и размер государственной пошлины. Указывается направление в надлежащий суд с учётом подсудности; также напоминается о возможности бесплатной юридической помощи.",
            Lang.en:
                "Based on the requirements of the Civil Procedure Code, the content of the statement of claim, the required attachments and the amount of state duty are explained. Referral to the proper court according to jurisdiction is indicated, and the possibility of free legal aid is also mentioned.",
          },
        ),
        Masala(
          {
            Lang.uz: "Sudyalar va sud xodimlari xatti-harakatlari",
            Lang.ru: "Действия судей и работников суда",
            Lang.en: "Conduct of judges and court staff",
          },
          {
            Lang.uz:
                "Sudya faoliyatiga oid shikoyat Sudyalar oliy kengashi vakolatiga kiradi; sud xodimi bo'yicha shikoyat sud raisi/devonxonasida ko'riladi. Arizachiga tegishli organ va shikoyat tartibi ko'rsatiladi, sud qarori mazmuniga baho bu tartibda berilmasligi izohlanadi.",
            Lang.ru:
                "Жалобы на деятельность судьи относятся к компетенции Высшего судейского совета; жалобы на работников суда рассматриваются председателем суда/канцелярией. Заявителю указываются соответствующий орган и порядок обжалования; поясняется, что оценка существа судебного решения в этом порядке не даётся.",
            Lang.en:
                "Complaints about a judge's activity fall within the competence of the Supreme Judicial Council; complaints about court staff are handled by the court chairman or registry. The applicant is directed to the appropriate body and procedure; it is explained that the substance of a court decision is not assessed through this procedure.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Aliment va ijro hujjatlariga oid masalalar",
        Lang.ru: "Вопросы алиментов и исполнительных документов",
        Lang.en: "Alimony and enforcement documents",
      },
      Icons.receipt_long_outlined,
      [
        Masala(
          {
            Lang.uz: "Aliment undirishga oid masalalar",
            Lang.ru: "Вопросы взыскания алиментов",
            Lang.en: "Alimony collection issues",
          },
          {
            Lang.uz:
                "«Sud hujjatlari va boshqa organlar hujjatlarini ijro etish to'g'risida»gi Qonun va Oila kodeksi asosida aliment ijro hujjati bo'yicha undiriladi. Qarzdor ish haqi/daromadidan ushlanadi; to'lamasa — mol-mulkka qaratish, chiqish cheklovi va JK 122-modda bo'yicha javobgarlik choralari qo'llanadi.",
            Lang.ru:
                "На основании Закона «Об исполнении судебных актов и актов иных органов» и Семейного кодекса алименты взыскиваются по исполнительному документу. Удержание производится из заработной платы/доходов должника; при неуплате применяются обращение взыскания на имущество, ограничение выезда и меры ответственности по статье 122 УК.",
            Lang.en:
                "Under the Law \"On the Enforcement of Judicial Acts and Acts of Other Bodies\" and the Family Code, alimony is collected under an enforcement document. Deductions are made from the debtor's salary/income; in case of non-payment, seizure of property, travel restrictions and liability under Article 122 of the Criminal Code are applied.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ijro hujjatlari bo'yicha qarz undirish",
            Lang.ru: "Взыскание долга по исполнительным документам",
            Lang.en: "Debt collection under enforcement documents",
          },
          {
            Lang.uz:
                "Ijro varaqasi asosida ijrochi qarzdor mol-mulki va daromadini aniqlab, undiruvni qaratadi. Arizachiga ijro ishi holati, ko'rilgan choralar bildirilib, ijrochi harakatsizligi ustidan yuqori bo'g'in va sudga shikoyat huquqi tushuntiriladi.",
            Lang.ru:
                "На основании исполнительного листа исполнитель устанавливает имущество и доходы должника и обращает на них взыскание. Заявителю сообщаются состояние исполнительного производства и принятые меры; разъясняется право обжаловать бездействие исполнителя в вышестоящее звено и в суд.",
            Lang.en:
                "Based on the writ of execution, the enforcement officer identifies the debtor's property and income and levies execution on them. The applicant is informed of the status of the enforcement case and the measures taken; the right to appeal the officer's inaction to a higher authority or the court is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ijro hujjatlari bo'yicha zararni undirish",
            Lang.ru: "Взыскание ущерба по исполнительным документам",
            Lang.en: "Recovery of damages under enforcement documents",
          },
          {
            Lang.uz:
                "Sud hal qiluv qarori asosida yetkazilgan zarar qarzdordan undiriladi. Mol-mulk yetarli bo'lmasa — qidiruv, daromadga qaratish va bo'lib undirish choralari ko'rilib, jarayon arizachiga muntazam bildiriladi.",
            Lang.ru:
                "На основании решения суда причинённый ущерб взыскивается с должника. Если имущества недостаточно — принимаются меры розыска, обращения взыскания на доходы и взыскания частями, о ходе процесса заявитель информируется регулярно.",
            Lang.en:
                "Based on the court judgment, the damages caused are recovered from the debtor. If the property is insufficient, measures such as asset tracing, levying on income and collection in instalments are taken, and the applicant is regularly informed of the progress.",
          },
        ),
        Masala(
          {
            Lang.uz: "Aliment miqdorini qayta hisoblash so'rovlari",
            Lang.ru: "Запросы о перерасчёте размера алиментов",
            Lang.en: "Requests to recalculate alimony amounts",
          },
          {
            Lang.uz:
                "Qayta hisoblash sud qarori yoki qarzdor daromadi o'zgarishiga bog'liq (Oila kodeksi). Ariza bo'yicha ushlanma to'g'riligi tekshirilib, xatolik qayta hisoblanadi; miqdorni o'zgartirish esa sudda ko'rilishi tushuntiriladi.",
            Lang.ru:
                "Перерасчёт зависит от решения суда или изменения доходов должника (Семейный кодекс). По заявлению проверяется правильность удержаний, ошибка пересчитывается; разъясняется, что изменение размера алиментов рассматривается судом.",
            Lang.en:
                "Recalculation depends on a court decision or a change in the debtor's income (Family Code). Upon application, the correctness of deductions is checked and errors are recalculated; it is explained that changing the amount itself is decided by the court.",
          },
        ),
        Masala(
          {
            Lang.uz: "Xodim xatti-harakatlari",
            Lang.ru: "Действия сотрудников",
            Lang.en: "Conduct of officers",
          },
          {
            Lang.uz:
                "Ijrochi harakati/harakatsizligi ustidan yuqori turuvchi ijrochi, byuro boshlig'i yoki sudga shikoyat qilish mumkin. Xizmat tekshiruvi o'tkazilib, qonunbuzarlik bo'lsa intizomiy chora ko'riladi va natija arizachiga bildiriladi.",
            Lang.ru:
                "Действия/бездействие исполнителя можно обжаловать вышестоящему исполнителю, начальнику бюро или в суд. Проводится служебная проверка; при нарушении закона принимаются дисциплинарные меры, результат сообщается заявителю.",
            Lang.en:
                "An enforcement officer's actions or inaction may be appealed to a higher-ranking officer, the head of the bureau or the court. An internal review is conducted; if a violation is found, disciplinary measures are taken and the applicant is informed of the outcome.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Kadastr hujjatlarini rasmiylashtirishga oid masalalar",
        Lang.ru: "Вопросы оформления кадастровых документов",
        Lang.en: "Processing of cadastre documents",
      },
      Icons.map_outlined,
      [
        Masala(
          {
            Lang.uz: "Kadastr hujjatlarini rasmiylashtirish",
            Lang.ru: "Оформление кадастровых документов",
            Lang.en: "Processing cadastral documents",
          },
          {
            Lang.uz:
                "«Davlat kadastrlari to'g'risida»gi Qonun va VM qoidalari asosida kadastr hujjati davlat xizmati tartibida rasmiylashtiriladi. Ariza bo'yicha zarur hujjatlar, muddat va yig'im ko'rsatilib, kechiktirilsa sabab aniqlanib bartaraf etiladi.",
            Lang.ru:
                "На основании Закона «О государственных кадастрах» и правил Кабинета Министров кадастровый документ оформляется в порядке государственной услуги. По заявлению указываются необходимые документы, сроки и сбор; при задержке причина выясняется и устраняется.",
            Lang.en:
                "Under the Law \"On State Cadastres\" and Cabinet of Ministers rules, cadastral documents are processed as a public service. Upon application, the required documents, deadlines and fees are indicated; in case of delay, the cause is identified and eliminated.",
          },
        ),
        Masala(
          {
            Lang.uz: "Kadastr ma'lumotlar bazasi bilan bog'liq holatlar",
            Lang.ru: "Ситуации, связанные с базой кадастровых данных",
            Lang.en: "Issues with the cadastral database",
          },
          {
            Lang.uz:
                "Baza ma'lumotidagi xatolik (maydon, egalik, manzil) texnik tuzatish tartibida to'g'rilanadi. Ariza bo'yicha asl hujjatlar bilan solishtirilib, xatolik tasdiqlansa tuzatiladi; tortishuv bo'lsa sudda ko'rish tushuntiriladi.",
            Lang.ru:
                "Ошибка в данных базы (площадь, право собственности, адрес) исправляется в порядке технической корректировки. По заявлению данные сверяются с подлинными документами, при подтверждении ошибки она исправляется; при споре разъясняется порядок рассмотрения в суде.",
            Lang.en:
                "Errors in the database (area, ownership, address) are corrected through a technical correction procedure. Upon application, the data are checked against the original documents and confirmed errors are corrected; in case of dispute, court proceedings are explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Yer uchastkasini o'zboshimchalik bilan egallab olish",
            Lang.ru: "Самовольный захват земельного участка",
            Lang.en: "Unauthorised occupation of a land plot",
          },
          {
            Lang.uz:
                "MJtK va Yer kodeksi asosida noqonuniy egallash buzilish hisoblanadi. Ariza bo'yicha ko'rik o'tkazilib, fakt tasdiqlansa — egallagan shaxsga nisbatan chora ko'rilib, yer qonuniy egasiga qaytarilishi yoki buzish tartibi qo'llanadi.",
            Lang.ru:
                "На основании КоАО и Земельного кодекса незаконный захват является правонарушением. По заявлению проводится осмотр; при подтверждении факта к захватившему лицу принимаются меры, земля возвращается законному владельцу либо применяется порядок сноса.",
            Lang.en:
                "Under the Code of Administrative Liability and the Land Code, unlawful occupation is an offence. An inspection is carried out upon application; if the fact is confirmed, measures are taken against the occupier and the land is returned to its lawful owner, or demolition procedures are applied.",
          },
        ),
        Masala(
          {
            Lang.uz: "O'zboshimcha (noqonuniy) qurilish",
            Lang.ru: "Самовольное (незаконное) строительство",
            Lang.en: "Unauthorised (illegal) construction",
          },
          {
            Lang.uz:
                "Shaharsozlik kodeksi va VM qarorlari asosida ruxsatsiz qurilish noqonuniy. Ariza bo'yicha ob'yekt tekshirilib, qonunlashtirish imkoniyati yoki buzish tartibi belgilanadi; qaror ustidan sudga shikoyat huquqi tushuntiriladi.",
            Lang.ru:
                "На основании Градостроительного кодекса и постановлений Кабинета Министров строительство без разрешения незаконно. По заявлению объект проверяется, определяется возможность легализации либо порядок сноса; разъясняется право обжаловать решение в суд.",
            Lang.en:
                "Under the Urban Planning Code and Cabinet of Ministers resolutions, construction without a permit is illegal. Upon application, the structure is inspected and either legalisation options or demolition procedures are determined; the right to appeal the decision in court is explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Kadastr xodimi xatti-harakatlari",
            Lang.ru: "Действия сотрудников кадастра",
            Lang.en: "Conduct of cadastre staff",
          },
          {
            Lang.uz:
                "Xodim sansalorlik yoki qoidabuzarlik qilsa, ichki xizmat tekshiruvi o'tkaziladi. Huquqbuzarlik tasdiqlansa intizomiy chora ko'rilib, natija arizachiga bildiriladi; korruptsiya belgisi bo'lsa tegishli organga material yuboriladi.",
            Lang.ru:
                "Если сотрудник допускает волокиту или нарушает правила, проводится внутренняя служебная проверка. При подтверждении правонарушения принимаются дисциплинарные меры и результат сообщается заявителю; при признаках коррупции материалы направляются в соответствующий орган.",
            Lang.en:
                "If an employee engages in red tape or violates the rules, an internal review is conducted. If the offence is confirmed, disciplinary measures are taken and the applicant is informed; if there are signs of corruption, the materials are forwarded to the appropriate body.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Bandlik va ish haqiga oid masalalar",
        Lang.ru: "Вопросы занятости и заработной платы",
        Lang.en: "Employment and wages",
      },
      Icons.work_outline,
      [
        Masala(
          {
            Lang.uz: "Ish haqi to'lash bilan bog'liq muammolar",
            Lang.ru: "Проблемы с выплатой заработной платы",
            Lang.en: "Problems with wage payment",
          },
          {
            Lang.uz:
                "Mehnat kodeksi asosida ish haqi belgilangan muddatda to'liq to'lanishi shart; kechiktirilsa ish beruvchi foiz to'laydi. Ariza mehnat inspektsiyasi orqali tekshirilib, qarzdorlik undiriladi; hal bo'lmasa mehnat nizosi sifatida sudga yo'naltiriladi.",
            Lang.ru:
                "На основании Трудового кодекса заработная плата должна выплачиваться полностью в установленный срок; при задержке работодатель выплачивает проценты. Заявление проверяется через трудовую инспекцию, задолженность взыскивается; если вопрос не решается, он направляется в суд как трудовой спор.",
            Lang.en:
                "Under the Labour Code, wages must be paid in full and on time; in case of delay, the employer pays interest. The complaint is verified by the labour inspectorate and arrears are recovered; if unresolved, the matter is referred to court as a labour dispute.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ish bilan ta'minlash so'rovi",
            Lang.ru: "Запрос о трудоустройстве",
            Lang.en: "Employment assistance request",
          },
          {
            Lang.uz:
                "«Aholini ish bilan ta'minlash to'g'risida»gi Qonun asosida bandlik markazi bo'sh ish o'rinlari, kasb o'qitish va subsidiya imkoniyatlarini taklif etadi. Arizachi rasmiy ro'yxatga olinib, unga mos vakansiyalar yo'naltiriladi.",
            Lang.ru:
                "На основании Закона «О занятости населения» центр занятости предлагает вакансии, профессиональное обучение и субсидии. Заявитель официально регистрируется, и ему подбираются подходящие вакансии.",
            Lang.en:
                "Under the Law \"On Employment of the Population\", the employment centre offers vacancies, vocational training and subsidies. The applicant is officially registered and referred to suitable vacancies.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ishdan bo'shatilganda yakuniy hisob-kitobni bermaslik",
            Lang.ru: "Невыдача окончательного расчёта при увольнении",
            Lang.en: "Failure to pay the final settlement upon dismissal",
          },
          {
            Lang.uz:
                "Mehnat kodeksiga ko'ra yakuniy hisob-kitob ishdan bo'shatilgan kuni to'liq berilishi shart. Ariza bo'yicha ish beruvchidan undirish choralari ko'riladi; to'lamasa mehnat inspektsiyasi jarima va sud orqali undirishni ta'minlaydi.",
            Lang.ru:
                "Согласно Трудовому кодексу окончательный расчёт должен быть выдан полностью в день увольнения. По заявлению принимаются меры взыскания с работодателя; при неуплате трудовая инспекция обеспечивает взыскание через штраф и суд.",
            Lang.en:
                "Under the Labour Code, the final settlement must be paid in full on the day of dismissal. Upon application, recovery measures are taken against the employer; if unpaid, the labour inspectorate ensures recovery through fines and the courts.",
          },
        ),
        Masala(
          {
            Lang.uz: "Mehnat nizolari",
            Lang.ru: "Трудовые споры",
            Lang.en: "Labour disputes",
          },
          {
            Lang.uz:
                "Mehnat nizolari mehnat nizolari komissiyasi va sud orqali ko'riladi. Arizachiga nizoni ko'rish tartibi, muddatlar va zarur hujjatlar tushuntirilib, mehnat inspektsiyasi tekshiruvi tashkil etiladi.",
            Lang.ru:
                "Трудовые споры рассматриваются комиссией по трудовым спорам и судом. Заявителю разъясняются порядок рассмотрения спора, сроки и необходимые документы, организуется проверка трудовой инспекции.",
            Lang.en:
                "Labour disputes are considered by the labour dispute commission and the courts. The applicant is informed of the review procedure, deadlines and required documents, and a labour inspectorate check is arranged.",
          },
        ),
        Masala(
          {
            Lang.uz: "Bandlik sohasida axborot tizimlari faoliyati",
            Lang.ru: "Работа информационных систем в сфере занятости",
            Lang.en: "Operation of employment information systems",
          },
          {
            Lang.uz:
                "«Ish haqi va bandlik» axborot tizimlaridagi nosozlik yoki xato ma'lumot texnik tartibda tuzatiladi. Ariza bo'yicha tizim ma'muriga yo'naltirilib, ma'lumot to'g'rilanadi va natija arizachiga bildiriladi.",
            Lang.ru:
                "Сбой или ошибочные данные в информационных системах «Заработная плата и занятость» исправляются в техническом порядке. Заявление направляется администратору системы, данные корректируются и результат сообщается заявителю.",
            Lang.en:
                "Malfunctions or incorrect data in the \"Wages and Employment\" information systems are corrected technically. The application is forwarded to the system administrator, the data are corrected and the applicant is informed of the result.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Maktabgacha ta'lim va maktab faoliyatiga oid masalalar",
        Lang.ru: "Вопросы дошкольного образования и деятельности школ",
        Lang.en: "Preschool education and school operations",
      },
      Icons.school_outlined,
      [
        Masala(
          {
            Lang.uz: "MTTga joylashtirish (bog'cha navbati)",
            Lang.ru: "Устройство в ДОО (очередь в детский сад)",
            Lang.en: "Placement in preschool (kindergarten waiting list)",
          },
          {
            Lang.uz:
                "«Ta'lim to'g'risida»gi Qonun va VM qoidalari asosida MTTga qabul elektron navbat tizimi orqali shaffof amalga oshiriladi. Ariza bo'yicha navbat holati, bo'sh o'rin va muqobil MTTlar ko'rsatiladi; navbatsiz imtiyozli toifalar ham tushuntiriladi.",
            Lang.ru:
                "На основании Закона «Об образовании» и правил Кабинета Министров приём в дошкольные образовательные организации осуществляется прозрачно через систему электронной очереди. По заявлению показываются состояние очереди, свободные места и альтернативные ДОО; также разъясняются льготные категории, принимаемые вне очереди.",
            Lang.en:
                "Under the Law \"On Education\" and Cabinet of Ministers rules, admission to preschool institutions is carried out transparently through the electronic queue system. Upon application, the queue status, available places and alternative preschools are shown; priority categories admitted out of turn are also explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ta'lim sohasi xodimi xatti-harakatlari",
            Lang.ru: "Действия работников сферы образования",
            Lang.en: "Conduct of education staff",
          },
          {
            Lang.uz:
                "Xodim odob-axloq va pedagogik etika qoidalarini buzsa, xizmat tekshiruvi o'tkaziladi. Tasdiqlansa — intizomiy chora ko'rilib natija bildiriladi; bolaga nisbatan huquqbuzarlik bo'lsa tegishli organlarga material yuboriladi.",
            Lang.ru:
                "Если работник нарушает правила этики и педагогической этики, проводится служебная проверка. При подтверждении принимаются дисциплинарные меры и сообщается результат; при правонарушении в отношении ребёнка материалы направляются в соответствующие органы.",
            Lang.en:
                "If an employee violates ethical or pedagogical conduct rules, an internal review is conducted. If confirmed, disciplinary measures are taken and the outcome is communicated; if a child's rights have been violated, materials are sent to the appropriate authorities.",
          },
        ),
        Masala(
          {
            Lang.uz: "Maktab faoliyatidan norozilik",
            Lang.ru: "Недовольство работой школы",
            Lang.en: "Complaints about school operations",
          },
          {
            Lang.uz:
                "Ariza maktab ma'muriyati va tuman ta'lim bo'limi tomonidan tekshiriladi. Kamchiliklar aniqlansa bartaraf etilib, javobgar shaxslarga chora ko'riladi; natija qonuniy muddatda arizachiga bildiriladi.",
            Lang.ru:
                "Заявление проверяется администрацией школы и районным отделом образования. При выявлении недостатков они устраняются, к виновным принимаются меры; результат сообщается заявителю в законный срок.",
            Lang.en:
                "The complaint is examined by the school administration and the district education department. Any shortcomings found are corrected and measures are taken against those responsible; the applicant is informed of the outcome within the legal deadline.",
          },
        ),
        Masala(
          {
            Lang.uz: "Davlat MTT faoliyatidan norozilik",
            Lang.ru: "Недовольство работой государственных ДОО",
            Lang.en: "Complaints about state preschools",
          },
          {
            Lang.uz:
                "MTT faoliyatidagi kamchilik (oziq-ovqat, tarbiya, sanitariya) tuman bo'limi tekshiruvi orqali ko'riladi. Talablar buzilsa bartaraf etilib, zarur holda rahbarga intizomiy chora qo'llanadi.",
            Lang.ru:
                "Недостатки в работе ДОО (питание, воспитание, санитария) рассматриваются через проверку районного отдела. При нарушении требований они устраняются, при необходимости к руководителю применяются дисциплинарные меры.",
            Lang.en:
                "Shortcomings in preschool operations (meals, upbringing, sanitation) are reviewed through a district department inspection. Violations are remedied and, where necessary, disciplinary measures are applied to the head.",
          },
        ),
        Masala(
          {
            Lang.uz: "Maktabga joylashtirish so'rovi",
            Lang.ru: "Запрос об устройстве в школу",
            Lang.en: "School placement request",
          },
          {
            Lang.uz:
                "Maktabga qabul hududiy biriktiruv va elektron tizim asosida amalga oshiriladi. Arizachiga biriktirilgan maktab, bo'sh o'rin va zarur hujjatlar ko'rsatilib, rad etilsa sabab va muqobil imkoniyat tushuntiriladi.",
            Lang.ru:
                "Приём в школу осуществляется на основе территориального закрепления и электронной системы. Заявителю указываются закреплённая школа, свободные места и необходимые документы; при отказе разъясняются причина и альтернативная возможность.",
            Lang.en:
                "School admission is based on territorial assignment and the electronic system. The applicant is shown the assigned school, available places and required documents; if refused, the reason and alternative options are explained.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Nogironlikni belgilash va sog'liqni saqlash masalalari",
        Lang.ru: "Вопросы установления инвалидности и здравоохранения",
        Lang.en: "Disability assessment and healthcare",
      },
      Icons.local_hospital_outlined,
      [
        Masala(
          {
            Lang.uz: "Davolanish va jarrohlik amaliyoti uchun moddiy yordam",
            Lang.ru: "Материальная помощь на лечение и хирургические операции",
            Lang.en: "Financial assistance for treatment and surgery",
          },
          {
            Lang.uz:
                "«Fuqarolar sog'lig'ini saqlash to'g'risida»gi Qonun va davlat kafolatlari dasturi asosida tibbiy hujjat va smeta bo'yicha ko'riladi. Kvota/bepul davolash imkoniyati bo'lsa yo'naltiriladi; moddiy yordam esa ijtimoiy jamg'armalar orqali ajratilishi tushuntiriladi.",
            Lang.ru:
                "На основании Закона «Об охране здоровья граждан» и программы государственных гарантий вопрос рассматривается по медицинским документам и смете. При наличии квоты/возможности бесплатного лечения даётся направление; разъясняется, что материальная помощь выделяется через социальные фонды.",
            Lang.en:
                "Under the Law \"On the Protection of Citizens' Health\" and the state guarantees programme, the matter is reviewed based on medical documents and a cost estimate. If a quota or free treatment is available, a referral is given; it is explained that financial assistance itself is provided through social funds.",
          },
        ),
        Masala(
          {
            Lang.uz: "Davolanishga order olish",
            Lang.ru: "Получение ордера (направления) на лечение",
            Lang.en: "Obtaining a treatment referral (order)",
          },
          {
            Lang.uz:
                "Ixtisoslashgan markazlarga order tibbiy ko'rsatma va navbat asosida beriladi. Ariza bo'yicha zarur tekshiruvlar, navbat va order rasmiylashtirish tartibi ko'rsatilib, kechiksa sabab aniqlanib bartaraf etiladi.",
            Lang.ru:
                "Ордер в специализированные центры выдаётся по медицинским показаниям и очереди. По заявлению указываются необходимые обследования, очередь и порядок оформления ордера; при задержке причина выясняется и устраняется.",
            Lang.en:
                "Referrals to specialised centres are issued based on medical indications and the waiting list. Upon application, the required examinations, the queue and the referral procedure are explained; in case of delay, the cause is identified and eliminated.",
          },
        ),
        Masala(
          {
            Lang.uz: "Tibbiyot xodimi xatti-harakatlari",
            Lang.ru: "Действия медицинских работников",
            Lang.en: "Conduct of medical staff",
          },
          {
            Lang.uz:
                "Xodim tibbiy etika yoki xizmat vazifasini buzsa, xizmat tekshiruvi va zarur holda tibbiy-ekspertiza o'tkaziladi. Huquqbuzarlik tasdiqlansa intizomiy/ma'muriy chora ko'riladi, og'ir holatda jinoiy-huquqiy baho beriladi.",
            Lang.ru:
                "Если работник нарушает медицинскую этику или служебные обязанности, проводится служебная проверка и при необходимости медицинская экспертиза. При подтверждении правонарушения принимаются дисциплинарные/административные меры, в тяжёлых случаях даётся уголовно-правовая оценка.",
            Lang.en:
                "If an employee violates medical ethics or official duties, an internal review and, where necessary, a medical expert examination are conducted. If the offence is confirmed, disciplinary or administrative measures are taken; in serious cases, a criminal-law assessment is given.",
          },
        ),
        Masala(
          {
            Lang.uz: "Sog'liqni saqlash sohasidagi huquqbuzarliklar",
            Lang.ru: "Правонарушения в сфере здравоохранения",
            Lang.en: "Offences in the healthcare sector",
          },
          {
            Lang.uz:
                "Ariza sog'liqni saqlash nazorati organi tomonidan tekshiriladi. Standart, litsenziya yoki bemor huquqi buzilsa — chora ko'rilib, zarar yetkazilgan bo'lsa qoplash va javobgarlikka tortish tartibi qo'llanadi.",
            Lang.ru:
                "Заявление проверяется органом надзора в сфере здравоохранения. При нарушении стандартов, лицензии или прав пациента принимаются меры; при причинении вреда применяются порядок возмещения и привлечения к ответственности.",
            Lang.en:
                "The complaint is examined by the healthcare supervisory body. If standards, licences or patient rights have been violated, measures are taken; if harm has been caused, compensation and accountability procedures are applied.",
          },
        ),
        Masala(
          {
            Lang.uz: "Tibbiy-mehnat ekspertizasi va nogironlik belgilash",
            Lang.ru: "Медико-трудовая экспертиза и установление инвалидности",
            Lang.en: "Medical-labour expert examination and disability determination",
          },
          {
            Lang.uz:
                "TME xulosasi belgilangan mezonlar asosida chiqariladi. Arizachi TMEga yo'naltirilib, xulosadan norozi bo'lsa yuqori TME komissiyasi yoki sudga shikoyat qilish huquqi tushuntiriladi.",
            Lang.ru:
                "Заключение МТЭК выносится на основании установленных критериев. Заявитель направляется в МТЭК; при несогласии с заключением разъясняется право обжалования в вышестоящую комиссию МТЭК или в суд.",
            Lang.en:
                "The MLEC conclusion is issued based on established criteria. The applicant is referred to the MLEC; if they disagree with the conclusion, the right to appeal to a higher MLEC commission or the court is explained.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Ichimlik va oqova suv bilan ta'minlash masalalari",
        Lang.ru: "Вопросы обеспечения питьевой водой и канализации",
        Lang.en: "Drinking water supply and sewerage",
      },
      Icons.water_drop_outlined,
      [
        Masala(
          {
            Lang.uz: "Ichimlik suvi tarmog'idagi avariyalar, bosim pastligi",
            Lang.ru: "Аварии в сети питьевого водоснабжения, низкое давление",
            Lang.en: "Drinking water network accidents and low pressure",
          },
          {
            Lang.uz:
                "«Suv va suvdan foydalanish to'g'risida»gi Qonun va VM «Ichimlik suvidan foydalanish qoidalari» asosida ta'minlovchi uzluksiz va me'yoriy bosimda ta'minlashga majbur. Ariza bo'yicha avariya bartaraf etilib, tiklash muddati va zarur holda muvaqat ta'minot ko'rsatiladi.",
            Lang.ru:
                "На основании Закона «О воде и водопользовании» и утверждённых Кабинетом Министров «Правил пользования питьевой водой» поставщик обязан обеспечивать бесперебойное снабжение с нормативным давлением. По заявлению авария устраняется, указываются срок восстановления и при необходимости временное снабжение.",
            Lang.en:
                "Under the Law \"On Water and Water Use\" and the Cabinet of Ministers' \"Rules for the Use of Drinking Water\", the supplier must ensure an uninterrupted supply at standard pressure. Upon application, the fault is repaired, the restoration deadline is given and, where necessary, temporary supply is arranged.",
          },
        ),
        Masala(
          {
            Lang.uz: "Ichimlik suvi to'lovlari, qarzdorlik, qayta hisoblash",
            Lang.ru: "Платежи за питьевую воду, задолженность, перерасчёт",
            Lang.en: "Drinking water payments, arrears and recalculation",
          },
          {
            Lang.uz:
                "To'lov hisoblagich yoki norma bo'yicha undiriladi. Solishtirma dalolatnoma orqali tafovut aniqlansa qayta hisoblanadi; qarzdorlik bo'lsa bo'lib to'lash va imtiyozli toifa uchun subsidiya imkoniyati tushuntiriladi.",
            Lang.ru:
                "Оплата взимается по счётчику или нормативу. Если через сверочный акт выявлено расхождение, производится перерасчёт; при задолженности разъясняются возможность рассрочки и субсидии для льготных категорий.",
            Lang.en:
                "Payment is charged based on the meter or the standard norm. If a discrepancy is found through a reconciliation report, a recalculation is made; in case of arrears, instalment options and subsidies for eligible categories are explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Markazlashgan suv tarmog'iga ulash masalalari",
            Lang.ru: "Вопросы подключения к централизованной водопроводной сети",
            Lang.en: "Connection to the centralised water network",
          },
          {
            Lang.uz:
                "Ulash texnik shartlar va loyiha asosida davlat xizmati tartibida amalga oshiriladi. Ariza bo'yicha texnik imkoniyat tekshirilib, shartlar beriladi; rad etilsa asos yozma ko'rsatilib muqobil yechim taklif etiladi.",
            Lang.ru:
                "Подключение осуществляется на основании технических условий и проекта в порядке государственной услуги. По заявлению проверяется техническая возможность и выдаются условия; при отказе основание указывается письменно и предлагается альтернативное решение.",
            Lang.en:
                "Connection is carried out based on technical conditions and a design, through the public services procedure. Upon application, technical feasibility is checked and conditions are issued; if refused, the grounds are stated in writing and an alternative solution is proposed.",
          },
        ),
        Masala(
          {
            Lang.uz: "Suv tizimi inshootlarini qurish va ta'mirlash",
            Lang.ru: "Строительство и ремонт сооружений водоснабжения",
            Lang.en: "Construction and repair of water system facilities",
          },
          {
            Lang.uz:
                "Inshootlarni qurish/ta'mirlash investitsiya dasturi va navbat asosida ko'riladi. Ariza bo'yicha texnik ko'rik o'tkazilib, ish rejasi va muddati belgilanib, arizachiga bildiriladi.",
            Lang.ru:
                "Строительство/ремонт сооружений рассматривается в рамках инвестиционной программы и очереди. По заявлению проводится технический осмотр, определяются план работ и сроки, о чём сообщается заявителю.",
            Lang.en:
                "Construction and repair of facilities are considered under the investment programme and in order of priority. Upon application, a technical inspection is carried out, a work plan and timeframe are set, and the applicant is informed.",
          },
        ),
        Masala(
          {
            Lang.uz: "Oqova suv (kanalizatsiya) avariyalari va tozalash",
            Lang.ru: "Аварии канализации и очистка",
            Lang.en: "Sewerage accidents and cleaning",
          },
          {
            Lang.uz:
                "Kanalizatsiya tizimi nosozligi ta'minlovchi tomonidan bartaraf etilishi shart. Ariza bo'yicha brigada yo'naltirilib, avariya tuzatiladi va sanitariya talablari ta'minlanadi; muddat arizachiga bildiriladi.",
            Lang.ru:
                "Неисправность канализационной системы должна устраняться поставщиком. По заявлению направляется бригада, авария устраняется и обеспечивается соблюдение санитарных требований; срок сообщается заявителю.",
            Lang.en:
                "Faults in the sewerage system must be repaired by the supplier. Upon application, a crew is dispatched, the fault is fixed and sanitary requirements are ensured; the deadline is communicated to the applicant.",
          },
        ),
      ],
    ),
    Tashkilot(
      {
        Lang.uz: "Viloyat hokimi qabuliga kirish masalasi",
        Lang.ru: "Вопрос записи на приём к хокиму области",
        Lang.en: "Booking a reception with the regional governor",
      },
      Icons.location_city_outlined,
      [
        Masala(
          {
            Lang.uz: "Ichki yo'llarni asfalt va shag'allashtirish",
            Lang.ru: "Асфальтирование и отсыпка щебнем внутренних дорог",
            Lang.en: "Asphalting and gravelling of local roads",
          },
          {
            Lang.uz:
                "«Mahalliy davlat hokimiyati to'g'risida»gi Qonun asosida yo'l-transport infratuzilmasi hokimlik vakolatiga kiradi. Ariza bo'yicha ob'yekt tegishli dastur va byudjet imkoniyatiga ko'ra rejaga kiritilib, navbat va muddat arizachiga bildiriladi.",
            Lang.ru:
                "На основании Закона «О местной государственной власти» дорожно-транспортная инфраструктура относится к полномочиям хокимията. По заявлению объект включается в план в рамках соответствующей программы и возможностей бюджета, очередь и срок сообщаются заявителю.",
            Lang.en:
                "Under the Law \"On Local State Authority\", road and transport infrastructure falls within the khokimiyat's remit. Upon application, the site is included in the plan according to the relevant programme and budget capacity, and the queue position and timeframe are communicated to the applicant.",
          },
        ),
        Masala(
          {
            Lang.uz: "Uy-joy bilan ta'minlash",
            Lang.ru: "Обеспечение жильём",
            Lang.en: "Housing provision",
          },
          {
            Lang.uz:
                "Ijtimoiy uy-joy va ipoteka subsidiyasi dasturlari asosida muhtojlik tasdiqlansa navbat belgilanadi. Arizachiga navbat holati, dastur shartlari va zarur hujjatlar ko'rsatilib, mos kelmasa muqobil imkoniyat tushuntiriladi.",
            Lang.ru:
                "На основании программ социального жилья и ипотечных субсидий при подтверждении нуждаемости устанавливается очередь. Заявителю указываются состояние очереди, условия программы и необходимые документы; при несоответствии разъясняются альтернативные возможности.",
            Lang.en:
                "Under social housing and mortgage subsidy programmes, a place in the queue is assigned once need is confirmed. The applicant is shown the queue status, programme conditions and required documents; if the conditions are not met, alternative options are explained.",
          },
        ),
        Masala(
          {
            Lang.uz: "Qarovsiz hayvonlar bilan bog'liq masalalar",
            Lang.ru: "Вопросы, связанные с безнадзорными животными",
            Lang.en: "Stray animal issues",
          },
          {
            Lang.uz:
                "Sanitariya va hayvonot dunyosini muhofaza qilish talablari asosida hokimlik va obod.xizmat qarovsiz hayvonlarni tutish va boshpanaga joylash ishlarini tashkil etadi. Ariza bo'yicha tegishli xizmatga topshiriq berilib, natija bildiriladi.",
            Lang.ru:
                "На основании санитарных требований и требований охраны животного мира хокимият и служба «obod.xizmat» организуют отлов безнадзорных животных и их размещение в приютах. По заявлению даётся поручение соответствующей службе, результат сообщается заявителю.",
            Lang.en:
                "Based on sanitary and wildlife protection requirements, the khokimiyat and the \"obod.xizmat\" service organise the capture of stray animals and their placement in shelters. Upon application, the relevant service is tasked and the result is communicated.",
          },
        ),
        Masala(
          {
            Lang.uz: "Mahalliy hokimliklar qarorlaridan norozilik",
            Lang.ru: "Несогласие с решениями местных хокимиятов",
            Lang.en: "Disagreement with local khokimiyat decisions",
          },
          {
            Lang.uz:
                "«Ma'muriy tartib-taomillar to'g'risida»gi Qonun asosida hokimlik qarori ustidan yuqori hokimlikka yoki ma'muriy sudga shikoyat qilish mumkin. Arizachiga shikoyat muddati, tartibi va tegishli instantsiya tushuntiriladi.",
            Lang.ru:
                "На основании Закона «Об административных процедурах» решение хокимията может быть обжаловано в вышестоящий хокимият или в административный суд. Заявителю разъясняются срок, порядок обжалования и соответствующая инстанция.",
            Lang.en:
                "Under the Law \"On Administrative Procedures\", a khokimiyat decision may be appealed to a higher khokimiyat or the administrative court. The applicant is informed of the appeal deadline, procedure and appropriate instance.",
          },
        ),
        Masala(
          {
            Lang.uz: "Viloyat hokimi (o'rinbosari) qabuli so'rovi",
            Lang.ru: "Запрос на приём к хокиму области (заместителю)",
            Lang.en: "Request for an appointment with the regional governor (deputy)",
          },
          {
            Lang.uz:
                "«Jismoniy va yuridik shaxslarning murojaatlari to'g'risida»gi Qonun 26-moddasi asosida shaxsiy qabul jadval bo'yicha tashkil etiladi. Masala avval quyi bo'g'inda ko'rilishi, hal bo'lmasa yuqoriga yo'naltirilishi tartibi tushuntiriladi.",
            Lang.ru:
                "На основании статьи 26 Закона «Об обращениях физических и юридических лиц» личный приём организуется по графику. Разъясняется порядок: вопрос сначала рассматривается в нижестоящем звене, а при нерешении направляется выше.",
            Lang.en:
                "Under Article 26 of the Law \"On Appeals of Individuals and Legal Entities\", personal reception is organised according to a schedule. It is explained that the issue must first be considered at the lower level and, if unresolved, referred upwards.",
          },
        ),
      ],
    ),
  ];

  /// Closing legal notes that apply to every appeal, from the source document.
  static const Map<Lang, List<String>> umumiyIzoh = {
    Lang.uz: [
      "Barcha murojaatlar «Jismoniy va yuridik shaxslarning murojaatlari to'g'risida»gi O'zbekiston Respublikasi Qonuni asosida ko'rib chiqilishi shart.",
      "Yozma murojaat — ro'yxatga olingan kundan boshlab 15 kun ichida (qo'shimcha o'rganish talab etilsa, vakolatli shaxs ruxsati bilan 1 oygacha) ko'rib chiqiladi.",
      "Har bir javob asoslantirilgan, aniq va tegishli qonun hujjatlariga havola qilingan holda berilishi lozim.",
      "Murojaat rad etilsa — rad etish sababi ko'rsatilib, yuqori turuvchi organ yoki sudga shikoyat qilish huquqi tushuntirilishi shart.",
      "Murojaatchini ta'qib qilish yoki uning murojaatini ko'rmasdan qoldirish qonunan taqiqlanadi va javobgarlikka sabab bo'ladi.",
      "Ushbu hujjatdagi huquqiy javoblar umumiy yo'naltiruvchi xususiyatga ega bo'lib, har bir aniq murojaat bo'yicha yakuniy qaror tegishli vakolatli organ tomonidan amaldagi qonunchilik va ishning holati asosida qabul qilinadi.",
    ],
    Lang.ru: [
      "Все обращения должны рассматриваться на основании Закона Республики Узбекистан «Об обращениях физических и юридических лиц».",
      "Письменное обращение рассматривается в течение 15 дней со дня регистрации (при необходимости дополнительного изучения — до 1 месяца с разрешения уполномоченного лица).",
      "Каждый ответ должен быть обоснованным, конкретным и содержать ссылки на соответствующие акты законодательства.",
      "При отказе в удовлетворении обращения должна указываться причина отказа и разъясняться право обжалования в вышестоящий орган или в суд.",
      "Преследование заявителя или оставление его обращения без рассмотрения запрещено законом и влечёт ответственность.",
      "Правовые ответы в настоящем документе носят общий ориентирующий характер; окончательное решение по каждому конкретному обращению принимается соответствующим уполномоченным органом на основании действующего законодательства и обстоятельств дела.",
    ],
    Lang.en: [
      "All appeals must be considered in accordance with the Law of the Republic of Uzbekistan \"On Appeals of Individuals and Legal Entities\".",
      "A written appeal is considered within 15 days from the date of registration (or up to 1 month with the permission of an authorised official if additional study is required).",
      "Every answer must be reasoned, specific and include references to the relevant legislation.",
      "If an appeal is refused, the reason for refusal must be stated and the right to appeal to a higher body or to court must be explained.",
      "Persecuting an applicant or leaving their appeal unconsidered is prohibited by law and entails liability.",
      "The legal answers in this document are of a general guiding nature; the final decision on each specific appeal is made by the relevant competent body based on the applicable legislation and the circumstances of the case.",
    ],
  };
}
