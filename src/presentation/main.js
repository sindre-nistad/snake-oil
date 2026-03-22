import Reveal from "reveal.js";
import Highlight from "reveal.js/plugin/highlight";
import Markdown from "reveal.js/plugin/markdown";
import RevealMath from "reveal.js/plugin/math";
import Notes from "reveal.js/plugin/notes";
import "./assets/atelier-dune-light.css";
import "reveal.js/reveal.css";
import "reveal.js/theme/sky.css";

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
