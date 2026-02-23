# 維度參考 (Dimensions Reference)

維度是用於細分和過濾數據的屬性。它們描述了數據中的「誰」(who)、「什麼」(what)、「哪裡」(where) 以及「何時」(when)。

## 基本配置

```yaml
columns:
  - name: customer_id
    description: "唯一的客戶識別碼"
    meta:
      dimension:
        type: string
        label: "客戶 ID"
        description: "每個客戶的唯一標識符"
        hidden: false
```

## 維度類型

| 類型 | 描述 | SQL 範例 |
|------|-------------|--------------|
| `string` | 文字值 | VARCHAR, TEXT, CHAR |
| `number` | 數值 | INT, FLOAT, DECIMAL |
| `boolean` | 真/假值 | BOOLEAN |
| `date` | 僅日期（無時間） | DATE |
| `timestamp` | 日期和時間 | TIMESTAMP, DATETIME |

## 所有配置選項

### 核心屬性

```yaml
dimension:
  type: string          # 必要項：string, number, boolean, date, timestamp
  label: "顯示名稱"      # 易於閱讀的名稱
  description: "..."    # 詳細描述
  hidden: false         # 是否在 UI 中隱藏（預設：false）
  sql: "${TABLE}.column_name"  # 自定義 SQL 表達式
```

### 格式化

```yaml
dimension:
  type: number
  round: 2              # 小數點位數
  format: "usd"         # 格式預設：usd, gbp, eur, percent, km, mi, id
  compact: "millions"   # 精簡顯示：thousands, millions, billions, trillions
```

**精簡選項 (Compact Options)：**
- 數值：`thousands` (K), `millions` (M), `billions` (B), `trillions` (T)
- 位元組 (Bytes)：`kilobytes`, `megabytes`, `gigabytes`, `terabytes`, `petabytes`
- 二進位 (Binary)：`kibibytes`, `mebibytes`, `gibibytes`, `tebibytes`, `pebibytes`

### 時間間隔 (Time Intervals)

適用於 `timestamp` 和 `date` 類型：

```yaml
dimension:
  type: timestamp
  time_intervals:       # 要生成的間隔
    - RAW               # 原始值
    - YEAR
    - QUARTER
    - MONTH
    - WEEK
    - DAY
    - HOUR              # 僅限 timestamp
    - MINUTE            # 僅限 timestamp
    - SECOND            # 僅限 timestamp
```

**停用時間間隔：**
```yaml
dimension:
  type: timestamp
  time_intervals: "OFF"  # 或 false
```

**所有可用間隔：**

| 間隔 (Interval) | 描述 | 輸出範例 |
|----------|-------------|----------------|
| `RAW` | 原始時間戳記 | 2024-01-15 14:30:00 |
| `YEAR` | 截斷至年份 | 2024-01-01 |
| `QUARTER` | 截斷至季度 | 2024-01-01 |
| `MONTH` | 截斷至月份 | 2024-01-01 |
| `WEEK` | 截斷至週 | 2024-01-15 |
| `DAY` | 截斷至日期 | 2024-01-15 |
| `HOUR` | 截斷至小時 | 2024-01-15 14:00:00 |
| `MINUTE` | 截斷至分鐘 | 2024-01-15 14:30:00 |
| `SECOND` | 截斷至秒 | 2024-01-15 14:30:00 |
| `MILLISECOND` | 截斷至毫秒 | 2024-01-15 14:30:00.000 |
| `YEAR_NUM` | 年份（數值） | 2024 |
| `QUARTER_NUM` | 季度（數值） | 1 |
| `MONTH_NUM` | 月份（數值） | 1 |
| `WEEK_NUM` | 週數（數值） | 3 |
| `DAY_OF_YEAR_NUM` | 一年中的第幾天 | 15 |
| `DAY_OF_MONTH_NUM` | 一個月中的第幾天 | 15 |
| `DAY_OF_WEEK_INDEX` | 一週中的第幾天 (0-6) | 1 |
| `HOUR_OF_DAY_NUM` | 小時 (0-23) | 14 |
| `MINUTE_OF_HOUR_NUM` | 分鐘 (0-59) | 30 |
| `QUARTER_NAME` | 季度名稱 | Q1 |
| `MONTH_NAME` | 月份名稱 | January |
| `DAY_OF_WEEK_NAME` | 星期名稱 | Monday |

### 組織架構

使用 `groups` 在側邊欄中組織維度：

```yaml
dimension:
  type: string
  groups:
    - "客戶詳情"
```

對於階層式分組，可以添加多個層級：

```yaml
dimension:
  type: string
  groups:
    - "客戶"
    - "人口統計"
```

> **注意：** `group_label` 已過時。請改用 `groups`。

### 顏色 (Colors)

將數值映射到顏色，以保持圖表樣式一致：

```yaml
dimension:
  type: string
  colors:
    "Active": "#22c55e"     # 綠色
    "Inactive": "#ef4444"   # 紅色
    "Pending": "#f59e0b"    # 黃色
```

### 網址 (URLs)

為維度數值添加可點擊的連結：

```yaml
dimension:
  type: string
  urls:
    - label: "在 CRM 中查看"
      url: "https://crm.example.com/customers/${value}"
    - label: "支援工單"
      url: "https://support.example.com/customer/${value}/tickets"
```

**URL 變數：**
- `${value}` - 該維度的值
- `${row.other_dimension}` - 同一行中其他維度的值

### 存取控制

根據用戶屬性限制存取：

```yaml
dimension:
  type: string
  required_attributes:
    department: "sales"           # 單一值
    region:                       # 多個值 (OR)
      - "north"
      - "south"
```

### AI 提示 (AI Hints)

引導 AI 生成查詢：

```yaml
dimension:
  type: string
  ai_hint: "用於按行業進行客戶細分"
  # 或多個提示：
  ai_hint:
    - "主要的客戶識別碼"
    - "用於客戶級別的分析"
```

### 標籤 (Tags)

為維度分類：

```yaml
dimension:
  type: string
  tags:
    - "customer"
    - "pii"
```

## 自定義 SQL 維度

建立計算維度：

```yaml
columns:
  - name: full_name
    meta:
      dimension:
        type: string
        sql: "CONCAT(${TABLE}.first_name, ' ', ${TABLE}.last_name)"

  - name: age_group
    meta:
      dimension:
        type: string
        sql: |
          CASE
            WHEN ${TABLE}.age < 18 THEN '18 歲以下'
            WHEN ${TABLE}.age < 35 THEN '18-34 歲'
            WHEN ${TABLE}.age < 55 THEN '35-54 歲'
            ELSE '55 歲以上'
          END
```

## 附加維度 (Additional Dimensions)

從基礎維度建立衍生維度：

```yaml
columns:
  - name: email
    meta:
      dimension:
        type: string
      additional_dimensions:
        email_domain:
          type: string
          label: "電子郵件網域"
          sql: "SPLIT_PART(${TABLE}.email, '@', 2)"
        has_company_email:
          type: boolean
          label: "是否為公司電子郵件"
          sql: "NOT ${TABLE}.email LIKE '%gmail.com' AND NOT ${TABLE}.email LIKE '%yahoo.com'"
```

## 完整範例

```yaml
columns:
  - name: created_at
    description: "客戶帳戶建立時間"
    meta:
      dimension:
        type: timestamp
        label: "帳戶建立日期"
        description: "客戶首次註冊的時間戳記"
        time_intervals:
          - DAY
          - WEEK
          - MONTH
          - QUARTER
          - YEAR
        groups:
          - "日期"

  - name: status
    description: "目前的帳戶狀態"
    meta:
      dimension:
        type: string
        label: "帳戶狀態"
        description: "Active, Inactive, 或 Churned"
        colors:
          "Active": "#22c55e"
          "Inactive": "#94a3b8"
          "Churned": "#ef4444"
        groups:
          - "帳戶資訊"

  - name: lifetime_value
    description: "客戶總支出"
    meta:
      dimension:
        type: number
        label: "終身價值 (LTV)"
        format: "usd"
        round: 2
        compact: "thousands"
        groups:
          - "財務"
        urls:
          - label: "營收詳情"
            url: "/customers/${row.customer_id}/revenue"
```

## 最佳實踐

1. **選擇正確的類型**：日期時間使用 `timestamp`，僅日期使用 `date`
2. **設置有意義的標籤**：使用符合業務習慣的名稱
3. **添加描述**：幫助用戶理解維度代表的含義
4. **配置時間間隔**：僅包含用戶實際需要的間隔
5. **對相關維度進行分組**：使用 `groups` 進行整潔的組織（支援階層式分組）
6. **一致地使用顏色**：將狀態值映射到直觀的顏色
7. **在有用之處添加 URL**：連結到外部系統以獲取上下文資訊
8. **使用 AI 提示**：幫助 AI 助手理解維度的用途
