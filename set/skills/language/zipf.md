# Language: Zipf optimization

Use a small, stable core vocabulary for recurring ideas. In natural-language
corpora, a few words occur often while a long tail occurs rarely. Exploit that
shape to reduce reading effort without sacrificing precision.

## Workflow

1. Identify the audience, task, and representative corpus. Word frequency
    depends on language, domain, genre, and tokenization.
2. Rank the terms used for recurring concepts. Find competing synonyms,
    needless variants, and rare words that add no useful distinction.
3. Choose one familiar canonical term for each recurring concept. Use it in
    headings, instructions, labels, error messages, and examples.
4. Replace an uncommon term with a common one only when meaning survives. Keep
    the precise term when it carries a technical, legal, safety, or domain
    distinction; define it at first use.
5. Put common action words and decision cues early. Let readers recognize the
    task before they meet qualifications or uncommon detail.
6. Measure the result with the intended audience. Check comprehension, search
    success, execution errors, and time to act; use word-frequency ranks only as
    diagnostic evidence.

## Practical rules

- Prefer one term used consistently over several elegant synonyms.
- Spend rare vocabulary on information, not style. A low-frequency word earns
  its place when it is the shortest accurate name for a necessary distinction.
- Keep exact identifiers, commands, API names, quoted text, and established
  domain terms unchanged.
- Explain rare terms with common words, then reuse the precise term.
- Compare alternatives against a corpus that represents the audience. General
  language frequency can misclassify familiar domain vocabulary as difficult.
- Optimize phrases and structure as well as isolated words. A common word in an
  unfamiliar construction can still be hard to understand.

## Signals of violation

- The same concept changes names across a document or interface.
- A rare synonym replaces a common word without adding precision.
- Important distinctions disappear because only high-frequency words are
  allowed.
- Raw word counts are treated as a readability or quality score.
- A frequency list from another language, domain, or audience dictates edits.
- Text is padded with common words to resemble an ideal rank-frequency curve.

## Limits

Zipf's law is an empirical approximation: a word's frequency is roughly
inversely proportional to its rank. It does not say that common words are
always clearer, that rare words are waste, or that forcing text toward a Zipfian
distribution improves it. Actual texts deviate, especially at the
highest and lowest ranks. Preserve accuracy and test the outcome with readers.
Apply the [[consequences]] principle when simplifying consequential language.

Based on [Zipf's law](https://en.wikipedia.org/wiki/Zipf%27s_law), the observed
rank-frequency pattern in which a small vocabulary accounts for much of a
natural-language corpus and a long tail of words occurs infrequently.
