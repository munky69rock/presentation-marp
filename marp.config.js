const { Marp } = require("@marp-team/marp-core");
const container = require("markdown-it-container");

function containerWithOptionalClasses(name, options = {}) {
  return [
    name,
    {
      render(tokens, idx) {
        const m = tokens[idx].info
          .trim()
          .match(new RegExp(String.raw`^${name}(?:\s+(.*))?$`));

        const additionalClasses = m?.[1] || "";

        if (tokens[idx].nesting === 1) {
          if (options.skipContainerName) {
            return `<div class="${additionalClasses}">`;
          }
          return `<div class="${name} ${additionalClasses}">`;
        }
        return "</div>\n";
      },
    },
  ];
}

module.exports = {
  html: true,
  engine: (opts) => {
    const marp = new Marp(opts);
    ["2", "3", "1-2", "2-1"].forEach((g) => marp.use(container, `grid${g}`));
    marp.use(container, ...containerWithOptionalClasses("grid-item"));
    marp.use(container, "spread");
    marp.use(
      container,
      ...containerWithOptionalClasses("classes", { skipContainerName: true })
    );
    return marp;
  },
  inputDir: "./slides",
  output: "./public",
  themeSet: "./themes",
};
