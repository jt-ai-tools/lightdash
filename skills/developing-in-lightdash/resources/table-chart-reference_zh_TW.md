# 表格圖表參考 (Table Chart Reference)

## 總覽

表格視覺化以表格式顯示查詢結果，並提供強大的配置選項，包括自定義、條件格式化和資料呈現。表格支援凍結欄位、儲存格內的長條圖視覺化、自定義欄位名稱以及複雜的條件格式化規則。

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/tableChart`。

## 基本 YAML 結構

```yaml
version: 1
name: "我的表格圖表"
slug: "my-table-chart"
spaceSlug: "my-space"
tableName: "my_explore"
updatedAt: "2024-01-30T12:00:00Z"

metricQuery:
  dimensions:
    - field_id_1
  metrics:
    - metric_id_1

chartConfig:
  type: "table"
  config:
    showColumnCalculation: true   # 顯示欄計算 (總計)
    hideRowNumbers: false         # 隱藏列號
    columns:
      field_id_1:
        visible: true             # 是否顯示
        name: "自定義欄位名稱"
        frozen: true              # 凍結欄位
    conditionalFormattings: []    # 條件格式化
```

## 關鍵配置選項

### 顯示選項

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `showColumnCalculation` | boolean | 在底部顯示欄總計 |
| `showRowCalculation` | boolean | 在額外的一欄中顯示列總計 |
| `showTableNames` | boolean | 在欄位標題中顯示資料表名稱 (例如："users.name" vs "name") |
| `hideRowNumbers` | boolean | 隱藏資料列編號欄 |
| `showResultsTotal` | boolean | 顯示結果總筆數 |
| `showSubtotals` | boolean | 為分組資料顯示小計列 |
| `metricsAsRows` | boolean | 將指標顯示為列而非欄 (樞紐檢視) |

### 欄位配置

`columns` 物件允許使用欄位 ID 作為鍵 (key) 來進行個別欄位的自定義：

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `visible` | boolean | 欄位是否可見 |
| `name` | string | 欄位的自定義顯示名稱 |
| `frozen` | boolean | 捲動時將欄位凍結在左側 |
| `displayStyle` | `"text"` \| `"bar"` | 儲存格數值的顯示樣式 |
| `color` | string (hex) | 長條圖樣式的顏色 |

### 條件格式化 (Conditional Formatting)

條件格式化根據數值突顯儲存格。每條規則包含：

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `target.fieldId` | string | 套用格式化的欄位 |
| `color` | string 或 `{start, end}` | 單一顏色或漸層色 |
| `rules` | array | 單一顏色格式化的條件 |
| `rule` | `{min, max}` | 漸層格式化的範圍 (數值或 `"auto"`) |
| `applyTo` | `"cell"` \| `"text"` | 套用於背景色或文字顏色 |

### 條件格式化運算子

- **空值檢查**：`isNull`, `notNull`
- **相等性**：`equals`, `notEquals`
- **字串**：`startsWith`, `endsWith`, `include`, `doesNotInclude`
- **數值**：`lessThan`, `lessThanOrEqual`, `greaterThan`, `greaterThanOrEqual`
- **範圍**：`inBetween`, `notInBetween`
- **日期**：`inThePast`, `notInThePast`, `inTheNext`, `inTheCurrent`, `notInTheCurrent`

## 範例：全功能表格

此範例展示了凍結欄位、長條圖視覺化和條件格式化：

```yaml
version: 1
name: "銷售績效"
slug: "sales-performance"
spaceSlug: "sales"
tableName: "orders"
updatedAt: "2024-01-30T12:00:00Z"

metricQuery:
  dimensions:
    - orders_region
    - orders_sales_rep
  metrics:
    - orders_total_revenue
    - orders_order_count

chartConfig:
  type: "table"
  config:
    showColumnCalculation: true
    hideRowNumbers: false
    showResultsTotal: true

    columns:
      orders_region:
        frozen: true
        name: "區域"
      orders_sales_rep:
        frozen: true
        name: "銷售代表"
      orders_total_revenue:
        name: "總營收"
        displayStyle: "bar"       # 顯示為長條圖
        color: "#10B981"
      orders_order_count:
        name: "訂單數"

    conditionalFormattings:
      # 基於營收的漸層色
      - target:
          fieldId: "orders_total_revenue"
        color:
          start: "#FFFFFF"
          end: "#10B981"
        rule:
          min: "auto"
          max: "auto"
        applyTo: "cell"

      # 將低訂單數以紅色突顯
      - target:
          fieldId: "orders_order_count"
        color: "#EF4444"
        rules:
          - id: "low-volume"
            operator: "lessThan"
            values: [10]
        applyTo: "cell"
```

## 範例：欄位間比較

比較欄位間的數值以突顯超出/低於預算的情況：

```yaml
chartConfig:
  type: "table"
  config:
    columns:
      orders_actual_spend:
        name: "實際支出"
      orders_budget:
        visible: false  # 隱藏此欄位，但用於比較

    conditionalFormattings:
      - target:
          fieldId: "orders_actual_spend"
        color: "#EF4444"
        rules:
          - id: "over-budget"
            operator: "greaterThan"
            values: []
            compareTarget:
              fieldId: "orders_budget"
        applyTo: "cell"
```

## 提示與最佳實踐

1. **凍結識別欄位**：將 ID 或名稱等關鍵欄位保持凍結，以便在水平捲動時更容易瀏覽。

2. **結合長條圖視覺化與條件格式化**：使用長條圖樣式進行快速視覺比較，並使用條件格式化來突顯異常值。

3. **漸層範圍使用 "auto"**：當數值變動很大時，為漸層規則設定 `min: "auto"` 和 `max: "auto"`。

4. **隱藏用於比較的欄位**：當進行欄位間比較時，可以使用 `visible: false` 隱藏目標欄位。

5. **套用於儲存格 vs 文字**：使用 `applyTo: "cell"` 進行背景突顯，使用 `applyTo: "text"` 更改文字顏色。

6. **自定義欄位名稱**：使用 `name` 屬性使欄位標題比原始欄位 ID 更具備友善的使用者體驗。
