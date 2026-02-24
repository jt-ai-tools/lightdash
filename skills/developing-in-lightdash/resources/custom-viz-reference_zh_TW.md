# 自定義視覺化參考 (Custom Visualizations Reference)

Lightdash 中的自定義視覺化功能允許您使用 Vega-Lite 規範建立進階且量身定制的圖表。這是一項針對需要 Lightdash 內建圖表類型以外的視覺化類型的進階功能。

有關詳細架構，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json) 中的 `$defs/customVis`。

## 總覽

自定義視覺化與 Vega-Lite 整合，Vega-Lite 是一種用於建立互動式視覺化的聲明式語法。Lightdash 會自動將您的查詢結果提供給 Vega-Lite 規範，讓您精確定義資料應如何被視覺化。

**何時使用自定義視覺化：**
- 您需要的視覺化類型在 Lightdash 的內建圖表 (長條圖、摺線圖、圓餅圖、表格等) 中無法使用。
- 您需要對視覺編碼 (visual encoding) 進行細粒度的控制。
- 您想要使用 Vega-Lite 的進階功能，如分層圖表 (layered charts)、投影 (projections) 或複雜的轉換。

**需求：**
- 熟悉 Vega-Lite 規範 (請參閱 [Vega-Lite 官方文件](https://vega.github.io/vega-lite/))。
- 了解您的資料結構和欄位名稱。

## 配置

### chartConfig.type
對於自定義視覺化，必須設定為 `"custom"`。

### chartConfig.config.spec
類型：`object`

完整的 Vega-Lite 規範物件。此物件定義了您的資料將如何被視覺化。

**關鍵屬性：**
- `$schema`：(必填) Vega-Lite 架構 URL，通常為 `https://vega.github.io/schema/vega-lite/v5.json`。
- `mark`：視覺標記類型 (bar, line, point, area, rect 等)。
- `encoding`：將資料欄位映射到視覺屬性 (x, y, color, size 等)。
- `transform`：資料轉換 (filter, calculate, aggregate 等)。
- `layer`：用於分層/複合圖表。
- `projection`：用於地理視覺化。

## Lightdash 如何提供資料

Lightdash 會自動將您的查詢結果提供給 Vega-Lite 規範：

- 資料以物件陣列的形式提供在 `values` 鍵下。
- Vega-Lite 規範中的欄位名稱必須與您 `metricQuery` 中的欄位名稱 (維度、指標和資料表計算) 匹配。
- 欄位名稱使用 `資料表_欄位` 的格式 (例如：`orders_status`, `orders_count`)。

**您不需要在規範中指定 `data` 屬性** —— Lightdash 會自動提供。

## 範例

### 基本長條圖

顯示各狀態訂單數量的簡單長條圖：

```yaml
chartConfig:
  type: custom
  config:
    spec:
      $schema: https://vega.github.io/schema/vega-lite/v5.json
      mark: bar
      encoding:
        x:
          field: orders_status
          type: nominal
          axis:
            labelColor: '#6e7079'
            tickColor: '#6e7079'
        y:
          field: orders_count
          type: quantitative
          axis:
            labelColor: '#6e7079'
            tickColor: '#6e7079'
```

### 熱圖 (Heatmap)

顯示跨兩個維度聚合值的熱圖：

```yaml
chartConfig:
  type: custom
  config:
    spec:
      $schema: https://vega.github.io/schema/vega-lite/v5.json
      mark: rect
      encoding:
        x:
          field: orders_created_month
          type: ordinal
        y:
          field: products_category
          type: nominal
        color:
          field: orders_total_revenue
          type: quantitative
          aggregate: sum
          scale:
            scheme: blues
```

## 提示與最佳實踐

1. **從範本開始**：在互動式建立自定義視覺化時，使用 Lightdash UI 的範本庫，然後匯出為 YAML。
2. **欄位名稱**：務必使用完整名稱引用欄位 (例如：`orders_status`，而非僅僅是 `status`)。
3. **資料類型**：確保 Vega-Lite 的資料類型與您的欄位類型匹配：
   - `nominal`：無順序的分類資料。
   - `ordinal`：有順序的分類資料。
   - `quantitative`：數值資料。
   - `temporal`：日期/時間資料。
4. **樣式設定**：使用一致的顏色 (例如：軸標籤使用 `#6e7079`) 以配合 Lightdash 的主題。
5. **測試**：在將其加入以程式碼定義圖表之前，先在 [Vega-Lite 編輯器](https://vega.github.io/editor/) 中測試您的 Vega-Lite 規範。
6. **保持簡單**：複雜的視覺化難以維護——請考慮內建圖表類型是否能滿足需求。

## 進階資源

- [Vega-Lite 官方文件](https://vega.github.io/vega-lite/)
- [Vega-Lite 範例庫](https://vega.github.io/vega-lite/examples/)
- [Vega-Lite 互動式編輯器](https://vega.github.io/editor/)
