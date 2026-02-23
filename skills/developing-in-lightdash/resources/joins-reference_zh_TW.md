# 連接參考 (Joins Reference)

連接 (Joins) 將多個表格聯繫在一起，讓您可以在單個查詢中結合來自多個模型的數據。

## 基本連接配置

```yaml
models:
  - name: orders
    meta:
      joins:
        - join: customers
          sql_on: "${orders.customer_id} = ${customers.customer_id}"
```

## 連接屬性

### 必要屬性

| 屬性 | 描述 |
|----------|-------------|
| `join` | 要連接的模型名稱 |
| `sql_on` | SQL 連接條件 |

### 選填屬性

| 屬性 | 描述 | 預設值 |
|----------|-------------|---------|
| `type` | 連接類型 | `left` |
| `alias` | 已連接模型的別名 | 模型名稱 |
| `label` | 顯示標籤 | 模型標籤 |
| `fields` | 限制包含的欄位 | 所有欄位 |
| `relationship` | 關聯性 (基數) 提示 | 無 |

## 連接類型 (Join Types)

```yaml
joins:
  - join: customers
    sql_on: "${orders.customer_id} = ${customers.customer_id}"
    type: left      # 左連接 (LEFT JOIN，預設)

  - join: required_data
    sql_on: "..."
    type: inner     # 內連接 (INNER JOIN)

  - join: all_combinations
    sql_on: "..."
    type: full      # 全外連接 (FULL OUTER JOIN)
```

**何時使用各種類型：**

| 類型 | 使用時機 |
|------|----------|
| `left` | 基礎表行應始終顯示，被連接的數據是可選的 |
| `inner` | 僅顯示兩個表都有數據的行 |
| `full` | 顯示兩個表的所有行（較罕見） |

## 關聯性類型 (Relationship Types)

指定關聯性以幫助 Lightdash 優化查詢：

```yaml
joins:
  - join: customers
    sql_on: "${orders.customer_id} = ${customers.customer_id}"
    relationship: many-to-one    # 每個客戶有多個訂單

  - join: order_items
    sql_on: "${orders.order_id} = ${order_items.order_id}"
    relationship: one-to-many    # 一個訂單有多個項目

  - join: user_profile
    sql_on: "${users.user_id} = ${user_profile.user_id}"
    relationship: one-to-one     # 每個用戶一個個人資料
```

**關聯性含義：**

| 關聯性 | 描述 | 範例 |
|--------------|-------------|---------|
| `one-to-one` | 一對一：每一行精確匹配一行 | 用戶 → 個人資料 |
| `one-to-many` | 一對多：基礎表的一行匹配多個連接行 | 訂單 → 訂單項目 |
| `many-to-one` | 多對一：多個基礎表行匹配一個連接行 | 訂單 → 客戶 |
| `many-to-many` | 多對多：雙向皆有多個匹配 | 產品 ↔ 標籤 |

## 使用別名 (Aliasing)

使用別名多次連接同一個表：

```yaml
joins:
  - join: users
    alias: created_by_user
    sql_on: "${orders.created_by} = ${created_by_user.user_id}"
    label: "建立者"

  - join: users
    alias: assigned_to_user
    sql_on: "${orders.assigned_to} = ${assigned_to_user.user_id}"
    label: "指派給"
```

## 限制欄位 (Limiting Fields)

僅包含來自被連接表的特定欄位：

```yaml
joins:
  - join: customers
    sql_on: "${orders.customer_id} = ${customers.customer_id}"
    fields:
      - customer_name
      - email
      - segment
```

## 最佳實踐

1. **選擇正確的連接類型**：使用 `left` 以保留基礎表的所有行，僅在兩側數據均為必要時使用 `inner`。
2. **指定關聯性 (Relationships)**：幫助 Lightdash 優化數據展開 (fan-out) 的計算。
3. **對自連接使用別名**：當多次連接同一個表時。
4. **適當限制欄位**：僅包含需要的欄位以減少混亂。
5. **添加清晰的標籤**：幫助用戶理解正在連接的數據是什麼。
6. **使用隱藏連接處理內部數據**：將查找表從 UI 中隱藏 (`hidden: true`)。
7. **測試連接結果**：驗證行數是否符合預期。
8. **使用 sql_on 處理複雜邏輯**：例如多條件連接、日期範圍等。
