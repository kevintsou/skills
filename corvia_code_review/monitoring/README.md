# Agent Monitoring Scripts

Tools to monitor Phase 2 agent completion and collect results.

## Available Scripts

### 1. PowerShell Version (Windows Recommended)
```powershell
.\Wait-Agents.ps1 -Timeout 600 -CheckInterval 5
```

**Features:**
- ✅ Works natively on Windows
- ✅ Color-coded output (Green/Yellow/Red)
- ✅ Formatted file sizes
- ✅ Real-time status updates
- ✅ Graceful timeout handling

**Parameters:**
- `-Timeout` (default: 600s) - Maximum wait time
- `-CheckInterval` (default: 5s) - How often to check status
- `-Agents` - List of agent task IDs to monitor

**Example:**
```powershell
.\Wait-Agents.ps1 -Timeout 300 -CheckInterval 3
```

---

### 2. Python Version (Cross-Platform)
```bash
python wait_agents.py --timeout 600 --interval 5
```

**Features:**
- ✅ Works on Windows, macOS, Linux
- ✅ Emoji status indicators
- ✅ Human-readable file sizes
- ✅ Command-line argument parsing
- ✅ Graceful error handling

**Parameters:**
- `--timeout` (default: 600) - Maximum wait time in seconds
- `--interval` (default: 5) - Check interval in seconds
- `--agents` - Space-separated list of agent IDs

**Example:**
```bash
python wait_agents.py --timeout 300 --agents ad18b41a80c0d1de0 a842e402b5e13aa86
```

---

### 3. Bash Version (Unix/Linux/macOS)
```bash
./wait-agents.sh 600
```

**Features:**
- ✅ Lightweight, minimal dependencies
- ✅ Simple and portable
- ✅ Works on Unix-like systems

**Usage:**
```bash
./wait-agents.sh <timeout_seconds>
```

---

## How to Use with Multi-Agent Skill

When launching Phase 2 agents in parallel, monitor their progress:

```powershell
# Start agents in background
$bug = Start-Job -ScriptBlock { & python -m your_bug_agent }
$sec = Start-Job -ScriptBlock { & python -m your_security_agent }
$style = Start-Job -ScriptBlock { & python -m your_style_agent }

# Wait for completion
.\Wait-Agents.ps1 -Timeout 600
```

---

## Output Examples

### PowerShell Output
```
Waiting for Phase 2 agents to complete (timeout: 600s)...
Agents: ad18b41a80c0d1de0, a842e402b5e13aa86, aee5e5ec6b0c44dcc

[ad18b41a80c0d1de0]      0 bytes | Elapsed: 0s
[a842e402b5e13aa86] Waiting to start... | Elapsed: 0s
[aee5e5ec6b0c44dcc] Waiting to start... | Elapsed: 0s
---
[ad18b41a80c0d1de0]  45234 bytes | Elapsed: 45s
[a842e402b5e13aa86]  78921 bytes | Elapsed: 45s
[aee5e5ec6b0c44dcc] Waiting to start... | Elapsed: 45s
---
✅ All agents have completed!
```

### Python Output
```
⏳ Waiting for Phase 2 agents to complete (timeout: 600s)...
📁 Output directory: C:\Users\<username>\AppData\Local\Temp\claude\...\tasks
🤖 Agents: ad18b41a80c0d1de0, a842e402b5e13aa86, aee5e5ec6b0c44dcc

[14:32:15] Status (elapsed: 0s)
  ⏳ [ad18b41a80c0d1de0] Waiting to start...
  ⏳ [a842e402b5e13aa86] Waiting to start...
  ⏳ [aee5e5ec6b0c44dcc] Waiting to start...

[14:32:20] Status (elapsed: 5s)
  🔄 [ad18b41a80c0d1de0] Running (0 bytes)
  ⏳ [a842e402b5e13aa86] Waiting to start...
  ⏳ [aee5e5ec6b0c44dcc] Waiting to start...

[14:32:45] Status (elapsed: 30s)
  ✅ [ad18b41a80c0d1de0] Complete (45.2KB)
  ✅ [a842e402b5e13aa86] Complete (78.9KB)
  ✅ [aee5e5ec6b0c44dcc] Complete (123.5KB)

🎉 All agents have completed!
```

---

## Troubleshooting

### Script doesn't find output directory
- Set environment variable: `$env:CLAUDE_TEMP_DIR = "C:\path\to\tasks"`
- Or modify the default path in the script

### Agents timeout
- Increase `--timeout` parameter: `.\Wait-Agents.ps1 -Timeout 1200` (20 minutes)
- Check if agents are actually running in background

### No output files appearing
- Verify agent task IDs are correct
- Check that agents were launched with correct IDs
- Ensure temporary directory has write permissions

---

## Integration with Multi-Agent Skill

Add to `SKILL.md`:
```
## Phase 2 Monitoring

After launching Phase 2 agents, monitor their completion:

**PowerShell:**
```powershell
& "monitoring/Wait-Agents.ps1" -Timeout 600
```

**Python:**
```bash
python "monitoring/wait_agents.py" --timeout 600
```
```

---

## Notes

- Default timeout: 10 minutes (600 seconds)
- Check interval: 5 seconds (adjustable)
- Scripts are idempotent - safe to run multiple times
- Output files are in JSONL format (one JSON object per line)

