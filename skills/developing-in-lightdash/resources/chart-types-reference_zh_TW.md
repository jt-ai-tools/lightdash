# 圖表類型參考 (Chart Types Reference)

本文件概述了 Lightdash 「圖表即代碼」(charts-as-code) 中可用的所有圖表類型。

如需完整的 Schema 細節，請參閱 [chart-as-code-1.0.json](schemas/chart-as-code-1.0.json)。

## 圖表類型索引

每種圖表類型都有其詳細的參考文件，包含配置選項、範例和最佳實踐。

| 類型 | 描述 | 參考連結 |
|------|-------------|-----------|
| `cartesian` | 具有 X/Y 軸的柱狀圖、折線圖、面積圖、散點圖 | [笛卡爾圖表參考](./cartesian-chart-reference_zh_TW.md) |
| `pie` | 用於顯示部分與整體關係的圓餅圖和環形圖 | [圓餅圖參考](./pie-chart-reference_zh_TW.md) |
| `table` | 具有欄位格式化和條件樣式的數據表格 | [表格圖表參考](./table-chart-reference_zh_TW.md) |
| `big_number` | 顯示單一 KPI 指標，並可選配比較功能 | [大數字圖表參考](./big-number-chart-reference_zh_TW.md) |
| `funnel` | 用於追蹤階段進度的轉化漏斗圖 | [漏斗圖參考](./funnel-chart-reference_zh_TW.md) |
| `gauge` | 用於顯示目標達成進度的儀表圖 | [儀表圖參考](./gauge-chart-reference_zh_TW.md) |
| `treemap` | 用於嵌套分類數據的分層矩形樹圖 | [矩形樹圖參考](./treemap-chart-reference_zh_TW.md) |
| `map` | 帶有標記或區域的地圖地理視覺化 | [地圖圖表參考](./map-chart-reference_zh_TW.md) |
| `custom` | 用於進階視覺化的 Vega-Lite 自定義圖表 | [自定義視覺化參考](./custom-viz-reference_zh_TW.md) |

## 圖表類型快速選擇指南

根據您的數據模式選擇合適的圖表類型：

| 數據模式 | 推薦圖表 | 原因 |
|--------------|-------------------|-----|
| 隨時間變化的趨勢 | 折線圖或面積圖 (`cartesian`) | 以 X 軸顯示隨時間的連續變化 |
| 類別比較 | 柱狀圖 (`cartesian`) | 輕鬆在離散類別之間進行視覺化比較 |
| 部分與整體的關係 | `pie` 或 `treemap` | 顯示各部分佔比（總和為 100%） |
| 單一 KPI 指標 | `big_number` | 將注意力集中在一個重要數值上 |
| 轉化階段 | `funnel` | 視覺化連續步驟之間的流失情況 |
| 目標達成進度 | `gauge` | 顯示當前數值相對於目標的比例 |
| 地理數據 | `map` | 在地圖上繪製數據點或區域 |
| 詳細記錄 | `table` | 顯示原始數據，並具備排序和格式化功能 |
| 進階自定義需求 | `custom` | 使用完整的 Vega-Lite 規範進行自定義視覺化 |

## 常用圖表配置

所有圖表類型都共用一個基本的結構：

```yaml
version: 1
name: "圖表名稱"
slug: unique-chart-slug
spaceSlug: target-space
tableName: my_explore
updatedAt: "2024-01-01T00:00:00.000Z"

metricQuery:
  dimensions:
    - my_explore_category
  metrics:
    - my_explore_total_sales
  filters: {}
  sorts: []
  limit: 500

chartConfig:
  type: <type>  # 上述列出的其中一種類型
  config:
    # 類型特定的視覺化配置

tableConfig:
  columnOrder: []
```

請參閱各別的圖表參考文件以了解類型特定的 `chartConfig.config` 選項。
