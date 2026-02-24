# 地圖圖表參考 (Map Chart Reference)

在 Lightdash 以程式碼定義圖表 (charts-as-code) 中建立地圖視覺化的指南。

> 有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/mapChart`。

## 總覽

地圖圖表透過三種位置類型將地理資料視覺化：

| 位置類型 | 說明 | 最適用於 |
|--------------|-------------|----------|
| `scatter` (散佈) | 經緯度座標點 | 門店位置、客戶地址 |
| `area` (區域) | 依指標填色的區域 (面量圖) | 各州/各國的銷售額 |
| `heatmap` (熱圖) | 密度視覺化 | 活動熱點 |

### 地圖類型

| 地圖類型 | 說明 | 位置匹配方式 |
|----------|-------------|-------------------|
| `USA` | 美國地圖 | 州名或縮寫 |
| `world` | 世界地圖 | 國家名稱或 ISO 代碼 |
| `europe` | 歐洲地圖 | 國家名稱或 ISO 代碼 |
| `custom` | 自定義 GeoJSON 區域 | 自定義屬性鍵 (property key) |

## 關鍵配置屬性

### 位置類型設定

**散佈圖 (Scatter Maps)** 需要緯度和經度欄位：
```yaml
config:
  locationType: "scatter"
  latitudeFieldId: "stores_latitude"
  longitudeFieldId: "stores_longitude"
  valueFieldId: "metric_for_color"      # 選填：顏色指標
  sizeFieldId: "metric_for_bubble_size" # 選填：氣泡大小指標
```

**區域圖 (Area Maps)** 將區域名稱與 GeoJSON 進行匹配：
```yaml
config:
  locationType: "area"
  locationFieldId: "orders_state"
  valueFieldId: "orders_total_sales"
  geoJsonPropertyKey: "name"
```

**熱圖 (Heatmaps)** 顯示點的密度：
```yaml
config:
  locationType: "heatmap"
  latitudeFieldId: "events_latitude"
  longitudeFieldId: "events_longitude"
  valueFieldId: "metric_for_intensity"  # 選填：強度指標
```

### 視覺設定

```yaml
config:
  tileBackground: "light"       # 地圖背景：none, openstreetmap, light, dark, satellite
  showLegend: true
  colorRange:
    - "#fee2e2"                 # 低數值顏色
    - "#dc2626"                 # 高數值顏色
  backgroundColor: "#ffffff"
  noDataColor: "#e5e7eb"        # 區域圖無資料時的顏色
```

### 視圖設定

```yaml
config:
  defaultZoom: 4
  defaultCenterLat: 39.8283
  defaultCenterLon: -98.5795
  saveMapExtent: true           # 儲存地圖範圍
```

## 範例

### 範例 1：門店位置 (散佈圖)

```yaml
version: 1
name: "門店位置"
slug: store-locations
spaceSlug: sales/maps
tableName: stores

metricQuery:
  exploreName: stores
  dimensions:
    - stores_store_name
    - stores_city
  metrics:
    - stores_total_revenue
  limit: 500

chartConfig:
  type: map
  config:
    mapType: "USA"
    locationType: "scatter"
    tileBackground: "light"
    latitudeFieldId: "stores_latitude"
    longitudeFieldId: "stores_longitude"
    sizeFieldId: "stores_total_revenue"
    minBubbleSize: 8
    maxBubbleSize: 40
    colorRange:
      - "#dbeafe"
      - "#1e40af"
    showLegend: true
    defaultZoom: 4
    defaultCenterLat: 39.8283
    defaultCenterLon: -98.5795

updatedAt: "2024-01-30T12:00:00Z"
```

### 範例 2：各州銷售額 (面量圖)

```yaml
version: 1
name: "各州銷售額"
slug: sales-by-state
spaceSlug: sales/maps
tableName: orders

metricQuery:
  exploreName: orders
  dimensions:
    - orders_state
  metrics:
    - orders_total_sales
  limit: 50

chartConfig:
  type: map
  config:
    mapType: "USA"
    locationType: "area"
    tileBackground: "none"
    locationFieldId: "orders_state"
    geoJsonPropertyKey: "name"
    valueFieldId: "orders_total_sales"
    colorRange:
      - "#f0f9ff"
      - "#2563eb"
    showLegend: true
    noDataColor: "#f3f4f6"

updatedAt: "2024-01-30T12:00:00Z"
```

## 資料要求

### 對於散佈圖與熱圖

- 緯度欄位 (數值，-90 到 90)。
- 經度欄位 (數值，-180 到 180)。
- 選填：用於控制顏色或大小的指標。

### 對於區域圖 (面量圖)

- 符合 GeoJSON 屬性的位置欄位：
  - 美國地圖：州名 ("California", "Texas")。
  - 世界地圖：國家名稱或 ISO 代碼。
  - 自定義地圖：與 `geoJsonPropertyKey` 匹配的數值。
- 用於為區域填色的指標。

## GeoJSON 屬性鍵 (Property Keys)

| 地圖類型 | 屬性鍵 | 範例數值 |
|----------|--------------|----------------|
| USA | `name` | "California", "Texas" |
| World | `name` | "United States", "France" |
| World | `ISO3166-1-Alpha-3` | "USA", "FRA" |
| Europe | `name` | "Germany", "France" |
| 自定義 | 使用者定義 | 與您的 GeoJSON 匹配 |

## 最佳實踐

### 選擇位置類型

- **散佈圖 (Scatter)**：精確座標、個別位置、需要氣泡大小呈現時。
- **區域圖 (Area)**：跨區域比較指標、行政邊界分析。
- **熱圖 (Heatmap)**：密度分佈、存在大量重疊點時。

### 效能

- 散佈圖：限制在 500-1000 個點以內。
- 熱圖：可處理 5000 個以上的點。
- 區域圖：受區域數量限制 (通常沒問題)。

### 顏色建議

**順序性 (Sequential)** (低到高)：同色相由淺到深。
```yaml
colorRange: ["#f0f9ff", "#0284c7"]
```

**發散性 (Diverging)** (負到正)：兩種顏色經過中性色。
```yaml
colorRange: ["#dc2626", "#f3f4f6", "#22c55e"]
```

## 常見問題

| 問題 | 解決方案 |
|-------|----------|
| 區域未顯示資料 | 檢查 `geoJsonPropertyKey` 是否與資料完全匹配 (區分大小寫) |
| 點未顯示 | 驗證經緯度是否有效 (-90 到 90, -180 到 180) |
| 未顯示顏色 | 確保 `valueFieldId` 已包含在指標查詢中 |
| 氣泡大小皆相同 | 加入具有變動數值的 `sizeFieldId` |

## 相關資源

- [圖表類型參考](./chart-types-reference_zh_TW.md) - 其他視覺化類型
- [指標參考](./metrics-reference_zh_TW.md) - 為地圖建立指標
- [維度參考](./dimensions-reference_zh_TW.md) - 位置維度
