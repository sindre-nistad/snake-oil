import Reveal from "reveal.js";
import Highlight from "reveal.js/plugin/highlight/highlight.esm";
import Markdown from "reveal.js/plugin/markdown/markdown.esm";
import RevealMath from "reveal.js/plugin/math/math.esm";
import Notes from "reveal.js/plugin/notes/notes.esm";
import "./assets/atelier-dune-light.css";
import "reveal.js/dist/reveal.css";
import "reveal.js/dist/theme/sky.css";

Reveal.initialize({
	plugins: [Markdown, RevealMath.KaTeX, Notes, Highlight],
	hash: true,
	progress: true,
	markdown: {
		smartypants: true,
		hash: true,
		history: true,
	},
	totalTime: 25 /* minutes */ * 60 /* seconds */,
});
