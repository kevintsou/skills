#!/bin/bash
# Wait for Phase 2 agents to complete
# Usage: ./wait-agents.sh <timeout_seconds>

TIMEOUT=${1:-600}  # Default 10 minutes
TEMP_DIR="${CLAUDE_TEMP_DIR:-/tmp/claude-tasks}"

# Agent task IDs (update these as needed)
AGENTS=(
    "ad18b41a80c0d1de0"  # Bug Agent
    "a842e402b5e13aa86"  # Security Agent
    "aee5e5ec6b0c44dcc"  # Style Agent
)

START_TIME=$(date +%s)
CHECK_INTERVAL=5

echo "Waiting for Phase 2 agents to complete (timeout: ${TIMEOUT}s)..."
echo "Agents: ${AGENTS[@]}"
echo ""

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))

    # Check timeout
    if [ $ELAPSED -gt $TIMEOUT ]; then
        echo "TIMEOUT: Agents did not complete within ${TIMEOUT} seconds"
        exit 1
    fi

    # Check each agent status
    ALL_DONE=true
    for AGENT in "${AGENTS[@]}"; do
        if [ -f "${TEMP_DIR}/${AGENT}.output" ]; then
            SIZE=$(stat -f%z "${TEMP_DIR}/${AGENT}.output" 2>/dev/null || stat -c%s "${TEMP_DIR}/${AGENT}.output" 2>/dev/null || echo "0")
            echo "[$AGENT] $(printf "%6d" $SIZE) bytes | Elapsed: ${ELAPSED}s"
            if [ "$SIZE" -eq 0 ]; then
                ALL_DONE=false
            fi
        else
            echo "[$AGENT] Waiting to start... | Elapsed: ${ELAPSED}s"
            ALL_DONE=false
        fi
    done

    if [ "$ALL_DONE" = true ]; then
        echo ""
        echo "✅ All agents have completed!"
        exit 0
    fi

    echo "---"
    sleep $CHECK_INTERVAL
done
