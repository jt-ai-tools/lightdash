# 表格參考 (Tables Reference)

表格（也稱為探索 Explores）是 Lightdash 專案的基礎。它們定義了數據結構、連接 (joins) 以及可用於分析的欄位。

## 基本配置

```yaml
version: 2

models:
  - name: orders
    description: "訂單交易數據"
    meta:
      label: "訂單"
```

## 表格屬性

### 核心屬性

```yaml
models:
  - name: orders
    meta:
      label: "訂單"                    # 顯示名稱
      description: "所有訂單記錄"       # 描述
      hidden: false                      # 是否在探索列表中隱藏
```

### SQL 配置

```yaml
meta:
  sql_table: "analytics.orders"          # 覆寫表格引用
  sql_where: "is_deleted = false"        # 始終套用的過濾器
```

### 欄位組織

```yaml
meta:
  order_fields_by: "label"               # 欄位排序方式："label" 或 "index"
  group_label: "銷售"                    # 在側邊欄中對此探索進行分組
```

### 主鍵 (Primary Key)

```yaml
meta:
  primary_key: "order_id"                # 單一欄位
  # 或
  primary_key:                           # 複合主鍵
    - order_id
    - line_item_id
```

### 預設時間維度

為時間序列分析設置預設時間維度：

```yaml
meta:
  default_time_dimension:
    field: created_at
    interval: MONTH                      # 預設分組間隔
```

### 預設顯示底層數值

為所有指標設置預設的下鑽欄位：

```yaml
meta:
  default_show_underlying_values:
    - order_id
    - customer_name
    - amount
    - created_at
```

### 欄位組 (Field Groups)

定義用於組織欄位的組別：

```yaml
meta:
  group_details:
    customer_info:
      label: "客戶資訊"
      description: "與客戶數據相關的欄位"
    order_details:
      label: "訂單詳情"
```

### 欄位集 (Field Sets)

建立具名欄位集以供快速選擇：

```yaml
meta:
  sets:
    customer_summary:
      label: "客戶摘要"
      fields:
        - customer_id
        - customer_name
        - email
```

### Spotlight 配置

控制在 AI 驅動搜尋中的可見性：

```yaml
meta:
  spotlight:
    visibility: "show"                   # "show" 或 "hide"
    categories:
      - "銷售"
      - "核心表格"
```

### 強制過濾器 (Required Filters)

在所有查詢中強制執行的過濾器：

```yaml
meta:
  required_filters:
    - is_deleted: false
    - status: ["active", "pending"]
```

### 存取控制

根據用戶屬性限制表格存取：

```yaml
meta:
  required_attributes:
    department: "sales"                  # 需要滿足的單一值
    region:                              # 滿足其中之一即可
      - "north"
      - "south"
```

### AI 提示 (AI Hints)

引導 AI 生成查詢：

```yaml
meta:
  ai_hint: "主要訂單表 - 用於營收和訂單分析"
```

## 連接配置 (Joins Configuration)

```yaml
meta:
  joins:
    - join: customers
      sql_on: "${orders.customer_id} = ${customers.customer_id}"
      type: left
      label: "客戶"
      relationship: many-to-one
```

詳細的連接配置請參閱 [連接參考](./joins-reference_zh_TW.md)。

## 最佳實踐

1. **設置清晰的標籤**：使用符合業務習慣的名稱。
2. **添加描述**：記錄表格包含的內容。
3. **配置主鍵**：有助於優化查詢。
4. **設置預設時間維度**：改善時間序列探索體驗。
5. **定義預設顯示底層數值**：提供更好的下鑽體驗。
6. **使用組別組織欄位**：使用 `groups` 屬性分組，並使用 `group_details` 定義組別元數據。
7. **使用 sql_where 進行數據過濾**：排除測試或已刪除的記錄。
8. **謹慎配置連接 (Joins)**：選擇正確的連接類型和關聯性。
9. **添加 AI 提示**：幫助 AI 助手理解表格用途。
