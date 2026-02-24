管理 Docker 開發環境。參數：(無) = 啟動，`reset` = 重設資料庫，`stop` = 停止服務。

## 參數

- **無參數**：自動偵測狀態並執行必要操作 (全新設定、遷移或僅啟動)。
- **`reset`**：強制重設資料庫並重新構建 dbt 模型。
- **`stop`**：停止 Docker 服務 (保留資料磁碟卷)。

## 狀態偵測

在採取行動前，請檢查目前的環境狀態。**同時執行這些檢查**以快速確定需要做什麼：

### 所有檢查 (平行執行)

```bash
# 檢查 1：所有 Docker 服務是否正常執行 (db, minio, headless-browser, mailpit)
RUNNING_COUNT=$(docker compose -f docker/docker-compose.dev.mini.yml ps --format json 2>/dev/null | grep -c '"State":"running"' || true)
[ "$RUNNING_COUNT" -ge 4 ] && echo "OK: 所有 Docker 服務執行中 ($RUNNING_COUNT)" || echo "NEED: 啟動 Docker 服務 (僅 $RUNNING_COUNT/4 執行中)"

# 檢查 2：環境檔案是否存在
test -f .env.development.local && echo "OK: 環境檔案已存在" || echo "NEED: 建立 .env.development.local"

# 檢查 3：CLAUDE.local.md 是否具有本地開發指令
grep -q "## Starting Development Services" CLAUDE.local.md 2>/dev/null && echo "OK: CLAUDE.local.md 具有本地開發指令" || echo "NEED: 在 CLAUDE.local.md 中加入本地開發指令"

# 檢查 4：依賴套件是否已安裝
test -d node_modules && test -d packages/common/dist && echo "OK: 依賴套件已安裝" || echo "NEED: 執行 pnpm install 並構建"

# 檢查 5：Python/dbt 環境是否就緒
test -f venv/bin/dbt && test -f venv/bin/dbt1.7 && echo "OK: Python/dbt 已就緒" || echo "NEED: 設定 Python venv"

# 檢查 6：資料庫是否已遷移 (需要 Docker 執行中)
docker exec docker-db-dev-1 psql -U postgres -tAc "SELECT CASE WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name='sessions') THEN 'migrated' ELSE 'not_migrated' END" 2>&1 | grep -q "^migrated" && echo "OK: 資料庫已遷移" || echo "NEED: 執行遷移"

# 檢查 7：資料庫是否已填入種子資料 (需要 Docker 執行中)
docker exec docker-db-dev-1 psql -U postgres -tAc "SELECT CASE WHEN EXISTS(SELECT 1 FROM emails WHERE email='demo@lightdash.com') THEN 'seeded' ELSE 'not_seeded' END" 2>&1 | grep -q "^seeded" && echo "OK: 資料庫已填入種子資料" || echo "NEED: 填入種子資料"

# 檢查 8：dbt 模型是否已構建 (需要 Docker 執行中)
docker exec docker-db-dev-1 psql -U postgres -tAc "SELECT CASE WHEN EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema='jaffle' AND table_name='orders') THEN 'built' ELSE 'not_built' END" 2>&1 | grep -q "^built" && echo "OK: dbt 模型已構建" || echo "NEED: 構建 dbt 模型"
```

**如何解讀輸出：**

- 以 `NEED:` 開頭的行表示必須執行的設定步驟。
- 以 `OK:` 開頭的行表示該組件已就緒。
- 如果所有行都顯示 `OK:`，則環境已就緒——只需啟動開發伺服器。
- 資料庫檢查 (6-8) 使用 `docker exec` 在 PostgreSQL 容器內執行 psql。
- 先平行執行檢查 1-5，然後平行執行檢查 6-8 (後者依賴於 Docker 的執行)。

### 為什麼對資料庫檢查使用 `docker exec`？

PostgreSQL 在 Docker 容器內執行，因此我們使用 `docker exec docker-db-dev-1 psql` 而不是本地的 `psql` 用戶端。這樣做的優點：

- 不需要本地安裝 psql。
- 使用與應用程式完全相同的連接。
- 如果 Docker 未執行則會明確失敗 (這也是首先需要解決的問題)。

### 資料庫檢查細節

**為什麼使用 `information_schema` 而非直接查詢？**

- 檢查 `SELECT 1 FROM tablename` 可能會因「關聯不存在 (relation does not exist)」錯誤而失敗。
- 使用 `information_schema.tables` 總是能成功並返回清晰的結果。
- `CASE WHEN EXISTS(...)` 模式返回確定性的字串，方便解析。

**為什麼檢查 `emails` 資料表來判斷種子資料狀態？**

- 示範使用者的電子郵件 (`demo@lightdash.com`) 位於 `emails` 資料表中，而非 `users`。
- `users` 資料表沒有 `email` 欄位 (Lightdash 將使用者身分與電子郵件分開)。
- 另外還有一個 `jaffle.users` 的 dbt 模型，這會造成歧義。

## 設定步驟 (根據需要執行)

### 前置要求 (macOS)

如果 `pnpm install` 因 canvas 錯誤而失敗 - 請參閱此指南：https://github.com/Automattic/node-canvas?tab=readme-ov-file#installation

### 啟動 Docker 服務

```bash
docker compose -f docker/docker-compose.dev.mini.yml --env-file .env.development up -d
```

等待幾秒鐘讓 PostgreSQL 就緒。

### 建立環境檔案

建立包含 localhost 覆蓋設定的 `.env.development.local`：

```bash
cat > .env.development.local << 'EOF'
# 本地開發覆蓋設定
PGHOST=localhost
S3_ENDPOINT=http://localhost:9000
HEADLESS_BROWSER_HOST=localhost
HEADLESS_BROWSER_PORT=3001
INTERNAL_LIGHTDASH_HOST=http://localhost:3000

# 電子郵件 - Mailpit (在 http://localhost:8025 查看郵件)
EMAIL_SMTP_HOST=localhost
EMAIL_SMTP_PORT=1025
EMAIL_SMTP_SECURE=false
EMAIL_SMTP_USE_AUTH=false
EMAIL_SMTP_ALLOW_INVALID_CERT=true
EMAIL_SMTP_SENDER_NAME=Lightdash
EMAIL_SMTP_SENDER_EMAIL=noreply@lightdash.local
EOF
```

然後加入帶有實際路徑的 DBT_DEMO_DIR：

```bash
echo "DBT_DEMO_DIR=$(pwd)/examples/full-jaffle-shop-demo" >> .env.development.local
```

### 在 CLAUDE.local.md 中加入本地開發指令

**重要：在修改 CLAUDE.local.md 之前，您必須徵得使用者的同意。** 使用 AskUserQuestion 進行確認：

> "docker-dev 設定可以將 PM2 指令與除錯指引加入到 CLAUDE.local.md 中。這包括 PM2 的啟動/停止/重啟指令，以及關於搭配 Spotlight 使用 /debug-local 技能的指引。我可以加入這些說明嗎？"

**僅在使用者確認後才繼續此步驟。** 如果被拒絕，請跳過此步驟並繼續其餘設定。

獲得許可後，將本地開發指令附加到 `CLAUDE.local.md` (如果檔案不存在則建立，存在則附加)：

````bash
cat >> CLAUDE.local.md << 'EOF'
# 本地開發環境

## 啟動開發服務

### 前置要求：Docker 服務

在執行開發伺服器之前，請先啟動 Docker 服務 (PostgreSQL, MinIO, headless browser, Mailpit)：

```bash
/docker-dev
```

### PM2 (建議用於 LLM 開發)

PM2 提供程序隔離、個別服務重啟與監控功能：

```bash
pnpm pm2:start          # 啟動所有服務
pnpm pm2:logs           # 串流所有日誌
pnpm pm2:logs:api --lines 50 --nostream  # 查看最後 50 行而不串流
pnpm pm2:status         # 檢查程序狀態
pnpm pm2:restart:api    # 僅重啟 API 伺服器
pnpm pm2:monit          # 互動式監控儀表板
pnpm pm2:stop           # 停止所有服務
```

## 除錯 (Debugging)

**遇到問題時，第一步總是使用 `/debug-local` 技能**以了解發生了什麼。此技能提供了完整的除錯工作流程。

使用 `/debug-local` 技能進行綜合除錯工作流程，結合：

- **PM2 日誌**：`pnpm pm2:logs:api` 查看帶有追蹤 ID (trace IDs) 的 API 伺服器日誌。
- **Spotlight MCP**：透過 `mcp__spotlight__search_traces`, `mcp__spotlight__get_traces`, `mcp__spotlight__search_errors` 以程式化方式查詢追蹤與錯誤。
- **瀏覽器自動化**：使用 Chrome DevTools MCP (`mcp__chrome-devtools__*`) 進行 UI 除錯。

執行 `pnpm pm2:start` 時，Spotlight UI 可在 http://localhost:8969 使用。
EOF
````

### 安裝依賴套件

```bash
pnpm install
pnpm -F common build && pnpm -F warehouses build
```

### 設定 Python/dbt

```bash
python3 -m venv venv
source venv/bin/activate
pip install dbt-core==1.7.0 dbt-postgres==1.7.0 'protobuf>=4.0.0,<5.0.0'
ln -sf venv/bin/dbt venv/bin/dbt1.7
```

### 執行遷移

```bash
PGHOST=localhost pnpx dotenv-cli -e .env.development -- pnpm -F backend migrate
```

### 填入種子資料

```bash
export PATH="$(pwd)/venv/bin:$PATH"
export DBT_DEMO_DIR=$(pwd)/examples/full-jaffle-shop-demo
PGHOST=localhost pnpx dotenv-cli -e .env.development -- pnpm -F backend seed
```

### 構建 dbt 模型

**重要**：使用 venv 中 `dbt` 的完整路徑，以避免「找不到指令」錯誤：

```bash
PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=postgres 
  "$(pwd)/venv/bin/dbt" seed --project-dir examples/full-jaffle-shop-demo/dbt --profiles-dir examples/full-jaffle-shop-demo/profiles
PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=postgres 
  "$(pwd)/venv/bin/dbt" run --project-dir examples/full-jaffle-shop-demo/dbt --profiles-dir examples/full-jaffle-shop-demo/profiles
```

## 重設步驟 (提供 `reset` 參數時)

如果使用者傳入 `reset` 作為參數，則無論目前狀態如何，強制執行完整的資料庫重設：

```bash
# 確保 Docker 已先啟動
docker compose -f docker/docker-compose.dev.mini.yml --env-file .env.development up -d

# 設定環境
export PATH="$(pwd)/venv/bin:$PATH"
export DBT_DEMO_DIR=$(pwd)/examples/full-jaffle-shop-demo

# 重設資料庫、執行遷移並填入種子資料
PGHOST=localhost pnpx dotenv-cli -e .env.development -- ./scripts/reset-db.sh

# 重新構建 dbt 模型
PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=postgres 
  "$(pwd)/venv/bin/dbt" seed --project-dir examples/full-jaffle-shop-demo/dbt --profiles-dir examples/full-jaffle-shop-demo/profiles
PGHOST=localhost PGPORT=5432 PGUSER=postgres PGPASSWORD=password PGDATABASE=postgres 
  "$(pwd)/venv/bin/dbt" run --project-dir examples/full-jaffle-shop-demo/dbt --profiles-dir examples/full-jaffle-shop-demo/profiles
```

## 停止步驟 (提供 `stop` 參數時)

如果使用者傳入 `stop` 作為參數，則停止 Lightdash 應用程式與 Docker 服務：

```bash
# 先停止 PM2 程序
pnpm pm2:stop

# 然後停止 Docker 服務
docker compose -f docker/docker-compose.dev.mini.yml down
```

這會停止 PM2 程序 (保留其註冊資訊以便快速重啟) 並移除 Docker 容器，但會**保留資料磁碟卷** (資料庫資料、MinIO 檔案)。

要驗證是否已全部停止：

```bash
pnpm pm2:status
docker compose -f docker/docker-compose.dev.mini.yml ps
```

**注意**：傳入 `stop` 時，不要繼續執行「啟動開發伺服器」——只需停止服務並報告狀態。

## 啟動開發伺服器

一旦所有檢查通過或設定完成，請使用 PM2 啟動開發伺服器：

```bash
pnpm pm2:start
```

PM2 提供程序隔離、個別服務重啟與監控——非常適合 LLM 驅動的開發。

**實用的 PM2 指令：**

| 指令 | 說明 |
| ---------------------------- | -------------------------------- |
| `pnpm pm2:logs`              | 串流所有程序日誌 |
| `pnpm pm2:status`            | 顯示程序狀態表 |
| `pnpm pm2:restart:api`       | 僅重啟 API 伺服器 |
| `pnpm pm2:restart:scheduler` | 僅重啟排程器 (scheduler) |
| `pnpm pm2:restart:frontend`  | 僅重啟前端 |
| `pnpm pm2:monit`             | 互動式監控儀表板 |
| `pnpm pm2:stop`              | 停止所有程序 |
| `pnpm pm2:delete`            | 停止並移除所有程序 |

### 替代方案：傳統開發伺服器

如果使用者明確要求使用 `pnpm dev`，請使用傳統的單一終端機方法：

```bash
export PGHOST=localhost S3_ENDPOINT=http://localhost:9000 HEADLESS_BROWSER_HOST=localhost HEADLESS_BROWSER_PORT=3001
pnpx dotenv-cli -e .env.development -- pnpm dev
```

**為什麼建議使用 PM2：**

| 特性 | `pnpm dev` | `pnpm pm2:start` |
| -------------------------- | ------------------ | ----------------------- |
| 程序可見性 | 交錯的輸出 | 個別的狀態/日誌 |
| 重啟個別服務 | 不可行 | `pnpm pm2:restart:api` |
| 記憶體/CPU 監控 | 不提供 | `pnpm pm2:monit` |
| 日誌管理 | 僅限終端機 | 持久的日誌檔案 |
| 背景執行 | 否 | 是 (程序會持續存在) |
| 最適合 | 快速終端機開發 | LLM 控制、除錯 |

## 存取應用程式

- **前端**：http://localhost:3000
- **後端 API**：http://localhost:8080
- **示範登入**：`demo@lightdash.com` / `demo_password!`

## 服務埠號參考 (Service Ports Reference)

| 服務 | 埠號 (Port) | 說明 |
| ----------------- | --------- | -------------------------------- |
| 前端 (Vite) | 3000 | React 開發伺服器 |
| 後端 (Express) | 8080 | API 伺服器 |
| 排程器 (Scheduler) | 8081 | 背景工作處理器 |
| PostgreSQL | 5432 | 資料庫 |
| MinIO | 9000/9001 | 相容於 S3 的儲存/控制台 |
| Headless Browser | 3001 | PDF/圖像生成 |
| Mailpit | 8025/1025 | 電子郵件測試 Web UI/SMTP 伺服器 |

## 疑難排解

### Canvas 安裝失敗 (macOS)

如果 `pnpm install` 因 canvas 錯誤而失敗 - 請參閱此指南：https://github.com/Automattic/node-canvas?tab=readme-ov-file#installation

### PostgreSQL 連線被拒絕

請等待 Docker 服務完全啟動：

```bash
docker compose -f docker/docker-compose.dev.mini.yml ps
```

所有服務應顯示 "running" 狀態。

### MinIO 連線被拒絕 / 查詢結果錯誤

如果在上傳結果時查詢因 `ECONNREFUSED` 而失敗，表示 MinIO 未在執行：

```bash
# 檢查 MinIO 是否正在執行
docker compose -f docker/docker-compose.dev.mini.yml ps | grep minio

# 如果未執行，請啟動所有服務
docker compose -f docker/docker-compose.dev.mini.yml --env-file .env.development up -d
```

MinIO 是儲存非同步查詢結果所必需的。如果沒有它，應用程式將無法載入查詢結果。

### 「關聯不存在 (relation does not exist)」錯誤

- **`sessions`**：遷移未執行 → 此指令會偵測並執行它們。
- **`jaffle.orders`**：dbt 模型未構建 → 此指令會偵測並構建它們。

### 被重新導向到 /register 而非登入頁面

資料庫未填入種子資料 → 此指令會偵測並填入。

### 找不到 dbt 指令

Python venv 未設定 → 此指令會偵測並設定。
