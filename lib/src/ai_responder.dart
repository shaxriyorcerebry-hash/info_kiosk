import 'content_models.dart';
import 'l10n.dart';

/// The kiosk's own advisor: it answers from the content the office publishes
/// (the FAQ and the service list) using simple token-overlap matching.
///
/// It runs entirely on what has already been downloaded, so a visitor asking
/// about opening hours or documents is answered instantly and without a
/// round-trip — and is still answered when the network is down. Only questions
/// it cannot match are worth spending a backend call on.
///
/// Its vocabulary is therefore only as good as the published content: with an
/// empty FAQ it matches nothing and says so, rather than inventing an answer.
class AiResponder {
  const AiResponder();

  static final RegExp _nonWord = RegExp(r"[^\p{L}\p{N}]+", unicode: true);

  Set<String> _tokens(String s) =>
      s.toLowerCase().split(_nonWord).where((w) => w.length > 2).toSet();

  /// Returns the best answer for [question] in [lang], or the localized
  /// offline fallback when nothing matches well enough.
  String answer(
    String question,
    Lang lang, {
    FaqInfo? faq,
    List<ServiceInfo> services = const [],
  }) =>
      match(question, lang, faq: faq, services: services) ?? Tr(lang).aiOffline;

  /// The best local answer for [question], or null when nothing in the
  /// published content matches well enough. Callers with a backend can use
  /// null as the signal to ask it instead of showing the offline text.
  String? match(
    String question,
    Lang lang, {
    FaqInfo? faq,
    List<ServiceInfo> services = const [],
  }) {
    final q = _tokens(question);
    if (q.isEmpty) return null;

    String? best;
    var bestScore = 0.0;

    void consider(String candidateText, String reply) {
      if (reply.trim().isEmpty) return;
      final c = _tokens(candidateText);
      if (c.isEmpty) return;
      final overlap = q.intersection(c).length;
      if (overlap == 0) return;
      // Normalised so short candidates aren't unfairly favoured.
      final score = overlap / (q.length + 1) + overlap / (c.length + 1);
      if (score > bestScore) {
        bestScore = score;
        best = reply;
      }
    }

    // FAQ: match against both the question and the answer text.
    for (final item in faq?.items ?? const []) {
      final question = item.question[lang] ?? '';
      final answer = item.answer[lang] ?? '';
      consider('$question $answer', answer);
    }
    // Services: title + description.
    for (final s in services) {
      final title = s.title[lang] ?? '';
      final desc = s.desc[lang] ?? '';
      consider('$title $desc', desc.isEmpty ? title : '$title — $desc.');
    }

    if (best != null && bestScore >= 0.35) return best!;
    return null;
  }
}
