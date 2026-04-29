# skills-convertor

Convert **Claude-native skill files** (XML-tagged Markdown with `<purpose>`, `<instructions>`, `<thinking>`, `{{VARIABLE}}` placeholders, etc.) into **Gemini-optimized System Instructions** (clean Markdown headers, flattened bullets, `[VARIABLE]` placeholders, no Anthropic-specific tone).

The repo ships a single system prompt — [`skill-converter.md`](./skill-converter.md) — that turns Gemini into a "Skill Migration Architect," plus a wrapper script and a worked example.

## What it does

Claude skills lean on XML tags for structure. Gemini's attention parses Markdown headers more reliably than custom XML. Running your existing `claude-skill.md` through `skill-converter.md` produces a portable Gemini skill: predictable header layout (`## Role & Context`, `## Core Instructions`, …), `[VAR]` placeholders, and direct task-oriented tone with no "helpful and harmless" filler.

## Quick start

Requires [`gemini`](https://github.com/google-gemini/gemini-cli) on your `PATH` and authenticated.

```bash
./convert.sh examples/claude-skill.md examples/gemini-skill.out.md
diff examples/gemini-skill.md examples/gemini-skill.out.md   # semantic, not byte-identical
```

Or stream to stdout:

```bash
./convert.sh examples/claude-skill.md
```

## Usage with `gemini-cli`

Three patterns, in order of convenience.

### 1. Wrapper script (recommended)

```bash
./convert.sh path/to/claude-skill.md path/to/gemini-skill.md
```

The script concatenates `skill-converter.md` + your input and pipes the result to `gemini -p` in headless mode.

### 2. Direct stdin pipe

If you don't want the wrapper:

```bash
{
  echo "## SYSTEM INSTRUCTIONS"
  cat skill-converter.md
  echo
  echo "## CLAUDE SKILL TO CONVERT"
  cat claude-skill.md
} | gemini -p "Apply the SYSTEM INSTRUCTIONS to convert the CLAUDE SKILL. Output only Markdown." > gemini-skill.md
```

### 3. `GEMINI.md` context file

`gemini-cli` auto-loads `GEMINI.md` from `~/.gemini/` and walks up the directory tree, concatenating all matches into the model's context. So you can install the converter globally:

```bash
mkdir -p ~/.gemini
cp skill-converter.md ~/.gemini/GEMINI.md       # or: ln -s "$PWD/skill-converter.md" ~/.gemini/GEMINI.md

gemini -p "$(cat claude-skill.md)" > gemini-skill.md
```

After that, any future `gemini` invocation in any directory has the converter rules loaded — useful if you migrate skills often. Use `/memory show` inside an interactive session to verify the context is loaded.

## Why this works

- **Directness.** The skill instructs Gemini to skip "Sure, I can help with that!" filler — essential for CLI/automation workflows.
- **Structure.** Gemini is highly sensitive to Markdown headers (`#`, `##`). Converting Claude's XML into headers lets Gemini's attention mechanism parse each section of the skill cleanly.

## Example

See [`examples/claude-skill.md`](./examples/claude-skill.md) (a Claude-style "Technical Blog Post Writer" using `<purpose>`, `<instructions>`, `<rules>`, `<examples>`, `<thinking>`, and `{{TOPIC}}` / `{{AUDIENCE}}` placeholders) and [`examples/gemini-skill.md`](./examples/gemini-skill.md) (the converted output) for what good output looks like.

## Layout

```
skills-convertor/
├── skill-converter.md       # the skill — the system prompt itself
├── convert.sh               # wrapper: ./convert.sh in.md [out.md]
├── README.md
├── examples/
│   ├── claude-skill.md      # sample input
│   └── gemini-skill.md      # converted reference output
└── .gitignore
```
