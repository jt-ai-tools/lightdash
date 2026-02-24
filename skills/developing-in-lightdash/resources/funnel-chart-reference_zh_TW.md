# 漏斗圖參考 (Funnel Chart Reference)

漏斗圖視覺化順序程序中的各個階段，顯示數值如何從一個階段減少到下一個階段。常見的使用案例包括轉換漏斗、銷售管線和多步驟的使用者流程。

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/funnelChart`。

## 何時使用漏斗圖

- **轉換漏斗**：網站訪客 → 註冊 → 付費客戶。
- **銷售管線**：潛在客戶 → 合格線索 → 提案 → 成交。
- **程序流程**：申請階段、結帳流程、入職步驟。
- **流失分析**：識別使用者在程序中哪些環節離開。

## 圖表結構

### 基本配置

```yaml
version: 1
name: "銷售漏斗"
slug: sales-funnel
spaceSlug: sales
tableName: leads

metricQuery:
  exploreName: leads
  dimensions:
    - leads_stage
  metrics:
    - leads_count
  sorts:
    - fieldId: leads_stage
      descending: false

chartConfig:
  type: funnel
  config:
    fieldId: leads_count
    dataInput: row
```

### 關鍵配置選項

#### `dataInput`

查詢結果中資料的組織方式。

- `row` (預設值)：每一列代表一個漏斗階段。
- `column`：每一欄代表一個漏斗階段。

**基於列 (Row-based) 的範例** (建議使用)：
```
| stage          | count |
|----------------|-------|
| Awareness      | 10000 |
| Interest       | 5000  |
| Consideration  | 2000  |
| Purchase       | 500   |
```

**基於欄 (Column-based) 的範例**：
```
| awareness | interest | consideration | purchase |
|-----------|----------|---------------|----------|
| 10000     | 5000     | 2000          | 500      |
```

#### `fieldId`

要顯示為漏斗數值的欄位 ID (指標或維度)。

#### `labels`

控制標籤顯示：
- `position`：`inside` (預設值)、`left`、`right` 或 `hidden`。
- `showValue`：顯示實際數值 (例如："5,000")。
- `showPercentage`：顯示最大值的百分比 (例如："50%")。

#### `labelOverrides`

為特定階段提供自定義標籤：

```yaml
config:
  labelOverrides:
    leads_stage_awareness: "漏斗頂端"
    leads_stage_interest: "已互動使用者"
```

#### `colorOverrides`

為個別漏斗階段自定義顏色：

```yaml
config:
  colorOverrides:
    leads_stage_awareness: "#3b82f6"
    leads_stage_interest: "#10b981"
```

#### 圖例選項 (Legend Options)

- `showLegend`：顯示或隱藏圖例 (預設值：true)。
- `legendPosition`：`horizontal` (水平) 或 `vertical` (垂直)。

## 完整範例

```yaml
version: 1
name: "銷售管線"
slug: sales-pipeline
spaceSlug: sales
tableName: opportunities

metricQuery:
  exploreName: opportunities
  dimensions:
    - opportunities_stage
  metrics:
    - opportunities_count
  sorts:
    - fieldId: opportunities_stage
      descending: false
  limit: 10

chartConfig:
  type: funnel
  config:
    fieldId: opportunities_count
    dataInput: row

    # 自定義階段標籤
    labelOverrides:
      opportunities_stage_lead: "新線索"
      opportunities_stage_qualified: "合格機會"
      opportunities_stage_proposal: "已發送提案"
      opportunities_stage_negotiation: "議價中"
      opportunities_stage_closed: "成交贏單"

    # 自定義階段顏色
    colorOverrides:
      opportunities_stage_lead: "#3b82f6"
      opportunities_stage_qualified: "#06b6d4"
      opportunities_stage_proposal: "#10b981"
      opportunities_stage_negotiation: "#f59e0b"
      opportunities_stage_closed: "#8b5cf6"

    labels:
      position: inside
      showValue: true
      showPercentage: true

    showLegend: true
    legendPosition: vertical
```

## 最佳實踐

### 資料準備

1. **邏輯排序階段**：在查詢結果中按正確的漏斗順序 (從上到下) 進行排序。
2. **使用有意義的階段名稱**：清晰的標籤有助於使用者理解程序。
3. **包含所有階段**：不要過濾掉數值為零的階段——它們能顯示流失點。

### 視覺設計

1. **限制階段數量**：4-7 個階段可獲得最佳可讀性。
2. **顯示百分比**：幫助檢視者理解各階段之間的轉換率。
3. **使用順序顏色**：顏色應能暗示進度。
4. **適當放置標籤**：
   - 對於短階段名稱和寬漏斗，使用 `inside` (內部)。
   - 對於長階段名稱，使用 `left` (左側) 或 `right` (右側)。
   - 當圖例已提供足夠背景時，使用 `hidden` (隱藏)。

### 何時不該使用漏斗圖

- **非順序程序**：請改用圓餅圖或長條圖。
- **比較多個漏斗**：使用分組長條圖。
- **階段過多 (>7)**：考慮使用摺線圖或長條圖。
- **階段數值可能會增加**：漏斗圖假設數值是遞減的。

## 常見問題

### 問題：階段順序錯誤

**解決方案**：在指標查詢中添加排序：

```yaml
metricQuery:
  sorts:
    - fieldId: stage_field
      descending: false
```

### 問題：標籤被截斷或重疊

**解決方案**：將標籤位置更改為 `left` 或 `right`。

### 問題：顏色未顯示

**解決方案**：確保您使用的是帶有 `#` 前綴的有效十六進制顏色代碼。

### 問題：圖例顯示內部欄位 ID

**解決方案**：使用 `labelOverrides` 提供易於理解的名稱。
