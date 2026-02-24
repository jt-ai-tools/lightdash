---
name: developing-in-lightdash
description: 建立、配置與部署 Lightdash 分析專案。支援嵌入 Lightdash 元資料的 dbt 專案，以及不含 dbt 的純 Lightdash YAML 專案。使用 Lightdash CLI 建立指標 (metrics)、維度 (dimensions)、圖表 (charts) 與儀表板 (dashboards)。
---

# 在 Lightdash 中開發 (Developing in Lightdash)

建立並部署 Lightdash 分析專案。此技能涵蓋了**語義層 (semantic layer)** (指標、維度、關聯) 以及**內容 (content)** (圖表、儀表板)。

## 您可以做什麼

| 任務 | 指令 | 參考資料 |
|------|----------|------------|
| 探索資料倉庫 | `lightdash sql` 執行原始 SQL，讀取 .csv 結果 | [CLI 參考](./resources/cli-reference_zh_TW.md) |
| 定義指標與維度 | 編輯 dbt YAML 或 Lightdash YAML | [指標](./resources/metrics-reference_zh_TW.md), [維度](./resources/dimensions-reference_zh_TW.md) |
| 建立圖表 | `lightdash download` 下載，編輯 YAML，`lightdash upload` 上傳 | [圖表類型](#圖表類型) |
| 建立儀表板 | `lightdash download` 下載，編輯 YAML，`lightdash upload` 上傳 | [儀表板參考](./resources/dashboard-reference_zh_TW.md) |
| 檢查 YAML 檔案 (Lint) | `lightdash lint` | [CLI 參考](./resources/cli-reference_zh_TW.md) |
| 部署變更 | `lightdash deploy` (語義層)，`lightdash upload` (內容) | [CLI 參考](./resources/cli-reference_zh_TW.md) |
| 測試變更 | `lightdash preview` | [工作流程](./resources/workflows-reference_zh_TW.md) |

## 在您開始之前

### 檢查您的目標專案

**務必確認您正在部署到哪個專案。** 部署到錯誤的專案可能會覆蓋生產環境的內容。

```bash
# 檢查目前專案
lightdash config get-project

# 列出可用專案
lightdash config list-projects

# 切換到正確專案
lightdash config set-project --name "My Project"
```

### 偵測您的專案類型

**不同專案類型的 YAML 語法有顯著差異。**

| 類型 | 偵測方式 | 關鍵差異 |
|------|-----------|----------------|
| **dbt 專案** | 包含 `dbt_project.yml` | 元資料嵌套在 `meta:` 下 |
| **純 Lightdash** | 包含 `lightdash.config.yml`，無 dbt | 頂層屬性 |

```bash
# 快速偵測
ls dbt_project.yml 2>/dev/null && echo "dbt project" || echo "Not dbt"
ls lightdash.config.yml 2>/dev/null && echo "Pure Lightdash" || echo "Not pure Lightdash"
```

### 語法比較

**dbt YAML** (元資料位於 `meta:` 下)：
```yaml
models:
  - name: orders
    meta:
      metrics:
        total_revenue:
          type: sum
          sql: "${TABLE}.amount"
    columns:
      - name: status
        meta:
          dimension:
            type: string
```

**純 Lightdash YAML** (位於頂層)：
```yaml
type: model
name: orders
sql_from: 'DB.SCHEMA.ORDERS'

metrics:
  total_revenue:
    type: sum
    sql: ${TABLE}.amount

dimensions:
  - name: status
    sql: ${TABLE}.STATUS
    type: string
```

## 核心工作流程

### 編輯指標與維度

1. **尋找模型 YAML 檔案** (dbt: `models/*.yml`，純 Lightdash: `lightdash/models/*.yml`)
2. 根據您的專案類型，使用正確語法**編輯指標/維度**。
3. **驗證**：執行 `lightdash lint` (純 Lightdash) 或 `dbt compile` (dbt 專案)。
4. **部署**：執行 `lightdash deploy`。

有關配置選項，請參閱[指標參考](./resources/metrics-reference_zh_TW.md)和[維度參考](./resources/dimensions-reference_zh_TW.md)。

### 編輯圖表

1. **下載**：`lightdash download --charts chart-slug`
2. **編輯** `lightdash/` 目錄中的 YAML 檔案。
3. **上傳**：`lightdash upload --charts chart-slug`

### 編輯儀表板

1. **下載**：`lightdash download --dashboards dashboard-slug`
2. **編輯** `lightdash/` 目錄中的 YAML 檔案。
3. **上傳**：`lightdash upload --dashboards dashboard-slug`

### 建立新內容

圖表和儀表板通常先在 UI 中建立，然後再作為程式碼進行管理：

1. 在 UI 中建立。
2. 執行 `lightdash download` 以 YAML 格式抓取。
3. 編輯並進行版本控制。
4. 執行 `lightdash upload` 同步變更。

### 使用預覽進行測試

對於較大的變更，請在隔離環境中測試：

```bash
lightdash preview --name "my-feature"
# 進行修改並迭代
lightdash stop-preview --name "my-feature"
```

## CLI 快速參考

| 指令 | 用途 |
|---------|---------|
| `lightdash deploy` | 同步語義層 (指標、維度) |
| `lightdash upload` | 上傳圖表/儀表板 |
| `lightdash download` | 以 YAML 格式下載圖表/儀表板 |
| `lightdash lint` | 在本地端驗證 YAML |
| `lightdash preview` | 建立臨時測試專案 |
| `lightdash sql "..." -o file.csv` | 對資料倉庫執行 SQL 查詢 |

有關完整的指令說明，請參閱 [CLI 參考](./resources/cli-reference_zh_TW.md)。

## 語義層概覽 (Semantic Layer Overview)

語義層定義了您的資料模型：哪些內容可以被查詢，以及如何查詢。

### 資料表 (探索 - Explores)

資料表是定義了可查詢實體的 dbt 模型或 Lightdash YAML 模型。

```yaml
# dbt 範例
models:
  - name: orders
    meta:
      label: "訂單"
      joins:
        - join: customers
          sql_on: "${orders.customer_id} = ${customers.customer_id}"
```

有關所有選項，請參閱[資料表參考](./resources/tables-reference_zh_TW.md)。

### 指標 (Metrics)

對資料進行的聚合計算 (總和、計數、平均值等)。

```yaml
metrics:
  total_revenue:
    type: sum
    sql: "${TABLE}.amount"
    format: "usd"
```

**常見類型：** `count`, `count_distinct`, `sum`, `average`, `min`, `max`, `number` (自定義 SQL)

有關所有類型和選項，請參閱[指標參考](./resources/metrics-reference_zh_TW.md)。

### 維度 (Dimensions)

用於分組和篩選資料的屬性。

```yaml
columns:
  - name: created_at
    meta:
      dimension:
        type: timestamp
        time_intervals: [DAY, WEEK, MONTH, YEAR]
```

**類型：** `string`, `number`, `boolean`, `date`, `timestamp`

有關包含時間間隔在內的所有選項，請參閱[維度參考](./resources/dimensions-reference_zh_TW.md)。

### 關聯 (Joins)

連接相關資料表以進行跨表分析。

```yaml
joins:
  - join: customers
    sql_on: "${orders.customer_id} = ${customers.customer_id}"
    type: left
```

有關配置選項，請參閱[關聯參考](./resources/joins-reference_zh_TW.md)。

## 圖表類型

Lightdash 支援 9 種圖表類型，每一種都有專門的參考文件：

| 類型 | 使用案例 | 參考資料 |
|------|----------|-----------|
| `cartesian` | 長條圖、摺線圖、面積圖、散佈圖 | [笛卡爾圖表](./resources/cartesian-chart-reference_zh_TW.md) |
| `pie` | 部分與整體的關係 | [圓餅圖](./resources/pie-chart-reference_zh_TW.md) |
| `table` | 資料表格 | [表格圖表](./resources/table-chart-reference_zh_TW.md) |
| `big_number` | KPI 指標 | [大數字](./resources/big-number-chart-reference_zh_TW.md) |
| `funnel` | 轉換漏斗 | [漏斗圖](./resources/funnel-chart-reference_zh_TW.md) |
| `gauge` | 進度指示器 | [量表圖](./resources/gauge-chart-reference_zh_TW.md) |
| `treemap` | 階層式資料 | [矩形式樹狀圖](./resources/treemap-chart-reference_zh_TW.md) |
| `map` | 地理資料 | [地圖圖表](./resources/map-chart-reference_zh_TW.md) |
| `custom` | Vega-Lite | [自定義視覺化](./resources/custom-viz-reference_zh_TW.md) |

有關 YAML 結構和配置選項，請參閱各個圖表類型的參考文件。

## 儀表板 (Dashboards)

儀表板在網格佈局中安排圖表和內容。有關 YAML 結構、圖塊類型、分頁和篩選器，請參閱[儀表板參考](./resources/dashboard-reference_zh_TW.md)。

## 探索資料倉庫

建立模型時，使用 `lightdash sql` 探索資料：

```bash
# 預覽資料表結構
lightdash sql "SELECT * FROM orders LIMIT 5" -o preview.csv

# 檢查某個維度的不重複數值
lightdash sql "SELECT DISTINCT status FROM orders" -o statuses.csv

# 測試指標計算
lightdash sql "SELECT SUM(amount) FROM orders" -o test.csv
```

## 工作流程模式

| 模式 | 何時使用 |
|---------|-------------|
| **直接 (Direct)** (`deploy` + `upload`) | 獨立開發、快速迭代 |
| **預覽優先 (Preview-First)** | 團隊協作、複雜變更 |
| **CI/CD** | 合併時自動執行 |

有關詳細範例和 CI/CD 配置，請參閱[工作流程參考](./resources/workflows-reference_zh_TW.md)。

## 資源

### 語義層
- [維度參考](./resources/dimensions-reference_zh_TW.md)
- [指標參考](./resources/metrics-reference_zh_TW.md)
- [資料表參考](./resources/tables-reference_zh_TW.md)
- [關聯參考](./resources/joins-reference_zh_TW.md)

### 圖表
- [笛卡爾圖表參考](./resources/cartesian-chart-reference_zh_TW.md) - 長條圖、摺線圖、面積圖、散佈圖
- [圓餅圖參考](./resources/pie-chart-reference_zh_TW.md)
- [表格圖表參考](./resources/table-chart-reference_zh_TW.md)
- [大數字參考](./resources/big-number-chart-reference_zh_TW.md)
- [漏斗圖參考](./resources/funnel-chart-reference_zh_TW.md)
- [量表圖參考](./resources/gauge-chart-reference_zh_TW.md)
- [矩形式樹狀圖參考](./resources/treemap-chart-reference_zh_TW.md)
- [地圖圖表參考](./resources/map-chart-reference_zh_TW.md)
- [自定義視覺化參考](./resources/custom-viz-reference_zh_TW.md)

### 儀表板與工作流程
- [儀表板參考](./resources/dashboard-reference_zh_TW.md)
- [儀表板最佳實踐](./resources/dashboard-best-practices_zh_TW.md)
- [CLI 參考](./resources/cli-reference_zh_TW.md)
- [工作流程參考](./resources/workflows-reference_zh_TW.md)

### 外部連結
- [Lightdash 官方文件](https://docs.lightdash.com)
