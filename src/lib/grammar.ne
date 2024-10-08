@preprocessor typescript

@{%
import { TokiPonaLexer } from "./lex";

const lexer = new TokiPonaLexer();

function idModifiers(args: any[]): any {
	let simple: any;
	let number: any = null;
	let nanpaPhrases: any;
	let piPhrases: any;

	if (args.length === 1) {
		[piPhrases] = args;
	} else if (args.length === 2) {
		[nanpaPhrases, piPhrases] = args;
	} else if (args.length === 3) {
		[number, nanpaPhrases, piPhrases] = args;
	} else if (args.length === 4) {
		[simple, number, nanpaPhrases, piPhrases] = args;
	} else {
		throw new Error("Invalid number of arguments");
	}

	return {
		type: "modifiers",
		simple: simple || [],
		number,
		nanpaPhrases: nanpaPhrases || [],
		piPhrases: piPhrases || []
	};
}

function verbify(phrase: any): any {
	if (phrase.type === "phrase") {
		return {
			type: "verb",
			kind: "default",
			head: phrase.head,
			modifiers: phrase.modifiers
		};
	} else if (phrase.type === "preposition_phrase") {
		return {
			type: "verb",
			kind: "preposition",
			preposition: phrase.preposition,
			phrase: phrase.phrase
		};
	} else {
		throw new Error("Invalid phrase type");
	}
}
%}

@lexer lexer

main -> Sentence {% id %}
	| Interjection {% id %}
	| Vocative {% id %}

Interjection -> GeneralSubject
	{% ([subjects]) => ({ type: "interjection", subjects }) %}
Vocative -> GeneralSubject "o"
	{% ([subjects, o]) => ({ type: "vocative", subjects, o}) %}

Sentence -> "taso":? Context:* Clause "kin":? QuestionTag:? "a":?
	{% ([conjunction, contexts, clause, kin, questionTag, emphasis]) => ({ type: "sentence", conjunction, contexts, clause, kin, questionTag, emphasis }) %}

Context -> ContextConjunction {% id %}
	| ContextPreposition {% id %}
	| ContextPhrase {% id %}
	| ContextClause {% id %}

ContextConjunction -> "kin" "la":?
	{% ([kin, la]) => ({ type: "context", kind: "conjunction", kin, la }) %}

ContextPreposition -> PrepositionPhrase:+ "la"
	{% ([phrases, la]) => ({ type: "context", kind: "preposition", phrases, la }) %}

ContextPhrase -> GeneralSubject "la"
	{% ([subjects, la]) => ({ type: "context", kind: "phrase", subjects, la }) %}

ContextClause -> Clause "la"
	{% ([clause, la]) => ({ type: "context", kind: "clause", clause, la }) %}

Clause -> UnmarkedSubjectClause {% id %}
	| MarkedSubjectClause {% id %}
	| DeonticClause {% id %}

QuestionTag -> "anu" "seme" {% tokens => ({ type: "question_tag", tokens }) %}


UnmarkedSubjectClause -> UnmarkedSubject Predicates
	{% ([subject, predicates]) => ({ type: "clause", kind: "unmarked_subject", subjects: [{ type: "subject", phrase: subject }], predicates }) %}

MarkedSubjectClause -> MarkedSubject "li" Predicates
	{% ([subjects, li, predicates]) => ({
		type: "clause",
		kind: "marked_subject",
		subjects,
		predicates: [{ marker: li, ...predicates[0] }, ...predicates.slice(1)]
	}) %}

DeonticClause -> GeneralSubject:? DeonticPredicates
	{% ([subjects, predicates]) => ({ type: "clause", kind: "deontic", subjects, predicates, deontic: true }) %}


UnmarkedSubject -> %word_unmarked_subject
	{% ([head]) => ({ type: "phrase", head }) %}

MarkedSubject -> MarkedSubjectHead {% ([head]) => [{ type: "subject", phrase: { type: "phrase", head } }] %}
	| Head ModifiersOneRequired {% ([head, modifiers]) => [{ type: "subject", phrase: { type: "phrase", head, modifiers } }] %}
	| Phrase ( SubjectMarker Phrase {% ([marker, subject]) => ({ type: "subject", marker, phrase: subject }) %} ):+
	{% ([subject, subjects]) => [{ type: "subject", phrase: subject }, ...subjects] %}

SubjectMarker -> "en" {% id %}
	| "anu" {% id %}

GeneralSubject -> UnmarkedSubject {% ([subject]) => [{ type: "subject", phrase: subject }] %}
	| MarkedSubject {% id %}


Predicates -> Predicate ( PredicateMarker Predicate {% ([li, predicate]) => ({ marker: li, ...predicate }) %} ):*
	{% ([predicate, predicates]) => [predicate, ...predicates] %}

PredicateMarker -> "li" {% id %}
	| "anu" {% id %}

DeonticPredicates -> ("o" Predicate {% ([o, predicate]) => ({ marker: o, ...predicate }) %} ):+
	{% id %}

Predicate -> TransitivePredicate {% id %}
	| IntransitivePredicate {% id %}
	| PrepositionPredicate {% id %}

TransitivePredicate -> Preverb:* Phrase ObjectPhrases
	{% ([preverbs, verb, objects]) => ({ type: "predicate", kind: "transitive", preverbs, verb: verbify(verb), objects }) %}

IntransitivePredicate -> Preverb:* Phrase PrepositionPhrase:*
	{% ([preverbs, verb, prepositions]) => ({ type: "predicate", kind: "intransitive", preverbs, verb: verbify(verb), prepositions }) %}

PrepositionPredicate -> Preverb:* PrepositionPhrase PrepositionPhrase:*
	{% ([preverbs, verb, prepositions]) => ({ type: "predicate", kind: "preposition", preverbs, verb: verbify(verb), prepositions }) %}

Preverb -> %word_preverb "ala":?
	{% ([preverb, negated]) => ({ type: "preverb", preverb, negated }) %}


ObjectPhrases -> "e" ObjectPhrase ( ObjectMarker ObjectPhrase {% ([marker, object]) => ({ marker, ...object }) %} ):*
	{% ([e, object, objects]) => [{ marker: e, ...object }, ...objects] %}

ObjectMarker -> "e" {% id %}
	| "anu" {% id %}

ObjectPhrase -> Phrase PrepositionPhrase:* {% ([object, prepositions]) => ({ type: "object", object, prepositions }) %}



PrepositionPhrase -> Preposition Phrase
	{% ([preposition, phrase]) => ({ type: "preposition_phrase", preposition, phrase }) %}

Preposition -> %word_preposition "ala":?
	{% ([preposition, negated]) => ({ type: "preposition", preposition, negated }) %}


Phrase -> Head Modifiers
	{% ([head, modifiers]) => ({ type: "phrase", head, modifiers }) %}

Modifiers -> ModifierWord:* NumberPhrase:? NanpaPhrase:* PiPhrase:* {% idModifiers %}

ModifiersOneRequired -> ModifierWord:+ NumberPhrase:? NanpaPhrase:* PiPhrase:* {% idModifiers %}
	| NumberPhrase NanpaPhrase:* PiPhrase:* {% idModifiers %}
	| NanpaPhrase:+ PiPhrase:* {% idModifiers %}
	| PiPhrase:+ {% idModifiers %}

NanpaPhrase -> "nanpa" NumberPhrase
	{% ([nanpa, number]) => ({ type: "nanpa_phrase", nanpa, number }) %}
PiPhrase -> "pi" Head ModifiersOneRequired
	{% ([pi, head, modifiers]) => ({ type: "pi_phrase", pi, head, modifiers }) %}

NumberPhrase -> %word_number:+
	{% ([tokens]) => ({ type: "number", tokens }) %}

Head -> %word_content {% id %}
	| %word_preposition {% id %}
	| %word_preverb {% id %}
	| %word_number {% id %}
	| %word_unmarked_subject {% id %}
MarkedSubjectHead -> %word_content {% id %}
	| %word_preposition {% id %}
	| %word_preverb {% id %}
	| %word_number {% id %}
ModifierWord -> Head {% id %}
	| %word_modifier_only {% id %}
