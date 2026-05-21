# corvia_code_review

> **Version:** v1.4.0

A two-phase, multi-agent code review skill for C/C++ and Python projects.
Combines Corvia static analysis with four parallel Claude deep-analysis agents
to deliver a unified report covering bugs, security, and style.

---

## Overview

```
Phase 1 — Corvia Static Analysis
  └── corvia-agent        MISRA C:2012, null-deref, memory leak, buffer overflow, ...

Phase 2 — Claude Deep Analysis (4 agents in parallel)
  ├── line-bug-agent      Line-level: dead boolean, off-by-one, type misuse, control flow
  ├── bug-agent           Cross-function: dataflow bugs, loop-index after break, unhandled errors
  ├── security-agent      OWASP, crypto, trust boundaries, injection, sensitive data
  └── style-agent         Naming, documentation, complexity, magic numbers
```

Phase 2 agents receive Corvia's findings so they can focus on what static analysis missed — no duplication.

---

## Trigger Phrases

| Language | Phrase |
|----------|--------|
| 中文 | `幫我做完整的 code review` |
| 中文 | `全面審查` |
| 中文 | `深度分析程式碼` |
| English | `comprehensive review` |
| English | `review my project` |
| English | `multi-agent review` |
| Direct | `/corvia_code_review` |

---

## Workflow

```
Step 0  Record start time
Step 1  Select scope  [1] 整個專案  [2] Git uncommitted  [3] VSCode files  [4] Custom path
Step 2  Select phases  Phase 1 / Phase 2 / Both  (defaults vary by scope)
Step 3  Gather targets & code
Step 4  Execute Phase 1 (Corvia) and/or Phase 2 (4 Claude agents in parallel)
Step 5  Merge & deduplicate findings
Step 6  Output report → saved as <target>_corvia_review.md
```

### Default Phase Selection by Scope

| Scope | Phase 1 | Phase 2 |
|-------|:-------:|:-------:|
| 整個專案 | ✅ | ❌ |
| Git uncommitted | ✅ | ✅ |
| VSCode files | ✅ | ✅ |
| Custom target | ✅ | ✅ |

---

## Installation

```bash
# Install to Claude Code skills directory
cp -r corvia_code_review ~/.claude/skills/
```

### Corvia Dependency (Phase 1)

```bash
pip install "corvia[mcp] @ git+https://github.com/kevintsou/Corvia.git"
```

If no `corvia.toml` is found in the target project, the skill auto-detects
the project type and copies the matching template from the installed package:

| Signal | Template used |
|--------|--------------|
| `.cproject` file found | `corvia.toml.ds5` (Eclipse CDT / ARM DS-5) |
| Path contains `PS5801` / `PT5801` / `phison` | `corvia.toml.ps5801` (Phison SoC) |
| No match | Prompts user to choose, or generates minimal fallback |

---

## Report Structure

```
🔍 Multi-Agent Code Review Report
  Skill 版本 / 審查範圍 / 執行 Phase / 規則來源

Phase 1 — 靜態分析結果 (Corvia)
  Table: severity | file:line | checker | message

Phase 2 — 深度分析結果 (Claude Agents)
  🔍 Line-Level Bug Issues    (line-bug-agent)
  🐛 Bug & Logic Issues       (bug-agent)
  🔐 Security Issues          (security-agent)
  🎨 Style & Maintainability  (style-agent)

📊 總結
  Overall verdict / issue counts table / top offending files / 行動建議

⏱️ 執行時間
  Start / End / Total elapsed
```

Report is saved as: `<target_name>_corvia_review.md` in the target directory.

---

## File Structure

```
corvia_code_review/
├── SKILL.md                    Orchestrator — main workflow
├── README.md                   This file
├── agents/
│   ├── corvia-agent.md         Phase 1: Corvia static analysis
│   ├── line-bug-agent.md       Phase 2: line-level bug detection
│   ├── bug-agent.md            Phase 2: cross-function bug detection
│   ├── security-agent.md       Phase 2: security analysis
│   └── style-agent.md          Phase 2: style & maintainability
├── monitoring/
│   ├── README.md
│   ├── Wait-Agents.ps1         PowerShell monitoring script
│   ├── wait_agents.py          Python monitoring script (cross-platform)
│   └── wait-agents.sh          Bash monitoring script
└── evals/
    └── evals.json
```

---

## Changelog

| Version | Changes |
|---------|---------|
| v1.4.0 | Update corvia-agent for Corvia v0.2.5: new install command, pre-flight `corvia.toml` auto-setup with template matching, simplified run flags |
| v1.3.0 | Add execution time tracking; add version number to report header |
| v1.2.x | Add `line-bug-agent` as 4th parallel Phase 2 agent; update report template with line-level bug section |
| v1.1.x | Switch all paths to relative references |
| v1.0.0 | Initial release: Phase 1 (Corvia) + Phase 2 (3 agents: bug, security, style) |
