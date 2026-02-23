# 儀表板參考 (Dashboard Reference)

儀表板將多個圖表、KPI 和內容磚塊組合在一個統一的視圖中，用於分析和監控。

## 儀表板結構

```yaml
version: 1
name: "銷售儀表板"
slug: sales-dashboard
spaceSlug: sales
description: "銷售業績概覽"

tiles: []        # 圖表和內容磚塊
tabs: []         # 選填：用於組織的頁籤
filters:         # 儀表板級別過濾器
  dimensions: []
```

## 磚塊類型 (Tile Types)

### 已儲存圖表磚塊 (Saved Chart Tile)

顯示專案中的圖表：

```yaml
tiles:
  - type: saved_chart
    x: 0              # 網格欄位 (0-35)
    y: 0              # 網格行數
    w: 12             # 寬度（網格單位，最大 36）
    h: 6              # 高度（網格單位）
    properties:
      chartSlug: monthly-revenue
      title: "每月營收"      # 選填：覆寫標題
      hideTitle: false
```

### SQL 圖表磚塊 (SQL Chart Tile)

顯示基於 SQL 的圖表：

```yaml
tiles:
  - type: sql_chart
    x: 12
    y: 0
    w: 12
    h: 6
    properties:
      chartSlug: custom-sql-chart
      savedSqlUuid: "abc123-def456"
```

### Markdown 磚塊 (Markdown Tile)

添加文字、備註或說明：

```yaml
tiles:
  - type: markdown
    x: 0
    y: 6
    w: 12
    h: 4
    properties:
      title: "關鍵洞察"
      content: |
        ## 第四季度業績摘要

        - 營收較上季增長 **15%**
        - 新客戶獲取情況改善
        - 重點領域：
          1. 企業市場
          2. 亞太地區擴張

        [查看詳細報告](/dashboards/q4-deep-dive)
```

### Loom 影片磚塊 (Loom Video Tile)

嵌入 Loom 影片：

```yaml
tiles:
  - type: loom
    x: 24
    y: 0
    w: 12
    h: 6
    properties:
      title: "儀表板導覽"
      url: "https://www.loom.com/share/abc123"
```

### 標題磚塊 (Heading Tile)

添加區段標題：

```yaml
tiles:
  - type: heading
    x: 0
    y: 10
    w: 36
    h: 1
    properties:
      text: "各地區細分"
```

## 網格佈局 (Grid Layout)

**重要提示：儀表板使用 36 欄的網格系統。** 若要填滿儀表板的全寬，請設置 `w: 36`。許多佈局錯誤地使用了較小的寬度（如 24 或 30），導致儀表板右側留下空白。

- **x**: 欄位位置 (0-35)
- **y**: 行數位置 (0+)
- **w**: 寬度（以欄為單位，1-36）。**使用 36 代表全寬磚塊。**
- **h**: 高度（以行為單位，最少 1）

### 寬度快速參考

| 佈局 | 寬度 (w) | 每行磚塊數 |
|--------|-----------|---------------|
| 全寬 (Full width) | 36 | 1 |
| 半寬 (Half width) | 18 | 2 |
| 三分之一寬 | 12 | 3 |
| 四分之一寬 | 9 | 4 |
| 六分之一寬 | 6 | 6 |

**注意：** Lightdash 中的預設磚塊寬度為 15 欄，不到網格的一半。建立儀表板時，請務必明確設置寬度以填滿可用空間。

### 常見佈局範例

**全寬 (w: 36)：**
```yaml
x: 0, y: 0, w: 36, h: 6
```

**兩欄（每格 w: 18，總計 36）：**
```yaml
# 左半邊
x: 0, y: 0, w: 18, h: 6
# 右半邊
x: 18, y: 0, w: 18, h: 6
```

**三欄（每格 w: 12，總計 36）：**
```yaml
x: 0, y: 0, w: 12, h: 6
x: 12, y: 0, w: 12, h: 6
x: 24, y: 0, w: 12, h: 6
```

## 儀表板頁籤 (Dashboard Tabs)

將磚塊組織到多個視圖中：

```yaml
tabs:
  - uuid: "overview-tab"
    name: "概覽"
    order: 0
  - uuid: "details-tab"
    name: "詳情"
    order: 1

tiles:
  # 概覽頁籤的磚塊
  - type: saved_chart
    tabUuid: "overview-tab"
    x: 0
    y: 0
    w: 36
    h: 6
    properties:
      chartSlug: revenue-summary
```

## 儀表板過濾器 (Dashboard Filters)

### 維度過濾器

```yaml
filters:
  dimensions:
    - target:
        fieldId: orders_created_at_month
        tableName: orders
      operator: inThePast
      values: [12]
      settings:
        unitOfTime: months
        completed: true
      label: "日期範圍"
      required: false
      disabled: false
```

### 過濾運算子

| 運算子 | 描述 | 範例值 |
|----------|-------------|----------------|
| `equals` | 精確匹配 | `["completed"]` |
| `notEquals` | 不等於 | `["cancelled"]` |
| `isNull` | 為空值 | `[]` |
| `notNull` | 非空值 | `[]` |
| `inThePast` | 在過去 N 個週期內 | `[30]` |
| `inTheNext` | 在未來 N 個週期內 | `[7]` |
| `inTheCurrent` | 在當前週期內 | `[1]` |
| `inBetween` | 在兩個數值之間 | `["2024-01-01", "2024-12-31"]` |

### 跨探索過濾器目標 (tileTargets)

當單一儀表板過濾器需要套用於來自不同探索 (explores) 的磚塊時，請使用 `tileTargets` 將過濾器對應到每個探索中的對等欄位。

#### 跨探索過濾範例

```yaml
filters:
  dimensions:
    - target:
        fieldId: orders_created_at    # 預設：適用於使用 orders 探索的磚塊
        tableName: orders
      operator: inThePast
      values: [30]
      label: "日期範圍"
      tileTargets:
        sales-by-region:              # 磚塊 slug - 使用 orders 探索（與預設相符）
          fieldId: orders_created_at
          tableName: orders
        customer-metrics:             # 磚塊 slug - 使用 customers 探索（不同的欄位！）
          fieldId: customers_signup_date
          tableName: customers
```

#### 從過濾器中排除特定磚塊

將磚塊目標設置為 `false` 可使其完全忽略該過濾器：

```yaml
tileTargets:
  company-overview: false       # 該磚塊將忽略地區過濾器
```

## 儀表板最佳實踐

### 佈局
1. **從 KPI 開始**：最頂行放置關鍵指標。
2. **邏輯流動**：概覽 → 詳情 → 下鑽。
3. **保持尺寸一致**：對齊網格，避免奇特的尺寸。

### 過濾器
1. **提供有用的預設值**：從有意義的數據開始。
2. **限制過濾器數量**：3-5 個主要過濾器為宜。
3. **正確目標化過濾器**：並非所有過濾器都適用於所有圖表。對於跨探索的儀表板，請務必使用 `tileTargets`。
