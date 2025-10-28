// commitlint.config.cjs
// Conventional Commits with project-specific scopes
module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // enforce lowercase type and scope
    "type-case": [2, "always", "lower-case"],
    "scope-case": [2, "always", "kebab-case"],
    // subject cannot be empty and should be concise
    "subject-empty": [2, "never"],
    "subject-max-length": [2, "always", 100],
    // allowed types
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "build",
        "ci",
        "chore",
        "revert",
      ],
    ],
    // allowed scopes tailored to this repo
    "scope-enum": [
      2,
      "always",
      ["src", "scripts", "emoji-forge", "emoji-registry", "docs", "ci", "config", "release"],
    ],
  },
};
