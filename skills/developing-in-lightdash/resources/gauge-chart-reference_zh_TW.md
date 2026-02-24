# 量表圖參考 (Gauge Chart Reference)

## 總覽

Lightdash 中的量表圖提供單一指標值相對於定義範圍的視覺化呈現，使其非常適合：

- **KPI 監控**：顯示相對於目標的績效 (例如：實際營收 vs. 目標)。
- **進度指示器**：顯示完成百分比 (例如：季度目標已完成 75%)。
- **狀態視覺化**：使用顏色編碼區段來指示健康狀況 (紅/黃/綠區域)。
- **閾值追蹤**：視覺化指標相對於警告和關鍵閾值的狀態。

量表圖在半圓形撥盤上顯示單一數值，並可選擇帶有顏色的區段來指示不同的範圍或績效區域。

## 架構參考 (Schema Reference)

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/gaugeChart`。

## 關鍵配置屬性

量表圖的 `config` 物件支援以下關鍵屬性：

### 核心數值設定

- **`selectedField`**：量表圖數值的欄位 ID (來自 `metricQuery` 的指標)。
- **`min`**：量表圖尺度的最小值 (預設值：0)。
- **`max`**：量表圖尺度的固定最大值。
- **`maxFieldId`**：用作動態最大值的欄位 ID (與 `max` 互斥)。

### 顯示設定

- **`showAxisLabels`**：在量表圖軸上顯示最小值/最大值標籤。
- **`customLabel`**：顯示自定義標籤而非欄位名稱。
- **`showPercentage`**：將數值顯示為最大值的百分比。
- **`customPercentageLabel`**：百分比顯示的自定義標籤。

### 區段 (顏色範圍)

- **`sections`**：指示績效區域的顏色範圍陣列。每個區段需要：
  - `min` / `minFieldId`：起始值 (固定或動態)。
  - `max` / `maxFieldId`：結束值 (固定或動態)。
  - `color`：十六進制顏色代碼 (例如：`"#DC2626"`)。

## 範例

### 範例 1：帶有顏色編碼區段的量表圖

帶有紅/黃/綠績效區域的量表圖：

```yaml
version: 1
name: "客戶滿意度得分"
slug: "customer-satisfaction"
spaceSlug: "metrics"
tableName: "customer_metrics"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions: []
  metrics:
    - "customer_metrics_csat_score"
  filters: []
  sorts: []
  limit: 1

chartConfig:
  type: "gauge"
  config:
    selectedField: "customer_metrics_csat_score"
    min: 0
    max: 10
    showAxisLabels: true
    customLabel: "CSAT 得分"
    sections:
      # 紅色區域：0-5 (差)
      - min: 0
        max: 5
        color: "#DC2626"
      # 黃色區域：5-7 (尚可)
      - min: 5
        max: 7
        color: "#FBBF24"
      # 綠色區域：7-10 (優異)
      - min: 7
        max: 10
        color: "#10B981"
```

### 範例 2：動態最大值與百分比顯示

相對於動態目標的進度量表圖：

```yaml
version: 1
name: "專案完成度"
slug: "project-completion"
spaceSlug: "projects"
tableName: "project_metrics"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions: []
  metrics:
    - "project_metrics_tasks_completed"
    - "project_metrics_total_tasks"
  filters: []
  sorts: []
  limit: 1

chartConfig:
  type: "gauge"
  config:
    selectedField: "project_metrics_tasks_completed"
    min: 0
    maxFieldId: "project_metrics_total_tasks"
    showAxisLabels: true
    showPercentage: true
    customPercentageLabel: "完成百分比"
    sections:
      - min: 0
        max: 50
        color: "#EF4444"
      - min: 50
        max: 75
        color: "#F59E0B"
      - min: 75
        max: 100
        color: "#22C55E"
```

## 常見模式

### KPI 儀表板量表圖

```yaml
config:
  selectedField: "kpi_current_value"
  maxFieldId: "kpi_target_value"
  showPercentage: true
  customPercentageLabel: "達標率"
  sections:
    - min: 0
      max: 80
      color: "#DC2626"  # 紅色：低於目標
    - min: 80
      max: 100
      color: "#FBBF24"  # 黃色：接近目標
    - min: 100
      max: 120
      color: "#10B981"  # 綠色：超越目標
```

### 簡單進度指示器

```yaml
config:
  selectedField: "completed_count"
  maxFieldId: "total_count"
  showPercentage: true
  showAxisLabels: true
```

## 提示

1. **限制為 1 列**：量表圖顯示單一數值，因此請在 `metricQuery` 中使用 `limit: 1`。

2. **使用聚合指標**：量表圖最適合用於聚合值 (總計、平均值、計數)。

3. **顏色可讀性**：為區段使用高對比度的顏色 (例如：標準紅/黃/綠：`#DC2626`, `#FBBF24`, `#10B981`)。

4. **區段覆蓋範圍**：確保區段覆蓋從 `min` 到 `max` 的完整範圍，以獲得完整的視覺呈現。

5. **動態 vs. 靜態最大值**：當您的目標會變動時 (例如：不同的月度目標)，請使用 `maxFieldId`；對於固定尺度，請使用 `max`。

6. **百分比顯示**：最適合用於追蹤進度，其中 100% 代表一個有意義的目標。
