# 矩形式樹狀圖參考 (Treemap Chart Reference)

矩形式樹狀圖 (Treemap charts) 使用巢狀矩形來視覺化階層式資料。每個矩形的大小代表一個定量指標 (如營收或計數)，而巢狀結構則顯示階層關係 (如類別 > 子類別 > 產品)。

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/treemapChart`。

## 何時使用矩形式樹狀圖

矩形式樹狀圖非常適合用於：

- **階層式資料視覺化**：產品類別、組織結構、檔案系統。
- **部分與整體的關係**：顯示子類別對總體數值的貢獻程度。
- **多層級比較**：在 2-3 個階層級別之間比較數值。
- **節省空間的顯示方式**：在有限的空間內顯示多個項目。
- **雙指標視覺化**：以矩形大小代表一個指標，顏色代表另一個指標。

**在以下情況下使用矩形式樹狀圖：**
- 您有 1-3 層的分類階層。
- 您希望同時顯示組成成分和相對大小。
- 您需要高效地在多個類別之間比較數值。

**在以下情況下應避免使用：**
- 您需要精確的數值比較 (請改用長條圖)。
- 精確的比例至關重要 (請改用圓餅圖/甜甜圈圖)。
- 階層超過 3 層 (過於複雜)。
- 您需要顯示隨時間變化的趨勢 (請改用摺線圖/面積圖)。

## 基本結構

```yaml
chartConfig:
  type: treemap
  config:
    groupFieldIds:
      - category_field
    sizeMetricId: size_metric
```

## 關鍵屬性

| 屬性 | 類型 | 說明 | 必填 |
|----------|------|-------------|----------|
| `groupFieldIds` | 陣列 | 用於階層分組的欄位 ID (1-3 層) | 是 |
| `sizeMetricId` | 字串 | 決定矩形大小的欄位 ID | 是 |
| `colorMetricId` | 字串 | 決定矩形顏色數值的欄位 ID | 否 |
| `visibleMin` | 數字 | 顯示節點的最小大小閾值 | 否 |
| `leafDepth` | 數字 | 顯示為葉節點的深度層級 | 否 |
| `startColor` | 字串 | 漸層起始顏色 (十六進制代碼) | 否 |
| `endColor` | 字串 | 漸層結束顏色 (十六進制代碼) | 否 |
| `useDynamicColors` | 布林值 | 啟用根據數值變化的動態顏色縮放 | 否 |
| `startColorThreshold` | 數字 | 起始顏色的數值閾值 | 否 |
| `endColorThreshold` | 數字 | 結束顏色的數值閾值 | 否 |

## 範例

### 範例 1：兩層階層式矩形式樹狀圖

使用巢狀矩形顯示類別和子類別的營收。

```yaml
version: 1
name: "類別與子類別營收"
slug: category-subcategory-revenue
spaceSlug: sales
tableName: products

metricQuery:
  exploreName: products
  dimensions:
    - products_category
    - products_subcategory
  metrics:
    - products_total_revenue
  sorts:
    - fieldId: products_total_revenue
      descending: true
  limit: 50

chartConfig:
  type: treemap
  config:
    groupFieldIds:
      - products_category
      - products_subcategory
    sizeMetricId: products_total_revenue
    visibleMin: 1000           # 隱藏小於 $1000 的矩形
```

**使用案例**：理解營收在類別和子類別層級的組成。`visibleMin` 設定可防止極小的矩形干擾視覺。

### 範例 2：基於第二指標的顏色漸層

以矩形大小代表營收，顏色代表利潤率以顯示獲利能力。

```yaml
version: 1
name: "各類別營收與利潤率"
slug: revenue-margin-by-category
spaceSlug: sales
tableName: products

metricQuery:
  exploreName: products
  dimensions:
    - products_category
  metrics:
    - products_total_revenue
    - products_profit_margin
  sorts:
    - fieldId: products_total_revenue
      descending: true
  limit: 25

chartConfig:
  type: treemap
  config:
    groupFieldIds:
      - products_category
    sizeMetricId: products_total_revenue
    colorMetricId: products_profit_margin
    startColor: "#ef4444"      # 低利潤率顯示為紅色
    endColor: "#22c55e"        # 高利潤率顯示為綠色
```

**使用案例**：快速識別營收高 (大矩形) 但利潤率低 (紅色) 且需要關注的類別。

## 最佳實踐

### 階層設計

1. **限制深度為 2-3 層**：層級過多會導致難以閱讀。
2. **邏輯排序分組**：將最重要或最大的項目排在前面。
3. **使用有意義的分組**：遵循自然階層 (例如：地理區域 > 州/省 > 城市)。

### 大小指標選擇

1. **選擇可累加的指標**：如總和、計數 (而非平均值或比率)。
2. **使用正數**：負數無法在矩形式樹狀圖中良好呈現。
3. **添加 `visibleMin`**：隱藏干擾視覺的微小矩形。

### 顏色策略

1. **簡單階層使用單一顏色**：讓矩形大小來傳達訊息。
2. **績效指標使用漸層色**：紅到綠代表差到好的範圍。
3. **設定明確閾值**：使用 `startColorThreshold` 和 `endColorThreshold` 定義清晰的範圍。

### 資料準備

1. **限制總矩形數量**：20-100 個可獲得最佳可讀性 (在 metricQuery 中使用 `limit`)。
2. **按大小指標排序**：由大到小排序以建立視覺層次感。
3. **過濾極端值**：極小或極大的數值可能會使視覺化失真。

## 疑難排解

### 小矩形過多

**問題**：圖表被微小矩形擠滿。
**解決方案**：
- 調高 `visibleMin` 以隱藏小數值。
- 減少 metricQuery 中的 `limit`。
- 添加篩選器以排除低價值的類別。

### 階層未顯示

**問題**：僅顯示扁平化類別，而非巢狀結構。
**解決方案**：
- 驗證 `groupFieldIds` 陣列中是否包含多個欄位。
- 檢查 metricQuery 中是否已包含這些維度。
- 若有指定 `leafDepth`，請確認其設定。

### 顏色未顯示

**問題**：所有矩形顏色相同或出現非預期顏色。
**解決方案**：
- 驗證 `colorMetricId` 是否包含在 metricQuery 的指標中。
- 檢查顏色指標的數值是否有變化。
- 設定明確的 `startColor` 和 `endColor`。

## 比較：矩形式樹狀圖 vs 其他圖表

| 需求 | 使用矩形式樹狀圖 | 替代方案 |
|------|-------------|-------------|
| 簡單的部分與整體關係 | 視情況而定 | 圓餅圖/甜甜圈圖 (對 3-7 個類別更清晰) |
| 階層式資料 | 是 | 旭日圖 (Sunburst，圓形替代方案) |
| 精確的數值比較 | 否 | 長條圖 (更容易比較長度) |
| 類別數量眾多 | 是 | 表格 (用於檢視精確數值) |
| 雙指標呈現 | 是 | 泡泡圖 (用於 2 個指標 + 類別) |
| 隨時間變化的趨勢 | 否 | 摺線圖/面積圖 |

## 相關文件

- [圖表類型參考](./chart-types-reference_zh_TW.md) - 所有圖表類型的概覽
- [儀表板參考](./dashboard-reference_zh_TW.md) - 在儀表板中使用矩形式樹狀圖
- [工作流程參考](./workflows-reference_zh_TW.md) - 以程式碼定義圖表的工作流程
