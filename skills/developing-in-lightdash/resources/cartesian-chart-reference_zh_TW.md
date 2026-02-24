# 笛卡爾圖表參考 (Cartesian Chart Reference)

## 總覽

Lightdash 中的笛卡爾圖表 (Cartesian charts) 提供了靈活的視覺化選項，用於在 X 軸和 Y 軸上顯示維度與指標之間的關係。它支援四種數列類型：

- **長條圖 (Bar charts)**：使用垂直或水平長條比較各類別的值。
- **摺線圖 (Line charts)**：使用連接的資料點顯示隨時間變化的趨勢。
- **面積圖 (Area charts)**：使用摺線下方的填充區域顯示累計值和趨勢。
- **散佈圖 (Scatter charts)**：使用個別資料點揭露相關性和分佈情況。

笛卡爾圖表支援：
- 具有不同視覺化類型的多個數列。
- 堆疊 (適用於長條圖和面積圖)。
- 雙 Y 軸，用於比較不同尺度的指標。
- 參考線，用於突顯閾值或目標。
- 靈活的軸配置和樣式設定。

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/cartesianChart`。

## 基本結構

```yaml
version: 1
name: "我的笛卡爾圖表"
slug: "my-cartesian-chart"
spaceSlug: "analytics"
tableName: "my_explore"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "my_explore_category"
  metrics:
    - "my_explore_total_sales"
  filters: {}
  sorts: []
  limit: 500

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "my_explore_category"
      yField:
        - "my_explore_total_sales"
    eChartsConfig:
      series:
        - type: "bar"
          encode:
            xRef:
              field: "my_explore_category"
            yRef:
              field: "my_explore_total_sales"
```

## 關鍵配置屬性

### `layout` (版面配置)

- **`xField`**：X 軸的欄位 ID (通常為維度)。
- **`yField`**：Y 軸的欄位 ID 陣列。
- **`flipAxes`**：對於水平長條圖，交換 X 軸和 Y 軸 (預設值：`false`)。
- **`showGridX`** / **`showGridY`**：顯示網格線。
- **`stack`**：將數列堆疊在一起 (`true` 或堆疊群組名稱)。

### `eChartsConfig`

- **`series`**：數列配置陣列 (必填)。
- **`xAxis`** / **`yAxis`**：軸配置陣列。
- **`legend`**：圖例顯示與位置。
- **`grid`**：圖表區域內邊距。
- **`tooltip`** / **`tooltipSort`**：工具提示行為。

### 數列配置 (Series Configuration)

每個數列需要：
- **`type`**：`"bar"`, `"line"`, `"area"`, 或 `"scatter"`。
- **`encode`**：透過 `xRef` 和 `yRef` 引用欄位。

選填屬性：
- **`name`**：圖例中的顯示名稱。
- **`color`**：十六進制顏色代碼。
- **`yAxisIndex`**：使用哪個 Y 軸 (0 或 1)。
- **`stack`**：堆疊群組名稱。
- **`smooth`**：摺線圖/面積圖的平滑曲線。
- **`areaStyle`**：存在此屬性時表示面積圖。
- **`markLine`**：參考線配置。

## 範例

### 長條圖 (Bar Chart)

```yaml
version: 1
name: "各合作夥伴銷售額"
slug: "sales-by-partner"
spaceSlug: "sales"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "orders_partner_name"
  metrics:
    - "orders_total_sales"
  filters: {}
  sorts:
    - fieldId: "orders_total_sales"
      descending: true
  limit: 10

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "orders_partner_name"
      yField:
        - "orders_total_sales"
    eChartsConfig:
      series:
        - type: "bar"
          encode:
            xRef:
              field: "orders_partner_name"
            yRef:
              field: "orders_total_sales"
```

### 帶有趨勢的摺線圖 (Line Chart with Trend)

```yaml
version: 1
name: "每月營收趨勢"
slug: "monthly-revenue-trend"
spaceSlug: "finance"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "orders_order_date_month"
  metrics:
    - "orders_total_revenue"
  filters: {}
  sorts:
    - fieldId: "orders_order_date_month"
      descending: false
  limit: 500

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "orders_order_date_month"
      yField:
        - "orders_total_revenue"
      showGridY: true
    eChartsConfig:
      xAxis:
        - name: "月份"
      yAxis:
        - name: "營收 ($)"
      series:
        - type: "line"
          encode:
            xRef:
              field: "orders_order_date_month"
            yRef:
              field: "orders_total_revenue"
          smooth: true
          showSymbol: true
```

### 堆疊面積圖 (Stacked Area Chart)

```yaml
version: 1
name: "各類別營收"
slug: "revenue-by-category"
spaceSlug: "sales"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "orders_order_date_month"
    - "orders_product_category"
  metrics:
    - "orders_total_revenue"
  filters: {}
  sorts:
    - fieldId: "orders_order_date_month"
      descending: false
  limit: 500

pivotConfig:
  columns:
    - "orders_product_category"

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "orders_order_date_month"
      yField:
        - "orders_total_revenue"
    eChartsConfig:
      legend:
        show: true
      series:
        - type: "line"
          stack: "total"
          areaStyle: {}
          encode:
            xRef:
              field: "orders_order_date_month"
            yRef:
              field: "orders_total_revenue"
              pivotValues:
                - field: "orders_product_category"
                  value: "Electronics"
```

### 散佈圖 (Scatter Chart)

```yaml
version: 1
name: "訂單價值 vs 利潤"
slug: "order-value-vs-profit"
spaceSlug: "analytics"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "orders_order_id"
  metrics:
    - "orders_basket_total"
    - "orders_profit"
  filters: {}
  sorts: []
  limit: 1000

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "orders_basket_total"
      yField:
        - "orders_profit"
    eChartsConfig:
      xAxis:
        - name: "訂單價值 ($)"
      yAxis:
        - name: "利潤 ($)"
      series:
        - type: "scatter"
          encode:
            xRef:
              field: "orders_basket_total"
            yRef:
              field: "orders_profit"
```

### 雙 Y 軸圖表 (Dual Y-Axis Chart)

```yaml
version: 1
name: "營收與利潤率"
slug: "revenue-profit-margin"
spaceSlug: "finance"
tableName: "orders"
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - "orders_order_date_month"
  metrics:
    - "orders_total_revenue"
  tableCalculations:
    - name: "profit_margin"
      displayName: "利潤率 %"
      sql: "${orders.profit}/${orders.total_revenue} * 100"
  filters: {}
  sorts:
    - fieldId: "orders_order_date_month"
      descending: false
  limit: 500

chartConfig:
  type: "cartesian"
  config:
    layout:
      xField: "orders_order_date_month"
      yField:
        - "orders_total_revenue"
        - "profit_margin"
    eChartsConfig:
      yAxis:
        - name: "營收 ($)"
        - name: "利潤率 (%)"
      series:
        - type: "bar"
          name: "營收"
          encode:
            xRef:
              field: "orders_order_date_month"
            yRef:
              field: "orders_total_revenue"
          yAxisIndex: 0
        - type: "line"
          name: "利潤率"
          encode:
            xRef:
              field: "orders_order_date_month"
            yRef:
              field: "profit_margin"
          yAxisIndex: 1
          smooth: true
```

## 提示

1. **選擇正確的圖表類型**：
   - 長條圖：比較離散的類別。
   - 摺線圖：顯示隨時間變化的趨勢。
   - 面積圖：強調累計總量或組成成分。
   - 散佈圖：探索變數之間的相關性。

2. **堆疊 (Stacking)**：為想要堆疊的數列設定相同的 `stack` 值。僅長條圖和面積圖支援堆疊。

3. **雙 Y 軸**：左軸使用 `yAxisIndex: 0`，右軸使用 `yAxisIndex: 1`。

4. **水平長條圖**：在 layout 中設定 `flipAxes: true`。

5. **樞紐資料 (Pivot data)**：在 `yRef` 中使用 `pivotValues` 從樞紐維度建立數列。

6. **參考線**：在數列中添加 `markLine` 用於目標或閾值。

7. **網格間距**：使用 `grid.containLabel: true` 以防止標籤被截斷。
