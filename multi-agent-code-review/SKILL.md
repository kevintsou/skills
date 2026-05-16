---
name: multi-agent-code-review
description: >
  Comprehensive multi-agent code review for C/C++ and Python projects.
  Combines Corvia static analysis (Phase 1) with parallel Claude deep-analysis
  agents for bugs, security, and style (Phase 2).
  Trigger on: "幫我做完整的 code review", "全面審查", "comprehensive review",
  "深度分析程式碼", "review my project", "multi-agent review",
  or any request for thorough code analysis covering bugs, security, and style together.
  Prefer this skill over the single-agent code-review when the user wants a
  multi-dimensional, in-depth review rather than a quick check.
---

# Multi-Agent Code Review — Orchestrator

You are the orchestrator of a two-phase, multi-agent code review pipeline.
Your job is to gather the user's intent, coordinate the worker agents, merge their
findings, and deliver a unified report.

The two existing skills remain untouched and independent:
- `code-review` (single-agent, Python/C manual review)
- `corvia-review` (single-agent, Corvia CLI)

This skill **combines** both approaches and adds parallel Claude agents on top.

---

## Step 1 — Scope Selection

Present the following options to the user:

```
請選擇審查範圍：

[1] 整個專案          — 掃描整個工作目錄（僅 Phase 1，速度快）
[2] Git uncommitted   — 只看本次尚未 commit 的異動
[3] VSCode 開啟的檔案 — 審查目前 extension 帶入的檔案
[4] 自訂目標          — 手動指定檔案或資料夾路徑
```

Wait for the user's answer before proceeding.

For **Scope 4**, ask: "請輸入目標路徑（可多個，空格分隔）："
Then store the input as `<custom_targets>`.

---

## Step 2 — Phase Selection

After scope is confirmed, show the default phase configuration and let the user override:

```
請確認要執行的 Phase：

[Phase 1] Corvia 靜態分析   <預設值>
[Phase 2] Claude 深度分析   <預設值>

直接 Enter 接受預設，或輸入 "1", "2", "1 2" 來指定：
```

**Default values by scope:**

| Scope | Phase 1 預設 | Phase 2 預設 |
|-------|:-----------:|:-----------:|
| 1. 整個專案 | ✅ | ❌ |
| 2. Git uncommitted | ✅ | ✅ |
| 3. VSCode 檔案 | ✅ | ✅ |
| 4. 自訂目標 | ✅ | ✅ |

If the user deselects both phases, respond:
> "至少需要選擇一個 Phase。請重新選擇。"
Then re-prompt Step 2.

---

## Step 3 — Gather Code and Targets

Based on the confirmed scope, collect what's needed before spawning agents.

### Scope 1 — 整個專案
```bash
pwd
```
`<target>` = current working directory.

### Scope 2 — Git uncommitted
```bash
git diff HEAD --name-only
git diff HEAD
```
`<target_files>` = list of changed file paths.
`<diff_content>` = full diff text (passed to Phase 2 agents as context).

If `git diff HEAD` returns nothing, also check staged-only:
```bash
git diff --cached --name-only
git diff --cached
```

If no changes are found at all, inform the user and stop.

### Scope 3 — VSCode 開啟的檔案
The file content is already in your context (brought in by the VSCode Claude Code
extension). Extract the file paths and content from context.
`<target_files>` = those file paths.
`<file_content>` = the code content already available.

### Scope 4 — 自訂目標
`<target>` = `<custom_targets>` from Step 1.

---

## Step 4 — Execute Phases

### Phase 1 — Corvia Static Analysis (if selected)

Read the agent instructions from:
`agents/corvia-agent.md`

Spawn a **Corvia Agent** subagent with the following context:
- Target: `<target>` or `<target_files>` from Step 3
- Instruction: follow `corvia-agent.md`
- Output: save structured results (JSON preferred) for Phase 2 consumption

Collect the output as `<corvia_results>`.

If Corvia is not installed and installation fails, set `<corvia_results>` = `null`
and note this in the final report. Do **not** abort — proceed to Phase 2 if selected.

---

### Phase 2 — Claude Deep Analysis (if selected)

Read each agent's instructions before spawning:
- `agents/line-bug-agent.md`
- `agents/bug-agent.md`
- `agents/security-agent.md`
- `agents/style-agent.md`

Spawn all **four agents in parallel** (same turn), each receiving:
- The target code content (files or diff from Step 3)
- `<corvia_results>` — so each agent knows what Corvia already found and can focus elsewhere
- Any `REVIEW_RULES.md` found in the project root or current directory

**Agent responsibilities (no overlap):**
| Agent | Focus |
|-------|-------|
| `line-bug-agent` | Line-by-line: dead boolean, off-by-one, type misuse, missing checks, single-function control flow |
| `bug-agent` | Cross-function: dataflow bugs, loop index after break, unhandled error paths, dynamic buffer overflows |
| `security-agent` | Security: OWASP, crypto, trust boundaries, injection, sensitive data |
| `style-agent` | Maintainability: naming, documentation, complexity, magic numbers |

Each agent returns a structured findings list. Collect as:
- `<line_bug_findings>`
- `<bug_findings>`
- `<security_findings>`
- `<style_findings>`

**Monitoring Phase 2 Completion:**

After spawning the three agents, you may optionally monitor their progress:

```powershell
# PowerShell (Windows)
& "monitoring/Wait-Agents.ps1" -Timeout 600
```

```bash
# Python (Cross-platform)
python "monitoring/wait_agents.py" --timeout 600
```

```bash
# Bash (Unix/Linux/macOS)
bash "monitoring/wait-agents.sh" 600
```

See `monitoring/README.md` for detailed usage instructions and troubleshooting.

---

## Step 5 — Merge and Deduplicate

Before writing the report, scan all findings for duplicates:
- If a Claude agent flagged an issue already caught by Corvia (same file + line + issue type),
  keep the Corvia entry and discard the duplicate from Phase 2.
- If a Claude agent provides additional context or a fix suggestion for a Corvia finding,
  annotate the Corvia entry with that context rather than creating a duplicate.

---

## Step 6 — Output the Final Report

### Save as Markdown File

After generating the report, **always save it as a `.md` file** using this naming rule:

```
<target_name>_corvia_review.md
```

Where `<target_name>` is derived from the scan target:
- **Single file** (e.g. `src/main.c`) → `main_corvia_review.md`
- **Directory** (e.g. `D:\repo\project\lcp`) → `lcp_corvia_review.md`
- **Git uncommitted** → `git_uncommitted_corvia_review.md`
- **VSCode files** → `vscode_files_corvia_review.md`

Save the file **in the same directory as the target** (or the current working directory if target is a single file or git diff).

Example save command:
```bash
# Target: D:\repo\project\lcp  → save as lcp_corvia_review.md in same directory
```

Then inform the user of the saved file path.

---

Use this exact structure:

---

## 🔍 Multi-Agent Code Review Report

**審查範圍：** `<scope description>`
**執行 Phase：** `<Phase 1 / Phase 2 / Both>`
**規則來源：** `<REVIEW_RULES.md path>` *(或 "general best practices")*

---

### Phase 1 — 靜態分析結果 (Corvia)
*(如未執行則標註 "未執行" 或 "安裝失敗")*

**總計：** X errors / Y warnings / Z info

| 嚴重度 | 檔案:行號 | Checker | 說明 |
|--------|-----------|---------|------|
| 🔴 error | ... | ... | ... |
| ⚠️ warning | ... | ... | ... |
| 💡 info | ... | ... | ... |

---

### Phase 2 — 深度分析結果 (Claude Agents)
*(如未執行則標註 "未執行")*

#### 🔍 Line-Level Bug Issues
*(Line-Bug Agent 發現：dead boolean、off-by-one、型別誤用、單函數控制流錯誤、防禦性缺失)*

**[Issue title]** — `file`, line XX
Severity: critical | warning
> 說明確切的變數、條件或表達式問題。
> 解釋為何有問題 — 哪個值造成失敗，後果是什麼。
> **建議修復：** ...

*(無則寫 "None")*

---

#### 🐛 Bug & Logic Issues
*(Bug Agent 發現：跨函數 dataflow、迴圈後索引使用、未處理錯誤路徑、動態 buffer overflow)*

**[Issue title]** — `file`, line XX
> 說明問題所在與影響。
> **建議修復：** ...

*(無則寫 "None")*

---

#### 🔐 Security Issues
*(Security Agent 發現)*

**[Issue title]** — `file`, line XX
> ...
> **建議修復：** ...

*(無則寫 "None")*

---

#### 🎨 Style & Maintainability
*(Style Agent 發現)*

- `file` line XX: ...

*(無則寫 "None")*

---

### 📊 總結

**Overall verdict：** ✅ Clean / ⚠️ Minor issues / 🔴 Needs fixes

| 類別 | 問題數 |
|------|--------|
| 🔴 Critical (Corvia errors + Bug Agent critical) | X |
| 🔍 Line-Level Bugs | X |
| ⚠️ Warnings | Y |
| 🔐 Security | Z |
| 💡 Style / Info | W |

**Top offending files：** *(列出問題最多的前 3 個檔案)*

**行動建議：** *(一段簡短的優先修復建議)*

---
