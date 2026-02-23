# 指標參考 (Metrics Reference)

指標是對數據執行的聚合計算。它們回答諸如「多少？」、「多少個？」以及「平均值是多少？」等問題。

## 指標定義位置

指標可以在兩個地方定義：

### 1. 欄位級別指標 (建議方式)

與特定欄位綁定：

```yaml
columns:
  - name: amount
    meta:
      dimension:
        type: number
      metrics:
        total_amount:
          type: sum
        average_amount:
          type: average
```

### 2. 模型級別指標

具備自定義 SQL 的獨立指標：

```yaml
models:
  - name: orders
    meta:
      metrics:
        revenue_per_customer:
          type: number
          sql: "SUM(${TABLE}.amount) / COUNT(DISTINCT ${TABLE}.customer_id)"
```

## 指標類型

### 聚合指標 (Aggregation Metrics)

| 類型 | 描述 | 是否需要 SQL |
|------|-------------|--------------|
| `count` | 計算所有行數 | 否 |
| `count_distinct` | 計算唯一值的數量 | 否 |
| `sum` | 數值總和 | 否 |
| `average` | 數值的平均值 | 否 |
| `min` | 最小值 | 否 |
| `max` | 最大值 | 否 |
| `percentile` | 百分位數值 | 否（需設定 `percentile:`） |
| `median` | 中位數（第 50 百分位數） | 否 |

### 自定義 SQL 指標

| 類型 | 描述 | 是否需要 SQL |
|------|-------------|--------------|
| `number` | 自定義數值計算 | 是 |
| `string` | 自定義字串結果 | 是 |
| `date` | 自定義日期結果 | 是 |
| `timestamp` | 自定義時間戳記結果 | 是 |
| `boolean` | 自定義布林結果 | 是 |

### 衍生指標 (Derived Metrics)

| 類型 | 描述 |
|------|-------------|
| `percent_of_previous` | 與前一行的百分比變化 |
| `percent_of_total` | 佔欄位總額的百分比 |
| `running_total` | 累計總和 |

## 配置選項

### 基本配置

```yaml
metrics:
  total_revenue:
    type: sum
    label: "總營收"
    description: "所有訂單金額的總和"
    hidden: false
```

### 格式化

```yaml
metrics:
  total_revenue:
    type: sum
    round: 2                    # 小數點位數
    format: "usd"               # 格式預設
    compact: "millions"         # 精簡顯示
```

**格式預設 (Format Presets)：**
- 貨幣：`usd`, `gbp`, `eur`
- 百分比：`percent`
- 距離：`km`, `mi`
- ID：`id`（不進行格式化）

**精簡選項 (Compact Options)：**
- 數值：`thousands`, `millions`, `billions`, `trillions`
- 位元組 (Bytes)：`kilobytes`, `megabytes`, `gigabytes`, `terabytes`

### 百分位數配置

```yaml
metrics:
  p95_response_time:
    type: percentile
    percentile: 95              # percentile 類型必填
    label: "P95 回應時間"
```

### 指標過濾器 (Metric Filters)

將過濾器套用於特定指標：

```yaml
metrics:
  completed_orders:
    type: count
    label: "已完成訂單"
    filters:
      - status: "completed"

  # 多個過濾條件
  high_value_completed:
    type: count
    filters:
      - status: "completed"
      - amount: "> 1000"
```

**過濾運算子：**
- 相等：`value`, `"value"`
- 比較：`"> 100"`, `"< 50"`, `">= 10"`, `"<= 100"`
- 多個值：`["value1", "value2"]`
- Null 檢查：`"null"`, `"!null"`
- 日期區間：`"inThePast N days"`, `"inTheNext N months"`（支援：`days`, `weeks`, `months`, `years`）

**日期過濾範例：**

```yaml
metrics:
  recent_orders:
    type: count
    filters:
      - created_at: "inThePast 30 days"

  upcoming_renewals:
    type: count
    filters:
      - renewal_date: "inTheNext 7 days"
```

**重要提示：** `inTheCurrent` 不是指標定義過濾器中的有效運算子。它僅在圖表和儀表板過濾器中可用。如果您在指標中需要當前週期的邏輯，請改用帶有日期截斷功能的自定義 SQL。

### 顯示底層數值 (Show Underlying Values)

配置用戶下鑽 (drill into) 指標時顯示的欄位：

```yaml
metrics:
  total_revenue:
    type: sum
    show_underlying_values:
      - order_id
      - customer_name
      - amount
      - created_at
```

### 組織架構

使用 `groups` 在側邊欄中組織指標：

```yaml
metrics:
  total_revenue:
    type: sum
    groups:
      - "營收指標"
```

對於階層式分組，可以添加多個層級：

```yaml
metrics:
  total_revenue:
    type: sum
    groups:
      - "財務"
      - "營收"
```

> **注意：** `group_label` 已過時。請改用 `groups`。

### 網址 (URLs)

為指標數值添加可點擊的連結：

```yaml
metrics:
  order_count:
    type: count
    urls:
      - label: "查看訂單"
        url: "/orders?customer_id=${row.customer_id}"
```

### 存取控制

```yaml
metrics:
  confidential_revenue:
    type: sum
    required_attributes:
      role: "finance"
```

### AI 提示 (AI Hints)

```yaml
metrics:
  total_revenue:
    type: sum
    ai_hint: "主要的營收指標 - 用於財務報告"
```

### 標籤 (Tags)

```yaml
metrics:
  total_revenue:
    type: sum
    tags:
      - "finance"
      - "kpi"
```

### 預設時間維度

將指標與時間維度關聯：

```yaml
metrics:
  total_revenue:
    type: sum
    default_time_dimension:
      field: created_at
      interval: MONTH
```

## 自定義 SQL 指標

### 模型級別自定義指標

```yaml
models:
  - name: orders
    meta:
      metrics:
        # 每個客戶的平均營收
        revenue_per_customer:
          type: number
          sql: "SUM(${TABLE}.amount) / NULLIF(COUNT(DISTINCT ${TABLE}.customer_id), 0)"
          round: 2
          format: "usd"

        # 轉化率
        conversion_rate:
          type: number
          sql: "COUNT(CASE WHEN ${TABLE}.status = 'completed' THEN 1 END)::float / NULLIF(COUNT(*), 0) * 100"
          round: 1
          description: "已完成訂單佔總訂單的百分比"

        # 年度同比增長 (需使用窗口函數)
        yoy_growth:
          type: number
          sql: |
            (SUM(${TABLE}.amount) - LAG(SUM(${TABLE}.amount)) OVER (ORDER BY DATE_TRUNC('year', ${TABLE}.created_at)))
            / NULLIF(LAG(SUM(${TABLE}.amount)) OVER (ORDER BY DATE_TRUNC('year', ${TABLE}.created_at)), 0) * 100
```

### 引用其他表格

在 SQL 中使用表格引用：

```yaml
metrics:
  customer_order_total:
    type: number
    sql: "SUM(${orders.amount})"  # 引用已連接的表格
```

## 完整範例

### 電子商務指標

```yaml
columns:
  - name: amount
    meta:
      dimension:
        type: number
        format: "usd"
      metrics:
        total_revenue:
          type: sum
          label: "總營收"
          description: "所有訂單金額的總和"
          format: "usd"
          round: 2
          show_underlying_values:
            - order_id
            - customer_name
            - amount
          groups:
            - "營收"

        average_order_value:
          type: average
          label: "平均訂單價值 (AOV)"
          description: "平均訂單金額"
          format: "usd"
          round: 2
          groups:
            - "營收"

        max_order:
          type: max
          label: "最大單筆訂單"
          format: "usd"
          groups:
            - "營收"

  - name: order_id
    meta:
      dimension:
        type: string
      metrics:
        order_count:
          type: count
          label: "總訂單量"
          groups:
            - "量體"

        unique_customers:
          type: count_distinct
          sql: "${TABLE}.customer_id"
          label: "不重複客戶數"
          groups:
            - "量體"
```

## 最佳實踐

1. **盡可能使用欄位級別指標**：將指標與其源數據綁定
2. **添加有意義的描述**：幫助用戶理解計算方式
3. **設置適當的進位**：通常為小數點後 0-2 位
4. **使用格式預設**：確保所有指標的顯示一致
5. **配置顯示底層數值**：啟用實用的下鑽功能
6. **對相關指標進行分組**：使用 `groups` 進行組織（支援階層式分組）
7. **處理除以零的情況**：在自定義 SQL 中使用 `NULLIF`
8. **對變體使用過濾器**：建立指標的過濾版本
9. **添加 AI 提示**：幫助 AI 助手正確使用指標
10. **明確進行類型轉換**：確保正確的聚合結果（例如 `::float`）
