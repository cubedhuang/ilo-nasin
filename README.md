# ilo nasin

_ilo nasin_ ("grammar tool") is a Toki Pona parser and part-of-speech tagger for TypeScript, using the [nearley](https://nearley.js.org/) parsing toolkit.

## Usage

### `tagSentence(text: string): { words: TaggedWord[]; error: string | null }`

Tags each word in a Toki Pona sentence with its part of speech. If the sentence is invalid or cannot be parsed, returns an error message.

```ts
import { tagSentence } from "ilo-nasin";

tagSentence("jan li pana e moku tawa sina.");
```

```ts
{
  words: [
    { word: { index: 0, text: 'jan' }, tag: 'noun' },
    { word: { index: 4, text: 'li' }, tag: 'particle' },
    { word: { index: 7, text: 'pana' }, tag: 'tverb' },
    { word: { index: 12, text: 'e' }, tag: 'particle' },
    { word: { index: 14, text: 'moku' }, tag: 'noun' },
    { word: { index: 19, text: 'tawa' }, tag: 'preposition' },
    { word: { index: 24, text: 'sina' }, tag: 'noun' }
  ],
  error: null
}
```

Returns the _nearley_ error message if the sentence is invalid.

```ts
tagSentence("toki pi ike li lon");
```

```ts
{
  words: [],
  error: "'li' at index 12\n" +
    'Unexpected word_particle token: "li". Instead, I was expecting to see one of the following:\n' +
    '\n' +
    'A word_modifier_only token based on:\n' +
    '    WordModifier →  ● %word_modifier_only\n' +
    ...
}
```

Returns an error if no parse results are found.

```ts
tagSentence("mi toki pi ike");
```

```ts
{ words: [], error: 'Unexpected end of input' }
```
