import 'data.dart';
import 'l10n.dart';

/// A fully offline advisor: it answers from the kiosk's own knowledge base
/// (FAQ + services) using simple token-overlap matching. No network, no
/// external services — self-contained so the kiosk works anywhere.
class AiResponder {
  const AiResponder();

  static final RegExp _nonWord = RegExp(r"[^\p{L}\p{N}]+", unicode: true);

  Set<String> _tokens(String s) => s
      .toLowerCase()
      .split(_nonWord)
      .where((w) => w.length > 2)
      .toSet();

  /// Returns the best answer for [question] in [lang], or the localized
  /// offline fallback when nothing matches well enough.
  String answer(String question, Lang lang) =>
      match(question, lang) ?? Tr(lang).aiOffline;

  /// The best local answer for [question], or null when nothing in the kiosk's
  /// own knowledge base matches well enough. Callers that have a backend can
  /// use null as the signal to ask it instead of showing the offline text.
  String? match(String question, Lang lang) {
    final q = _tokens(question);
    if (q.isEmpty) return null;

    String? best;
    var bestScore = 0.0;

    void consider(String candidateText, String reply) {
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
    for (final item in AppData.faq[lang]!) {
      consider('${item[0]} ${item[1]}', item[1]);
    }
    // Services: title + description.
    for (final s in AppData.xizmatlar[lang]!) {
      consider('${s[0]} ${s[1]}', '${s[0]} — ${s[1]}.');
    }

    if (best != null && bestScore >= 0.35) return best!;
    return null;
  }
}
