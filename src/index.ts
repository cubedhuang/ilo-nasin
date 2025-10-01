export * from "./parser.js";
export * from "./tag.js";
export * from "./types.js";

import { parse, type Result } from "./parser.js";
import { tagTree, type TaggedWord } from "./tag.js";

export type TagResult = {
	words: TaggedWord[];
	error: string | null;
};

export function tagSentence(text: string): TagResult {
	let results: Result[] = [];
	let error: string | null = null;

	try {
		results = parse(text);
	} catch (e) {
		error = (e as Error).message;
	}

	if (results.length === 0 && !error) {
		error = "Unexpected end of input";
	}

	return {
		words: results.length ? tagTree(results[0]!.tree) : [],
		error,
	};
}
