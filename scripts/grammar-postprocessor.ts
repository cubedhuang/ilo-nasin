// https://github.com/toaq/kuna/blob/a18c585a791ae2dac47fa9e5deba3a7ef4725567/src/scripts/grammar-preprocessor.ts

/**
 * This tool processes a nearley.js grammar with "generics", such as
 *
 *      Foo<T> -> Bar<T> Hao<T>
 *      Example -> Foo<x>
 *      Mua -> Foo<y>
 *
 * and expands all the generic templates:
 *
 *      Foo_x -> Bar_x Hao_x
 *      Foo_y -> Bar_y Hao_y
 *      Example -> Foo_x
 *      Mua -> Foo_y
 *
 * Foo<A> (uppercase) is treated as a generic rule with a variable "A", and
 * Foo<b> (lowercase) is treated as an instantiation thereof with A = b.
 *
 * It also processes C-style `#ifdef FLAG / #else / #endif` directives.
 *
 * It's not very fancy, and uses regex to get the job done. It expects rules to
 * be contained in one line and only refer to at most one generic variable.
 */

import * as fs from "node:fs";

export function postprocess(file: string): string {
	return "// @ts-nocheck\n" + file;
}

function main(): void {
	const args = process.argv.slice(2);

	if (args.length < 2) {
		console.error(
			"Usage: grammar-postprocessor.ts <input-file> <output-file>",
		);
		process.exit(1);
	}

	const inputPath = args[0];
	const outputPath = args[1];
	console.log(`🍳 Postprocessing ${inputPath} into ${outputPath}.`);

	const contents: string = fs.readFileSync(inputPath, "utf-8");
	const converted = postprocess(contents);

	fs.writeFileSync(outputPath, converted, "utf-8");
	console.log("✨ Postprocessing complete.");
}

if (process.argv[1] === import.meta.url.substring(7)) {
	main();
}
