import Reveal from "reveal.js";
import Markdown from "reveal.js/plugin/markdown/markdown.esm";
import RevealMath from "reveal.js/plugin/math/math.esm";
import "reveal.js/dist/reveal.css";
import "reveal.js/dist/theme/sky.css";

Reveal.initialize({
	plugins: [Markdown, RevealMath.KaTeX],
	hash: true,
	progress: true,
	markdown: {
		smartypants: true,
	},
});
