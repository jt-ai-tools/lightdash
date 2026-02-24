# 圓餅圖參考 (Pie Chart Reference)

Lightdash 以程式碼定義圖表 (charts-as-code) 的圓餅圖與甜甜圈圖配置指南。

> **架構參考**：有關完整的架構定義，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/pieChart`。

## 總覽

圓餅圖將圓形劃分為與每個類別數值成比例的切片，用以顯示部分與整體的關係。甜甜圈圖與圓餅圖相同，但中心是空心的，這在比較多個圖表時可能更容易閱讀。

### 何時使用

**最適用於：**
- 顯示整體的比例 (總和為 100% 的百分比)。
- 比較 3-7 個類別。
- 當相對比例比精確數值更重要時。

**應避免：**
- 比較過多類別 (>7 個切片)。
- 需要精確比較時 (請改用長條圖)。
- 顯示隨時間變化的情況 (請改用摺線圖)。

### 圓餅圖 vs 甜甜圈圖

| 特性 | 圓餅圖 | 甜甜圈圖 |
|---------|-----------|-------------|
| 視覺效果 | 實心圓 | 帶孔的環狀 |
| 使用案例 | 專注於單一指標 | 較適合用於比較 |
| 中心空間 | 無 | 可顯示總計/摘要 |

## 基本結構

每個圓餅圖都需要：
1. `groupFieldIds` - 一個或多個用於切分的維度欄位。
2. `metricId` - 要測量的指標。
3. 圖表類型設定為 `pie`。

```yaml
version: 1
name: "各產品類別營收"
slug: revenue-by-category
spaceSlug: sales
tableName: orders

metricQuery:
  exploreName: orders
  dimensions:
    - orders_product_category
  metrics:
    - orders_total_revenue
  sorts:
    - fieldId: orders_total_revenue
      descending: true
  limit: 10

chartConfig:
  type: pie
  config:
    groupFieldIds:
      - orders_product_category
    metricId: orders_total_revenue
```

## 配置選項

### 核心設定

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `groupFieldIds` | `string[]` | 用於切分的欄位 ID 陣列 (必填) |
| `metricId` | `string` | 要顯示的指標 (必填) |
| `isDonut` | `boolean` | `true` = 中心空心的甜甜圈圖 |

### 數值標籤

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `valueLabel` | `"hidden" \| "inside" \| "outside"` | 切片上標籤的位置 |
| `showValue` | `boolean` | 顯示實際數值 |
| `showPercentage` | `boolean` | 顯示總計的百分比 |

### 圖例 (Legend)

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `showLegend` | `boolean` | 顯示/隱藏圖例 |
| `legendPosition` | `"horizontal" \| "vertical"` | 圖例方向 |
| `legendMaxItemLength` | `number` | 截斷前的最大字元數 |

### 自定義

| 屬性 | 類型 | 說明 |
|----------|------|-------------|
| `groupLabelOverrides` | `Record<string, string>` | 切片的自定義顯示標籤 |
| `groupColorOverrides` | `Record<string, string>` | 切片的自定義十六進制顏色 |
| `groupSortOverrides` | `string[]` | 自定義排序順序 (從頂部順時針方向) |
| `groupValueOptionOverrides` | `Record<string, {...}>` | 個別切片的顯示選項 |

## 完整範例

帶有自定義顏色和標籤的甜甜圈圖：

```yaml
version: 1
name: "區域銷售績效"
slug: regional-sales
spaceSlug: sales
tableName: orders
updatedAt: 2026-01-30T10:00:00Z

metricQuery:
  exploreName: orders
  dimensions:
    - orders_region
  metrics:
    - orders_total_revenue
  sorts:
    - fieldId: orders_total_revenue
      descending: true
  limit: 8

chartConfig:
  type: pie
  config:
    groupFieldIds:
      - orders_region
    metricId: orders_total_revenue

    # 甜甜圈圖
    isDonut: true

    # 標籤
    valueLabel: inside
    showValue: true
    showPercentage: true

    # 圖例
    showLegend: true
    legendPosition: vertical

    # 為區域代碼設定自定義標籤
    groupLabelOverrides:
      "NA": "北美洲"
      "EMEA": "歐洲、中東與非洲"
      "APAC": "亞太地區"
      "LATAM": "拉丁美洲"

    # 為區域設定品牌顏色
    groupColorOverrides:
      "NA": "#3b82f6"
      "EMEA": "#10b981"
      "APAC": "#f59e0b"
      "LATAM": "#ef4444"
      "Other": "#94a3b8"

    # 隱藏較小的「其他 (Other)」切片的標籤
    groupValueOptionOverrides:
      "Other":
        valueLabel: hidden

    # 自定義排序順序
    groupSortOverrides:
      - "NA"
      - "EMEA"
      - "APAC"
      - "LATAM"
      - "Other"
```

## 最佳實踐

### 資料準備

1. **限制類別數量**：3-7 個切片可獲得最佳可讀性。
2. **按數值排序**：使用 `metricQuery.sorts` 將最大的切片排在第一位。
3. **分組較小值**：在您的 dbt 模型中將較小的切片合併為「其他」。

### 視覺設計

1. **使用甜甜圈圖以獲得現代感**：設定 `isDonut: true`。
2. **優先顯示百分比而非數值**：對圓餅圖而言，百分比更有意義。
3. **保持顏色一致**：相同類別在不同圖表中應使用相同顏色。
4. **淡化「其他」**：對於雜項類別，使用灰色 (`#94a3b8`)。

### 標籤放置

| 位置 | 最適用於 |
|----------|----------|
| `inside` | 少數切片 (3-5 個)、較大的切片 |
| `outside` | 較多切片 (6-7 個)、較長的標籤 |
| `hidden` | 7 個以上切片、已有詳細圖例的情況 |

### 顏色選擇

- **順序性 (Sequential)**：有序類別由淺到深。
- **類別性 (Categorical)**：無序類別使用截然不同的顏色。
- **語義性 (Semantic)**：綠色代表良好，紅色代表不良，黃色代表警告。

## 疑難排解

### 切片太小難以閱讀

隱藏小切片的標籤：
```yaml
groupValueOptionOverrides:
  "Small Category":
    valueLabel: hidden
```

### 顏色未套用

- 檢查拼字 (區分大小寫)。
- 驗證十六進制格式 (`#RRGGBB`)。
- 確保數值與資料完全匹配。

### 圖例被截斷

```yaml
legendMaxItemLength: 100
legendPosition: vertical
```

## 相關文件

- [圖表類型參考](chart-types-reference_zh_TW.md)
- [指標參考](metrics-reference_zh_TW.md)
- [維度參考](dimensions-reference_zh_TW.md)
