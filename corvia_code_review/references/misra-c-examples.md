# MISRA C:2012 Example Suite 使用指南

這個目錄包含 MISRA C:2012 官方範例套件（`Example-Suite-master/`），由 HORIBA MIRA Limited 發布。
審查 C 程式碼時，請根據需要查閱對應的範例檔案來確認某個寫法是否符合規範。

---

## 檔案命名規則

| 格式 | 說明 | 範例 |
|------|------|------|
| `R_XX_YY.c` | Required Rule XX.YY 的範例 | `R_14_01.c` = Rule 14.1 |
| `D_XX_YY.c` | Directive XX.YY 的範例 | `D_04_05.c` = Directive 4.5 |
| `R_XX_system.c` | Section XX 跨翻譯單元分析用的 main 函式 | |
| `R_XX_support.c` | Section XX 輔助呼叫函式 | |

每個 `.c` 檔案都有兩種標記：
- `/* Compliant */` — 符合規範的寫法
- `/* Non-compliant */` — 違反規範的寫法

---

## 常用規則對照表

| 規則 | 主題 | 範例檔案 |
|------|------|----------|
| Rule 1.1 | C 語法合規性 | R_01_01.c |
| Rule 2.1 | 不可達程式碼 | R_02_01.c |
| Rule 5.x | 識別子命名（命名衝突、長度）| R_05_01.c … R_05_09.c |
| Rule 7.x | 字面值 | R_07_01.c … R_07_04.c |
| Rule 8.x | 宣告與定義（外部連結、型別等）| R_08_01.c … R_08_14.c |
| Rule 9.x | 初始化 | R_09_01.c … R_09_05.c |
| Rule 10.x | 基本型別轉換 | R_10_01.c … R_10_08.c |
| Rule 11.x | 指標轉換 | R_11_01.c … R_11_09.c |
| Rule 12.x | 副作用 | R_12_01.c … R_12_05.c |
| Rule 13.x | 邏輯運算子 | R_13_01.c … R_13_06.c |
| Rule 14.x | 控制流（浮點迴圈計數器等）| R_14_01.c … R_14_04.c |
| Rule 15.x | switch / goto | R_15_01.c … R_15_07.c |
| Rule 16.x | switch 語句 | R_16_01.c … R_16_07.c |
| Rule 17.x | 函式（遞迴等）| R_17_01.c … R_17_08.c |
| Rule 18.x | 指標算術 | R_18_01.c … R_18_08.c |
| Rule 19.x | 覆疊的儲存空間 | R_19_01.c … R_19_02.c |
| Rule 20.x | 前處理器指令 | R_20_01.c … R_20_14.c |
| Rule 21.x | 標準函式庫 | R_21_01.c … R_21_20.c |
| Rule 22.x | 資源管理 | R_22_01.c … R_22_10.c |
| Directive 1.x | 可移植性 | D_01_01.c |
| Directive 2.x | 文件化 | D_02_01.c |
| Directive 3.x | 語言擴充 | D_03_01.c |
| Directive 4.x | 設計/實作 | D_04_01.c … D_04_14.c |

---

## 如何在審查時使用這些範例

### 情境 1：看到可疑的寫法，想確認是否違規

1. 判斷可能違反哪條規則（例如：浮點迴圈計數器 → Rule 14.1）
2. 開啟對應檔案：`Example-Suite-master/R_14_01.c`
3. 找到 `/* Non-compliant */` 的標記，確認是否與被審查的程式碼相符
4. 引用規則編號於報告中

### 情境 2：想知道正確寫法

1. 在同一個 `.c` 檔案中找 `/* Compliant */` 的標記
2. 建議修正時附上規則編號與說明

### 情境 3：MISRA C 審查模式

當使用者明確要求做 MISRA C 審查時（例如「幫我做 MISRA C 審查」、「這段 C code 符合 MISRA 嗎」），請：
1. 系統性地逐條對照相關規則的範例檔案
2. 每個違規項目都標明對應的規則編號（如 `[MISRA C:2012 Rule 14.1]`）
3. 引用範例套件的 Compliant 寫法作為修正建議

---

## 注意事項

- 這套範例**不是完整的測試套件**，僅用於理解各規則的精神
- 範例假設 32-bit 整數（char=8bit, short=16bit, int=32bit, long=64bit）
- 部分檔案需跨翻譯單元分析（見 `*_system.c` 和 `*_support.c`）
