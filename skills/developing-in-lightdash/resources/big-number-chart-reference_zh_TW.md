# 大數字圖表參考 (Big Number Chart Reference)

## 總覽

Lightdash 中的大數字圖表 (也稱為 KPI 顯示) 用於突顯顯示單一指標值，使其非常適合：

- **關鍵績效指標 (KPIs)**：一眼就能看到關鍵業務指標 (例如：月營收、活躍使用者)。
- **儀表板**：建立帶有標題數字的高階主管儀表板。
- **同期比較 (Period-over-period comparison)**：顯示指標與前一個期間相比的變化情況。
- **警示監控**：使用顏色編碼的變化指示器來強調重要指標。
- **緊湊顯示**：以易讀的格式顯示大數字 (例如：1.2M 而非 1,234,567)。

大數字圖表會突顯顯示單一數值，並可選擇顯示與過去時間點的比較變動，以及自定義數字格式。

## 架構參考 (Schema Reference)

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/bigNumber`。

## 基本結構

```yaml
version: 1
name: "我的大數字"
slug: "my-big-number"
spaceSlug: "analytics"
tableName: "my_explore"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions: []
  metrics:
    - "my_explore_total_revenue"
  filters: []
  sorts: []
  limit: 1

chartConfig:
  type: "big_number"
  config:
    selectedField: "my_explore_total_revenue"
    label: "總營收"
    showBigNumberLabel: true
```

## 關鍵配置屬性

`config` 物件支援以下關鍵屬性：

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `selectedField` | 字串 | 要顯示為大數字的欄位 ID (應為 `metricQuery` 中的指標) |
| `label` | 字串 | 大數字的自定義標籤 (若未提供，預設為欄位名稱) |
| `showBigNumberLabel` | 布林值 | 是否在數字上方顯示標籤 |
| `showTableNamesInLabel` | 布林值 | 是否在標籤中包含資料表名稱 |
| `style` | 字串 | 數字格式樣式：`"K"`, `"M"`, `"B"`, `"T"` (或 `"thousands"`, `"millions"`, `"billions"`, `"trillions"`) |
| `showComparison` | 布林值 | 是否顯示與前一個數值的比較 |
| `comparisonFormat` | 字串 | 比較格式：`"raw"` (絕對變化) 或 `"percentage"` (百分比變化) |
| `comparisonLabel` | 字串 | 比較值的自定義標籤 (例如："與上個月相比") |
| `flipColors` | 布林值 | 反轉配色方案 (增加為紅色，減少為綠色) |

## 範例

### 範例 1：基本 KPI 與緊湊格式

以百萬為單位顯示總營收的簡單大數字：

```yaml
version: 1
name: "總營收"
slug: "total-revenue"
spaceSlug: "sales"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions: []
  metrics:
    - "orders_total_revenue"
  filters: []
  sorts: []
  limit: 1

chartConfig:
  type: "big_number"
  config:
    selectedField: "orders_total_revenue"
    label: "總營收"
    style: "M"  # 顯示為百萬 (例如：2.5M)
    showBigNumberLabel: true
```

### 範例 2：反轉顏色的同期比較

顯示成本與百分比變化，其中增加被標示為負面 (紅色)：

```yaml
version: 1
name: "基礎設施成本"
slug: "infrastructure-costs"
spaceSlug: "finance"
tableName: "expenses"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions: []
  metrics:
    - "expenses_total_cost"
  filters:
    - target:
        fieldId: "expenses_date"
      operator: "inThePast"
      values: [30]
      settings:
        unitOfTime: "days"
  sorts: []
  limit: 1

chartConfig:
  type: "big_number"
  config:
    selectedField: "expenses_total_cost"
    label: "每月基礎設施成本"
    style: "K"
    showBigNumberLabel: true
    showComparison: true
    comparisonFormat: "percentage"
    comparisonLabel: "與上個月相比"
    flipColors: true  # 增加為紅色，減少為綠色
```

## 常見模式

### 高階主管儀表板 KPI

```yaml
config:
  selectedField: "revenue_total"
  label: "總營收"
  style: "M"
  showBigNumberLabel: true
  showComparison: true
  comparisonFormat: "percentage"
  comparisonLabel: "與上個月相比"
```

### 成本監控

```yaml
config:
  selectedField: "costs_total"
  label: "每月雲端成本"
  style: "K"
  showBigNumberLabel: true
  showComparison: true
  comparisonFormat: "percentage"
  flipColors: true  # 增加顯示為紅色
```

### 簡單指標顯示

```yaml
config:
  selectedField: "users_count"
  label: "總使用者數"
  showBigNumberLabel: true
```

## 提示

1. **限制為 1 列**：大數字圖表僅顯示單一數值，因此請務必在 `metricQuery` 中設定 `limit: 1`。

2. **使用聚合指標**：大數字最適合用於聚合值 (總計、計數、平均值)。

3. **選擇正確的樣式**：對大數字使用緊湊計法：
   - 營收以百萬計？使用 `"M"`。
   - 使用者數以千計？使用 `"K"`。
   - 市值以十億計？使用 `"B"`。

4. **適當反轉顏色**：對於增加代表負面含義的指標 (成本、錯誤、回應時間、流失率)，請使用 `flipColors: true`。

5. **比較背景**：使用 `showComparison` 時，請務必提供 `comparisonLabel` 以明確背景資訊。

6. **百分比 vs. 原始值**：根據受眾選擇比較格式：
   - **百分比**：較適合理解相對變化。
   - **原始值**：當絕對數字較重要時使用。

## 快速參考表

### 數字格式樣式

| 樣式 | 輸入範例 | 輸出範例 | 使用案例 |
|-------|---------------|----------------|----------|
| `"K"` | 1500 | 1.5K | 以千為單位的較小數字 |
| `"M"` | 1500000 | 1.5M | 營收、大量使用者數 |
| `"B"` | 1500000000 | 1.5B | 市值、大型財務數據 |
| `"T"` | 1500000000000 | 1.5T | 國家經濟數據 |

### 配色方案

| flipColors | 增加 | 減少 | 適用於 |
|------------|----------|----------|---------|
| `false` (預設) | 綠色 | 紅色 | 營收、使用者、註冊數 |
| `true` | 紅色 | 綠色 | 成本、錯誤、流失率 |
