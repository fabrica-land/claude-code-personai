#!/bin/bash
# precompact.sh — Personai PreCompact hook
#
# Runs before context compaction. Backs up transcript and extracts
# recovery data for the boot sequence.
#
# Input (stdin JSON): session_id, transcript_path, cwd, trigger

set -euo pipefail

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_SCRIPT="$PLUGIN_ROOT/scripts/precompact-backup.sh"

if [ -f "$BACKUP_SCRIPT" ]; then
    echo "$INPUT" | bash "$BACKUP_SCRIPT" 2>&1 || true
fi
