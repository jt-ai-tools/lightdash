# CLI 參考 (CLI Reference)

Lightdash CLI 指令的完整參考手冊。

## 身分驗證 (Authentication)

```bash
# 登入 Lightdash 實例
lightdash login https://app.lightdash.cloud

# 使用 Token 登入 (非互動式)
lightdash login https://app.lightdash.cloud --token YOUR_API_TOKEN

# 列出可用的專案 (不含預覽專案)
lightdash config list-projects

# 顯示目前選定的專案
lightdash config get-project

# 設定活動專案
lightdash config set-project --name "My Project"
lightdash config set-project --uuid abc123-def456
```

## 編譯與部署 (Compilation & Deployment)

```bash
# 編譯 dbt 模型並驗證
lightdash compile --project-dir ./dbt --profiles-dir ./profiles

# 部署至 Lightdash
lightdash deploy --project-dir ./dbt --profiles-dir ./profiles

# 在部署時建立新專案
lightdash deploy --create "New Project Name"

# 忽略驗證錯誤進行部署
lightdash deploy --ignore-errors

# 跳過 dbt 編譯 (使用現有的 manifest)
lightdash deploy --skip-dbt-compile

# 純 Lightdash YAML (無 dbt)
lightdash deploy --no-warehouse-credentials
```

## 預覽專案 (Preview Projects)

```bash
# 建立預覽環境 (監控變更)
lightdash preview --name "feature-branch-preview"

# 啟動預覽但不監控
lightdash start-preview --name "my-preview"

# 停止預覽
lightdash stop-preview --name "my-preview"
```

## 生成 YAML (Generate YAML)

```bash
# 為所有模型生成架構 (schema)
lightdash generate

# 為特定模型生成
lightdash generate -s my_model
lightdash generate -s tag:sales
lightdash generate -s +my_model  # 包含父級模型
```

## 驗證 (Validation)

```bash
# 在本地端對圖表和儀表板 YAML 檔案進行 Lint 檢查 (離線)
lightdash lint --path ./lightdash

# 連接 Lightdash 伺服器進行驗證
lightdash validate --project my-project-uuid

# 將 Lint 結果輸出為 JSON/SARIF 格式
lightdash lint --format json
```

## 下載與上傳內容 (Download & Upload Content)

```bash
# 下載所有圖表與儀表板
lightdash download

# 下載特定內容
lightdash download --charts chart-slug-1 chart-slug-2
lightdash download --dashboards dashboard-slug

# 以巢狀資料夾結構下載
lightdash download --nested

# 上傳修改後的內容
lightdash upload

# 強制上傳 (忽略時間戳記)
lightdash upload --force

# 上傳特定項目
lightdash upload --charts my-chart --dashboards my-dashboard
```

## 刪除內容 (Delete Content)

從伺服器永久刪除圖表和儀表板，並移除其本地 YAML 檔案。

```bash
# 透過 Slug 刪除圖表
lightdash delete -c my-chart

# 透過 Slug 刪除儀表板
lightdash delete -d my-dashboard

# 一次刪除多個項目
lightdash delete -c chart1 chart2 -d dashboard1

# 透過 UUID 刪除
lightdash delete -c abc123-def456

# 透過 URL 刪除
lightdash delete -c "https://app.lightdash.cloud/projects/xxx/saved/abc123"

# 跳過確認提示 (請謹慎使用)
lightdash delete -c my-chart --force

# 指定本地檔案的自定義路徑
lightdash delete -c my-chart --path ./custom-lightdash

# 從特定專案中刪除
lightdash delete -c my-chart --project <project-uuid>
```

**選項：**

- `-c, --charts <charts...>` - 要刪除的圖表 Slug、UUID 或 URL
- `-d, --dashboards <dashboards...>` - 要刪除的儀表板 Slug、UUID 或 URL
- `-f, --force` - 跳過確認提示
- `-p, --path <path>` - 儲存本地「以程式碼定義圖表」檔案的自定義路徑
- `--project <uuid>` - 指定專案 UUID

**警告：** 如果被刪除的圖表正被某些儀表板引用，`delete` 指令會發出警告。

## SQL Runner

使用目前專案的憑證對資料倉庫執行原始 SQL 查詢。

```bash
# 執行查詢並將結果儲存為 CSV
lightdash sql "SELECT * FROM orders LIMIT 10" -o results.csv

# 限制返回的列數
lightdash sql "SELECT * FROM customers" -o customers.csv --limit 1000

# 為大型結果調整分頁 (預設 500，最大 5000)
lightdash sql "SELECT * FROM events" -o events.csv --page-size 2000

# 顯示詳細輸出以進行除錯
lightdash sql "SELECT COUNT(*) FROM users" -o count.csv --verbose
```

**選項：**

- `<query>` - 要執行的 SQL 查詢 (必填)
- `-o, --output <file>` - 輸出 CSV 檔案的路徑 (必填)
- `--limit <number>` - 要返回的最大列數
- `--page-size <number>` - 每頁列數 (預設：500，最大：5000)
- `--verbose` - 顯示詳細輸出

**注意：** 使用目前選定的 Lightdash 專案中的資料倉庫憑證。

## 執行圖表 (Run Chart)

針對資料倉庫執行圖表 YAML 檔案的指標查詢。僅支援指標查詢圖表 (帶有 `tableName` 和 `metricQuery`)，不支援 SQL 圖表。

```bash
# 驗證圖表查詢是否成功執行
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml

# 執行圖表並將結果儲存為 CSV
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml -o results.csv

# 限制返回的列數
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml -o results.csv -l 100

# 為大型結果調整分頁
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml -o results.csv --page-size 2000

# 顯示詳細輸出以進行除錯
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml --verbose
```

**選項：**

- `-p, --path <path>` - 圖表 YAML 檔案路徑 (必填)
- `-o, --output <file>` - 輸出 CSV 檔案路徑
- `-l, --limit <number>` - 要返回的最大列數
- `--page-size <number>` - 每頁列數 (預設：500)
- `--verbose` - 顯示詳細輸出

**注意：**

- 使用目前選定的 Lightdash 專案中的資料倉庫憑證。
- 圖表 YAML 必須包含 `tableName` 和 `metricQuery` 欄位。
- 指標查詢中引用的所有語義層欄位 (維度、指標、自定義維度等) 必須已經部署到 Lightdash 專案中。

## 指令摘要 (Command Summary)

| 指令 | 用途 |
| --------------------- | -------------------------------- |
| `lightdash login`     | 向 Lightdash 進行身分驗證        |
| `lightdash config`    | 管理專案選擇                    |
| `lightdash deploy`    | 將語義層同步至 Lightdash         |
| `lightdash upload`    | 上傳圖表/儀表板                 |
| `lightdash download`  | 下載圖表/儀表板                 |
| `lightdash delete`    | 移除圖表/儀表板                 |
| `lightdash preview`   | 建立臨時測試專案                |
| `lightdash validate`  | 向伺服器進行驗證                |
| `lightdash lint`      | 在本地端驗證 YAML               |
| `lightdash generate`  | 從 dbt 模型生成 YAML            |
| `lightdash sql`       | 執行 SQL 查詢                   |
| `lightdash run-chart` | 執行圖表 YAML 查詢              |
