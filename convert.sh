#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERTER="$SCRIPT_DIR/skill-converter.md"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <claude-skill.md> [output.md]" >&2
  echo "" >&2
  echo "Converts a Claude-native skill file into Gemini-optimized System" >&2
  echo "Instructions by piping skill-converter.md + input to 'gemini -p'." >&2
  echo "If [output.md] is omitted, result is written to stdout." >&2
  exit 1
fi

INPUT="$1"
OUTPUT="${2:-/dev/stdout}"

if [ ! -f "$CONVERTER" ]; then
  echo "error: missing $CONVERTER" >&2
  exit 1
fi

if [ ! -f "$INPUT" ]; then
  echo "error: input file not found: $INPUT" >&2
  exit 1
fi

if ! command -v gemini >/dev/null 2>&1; then
  echo "error: 'gemini' CLI not found on PATH (https://github.com/google-gemini/gemini-cli)" >&2
  exit 1
fi

{
  echo "## SYSTEM INSTRUCTIONS"
  cat "$CONVERTER"
  echo
  echo "## CLAUDE SKILL TO CONVERT"
  cat "$INPUT"
} | gemini -p "Apply the SYSTEM INSTRUCTIONS above to convert the CLAUDE SKILL TO CONVERT. Output ONLY the converted Markdown — no preamble, no code fences." > "$OUTPUT"
