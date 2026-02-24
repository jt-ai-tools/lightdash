---
name: debug-local
description: 使用 PM2 日誌、Spotlight 追蹤和瀏覽器自動化來除錯 Lightdash 應用程式。用於調查問題、追踪錯誤、理解請求流程，或將前端動作與後端行為關聯起來。
---

# Lightdash 除錯 (Debugging Lightdash)

此技能幫助您使用 PM2 日誌、Spotlight 遙測 (telemetry) 和瀏覽器自動化來除錯 Lightdash。

## 前置要求

確保開發環境正在執行：

```bash
/docker-dev              # 啟動 Docker 服務 (postgres, minio 等)
pnpm pm2:start           # 啟動所有 PM2 程序，包括 Spotlight
pnpm pm2:status          # 驗證所有程序是否已上線
```

服務：
- **前端 (Frontend)**：http://localhost:3000
- **API**：http://localhost:8080
- **Spotlight UI**：http://localhost:8969

## 伺服器日誌 (PM2)

### 查看日誌

```bash
pnpm pm2:logs              # 串流所有日誌 (按 Ctrl+C 退出)
pnpm pm2:logs:api          # 僅 API 伺服器日誌
pnpm pm2:logs:scheduler    # 背景工作排程器日誌
pnpm pm2:logs:frontend     # Vite 開發伺服器日誌
pnpm pm2:logs:spotlight    # Spotlight sidecar 日誌
```

非阻塞式查看日誌 (最後 N 行)：

```bash
pnpm exec pm2 logs lightdash-api --lines 20 --nostream
```

### 日誌格式

Lightdash 日誌包含 32 字元的追蹤 ID (trace ID)，用於關聯：

```
[700aa55e784a437aa97de9b8c5c3ed3a] GET /api/v1/health 200 - 37 ms
[4d40816e5a7d433e88f99008de5f4be5] GET /api/v1/user/login-options 200 - 2 ms
```

使用前 8 個字元 (例如：`700aa55e`) 在 Spotlight 中查找追蹤。

## 追蹤查找 (Spotlight MCP)

使用 Spotlight MCP 工具以程式化方式查詢遙測資料：

### 列出最近的追蹤

```
mcp__spotlight__search_traces 帶有篩選器：{"timeWindow": 300}
```

返回最近追蹤的摘要，包含追蹤 ID、端點、持續時間、span 數量。

### 獲取追蹤詳細資訊

```
mcp__spotlight__get_traces 帶有 traceId："700aa55e"
```

返回完整的 span 樹及時間詳解：

```
GET /api/v1/health [816224a9 · 39ms]
   ├─ select * from "knex_migrations" [db · 8ms]
   ├─ select * from "organizations" [db · 2ms]
   ├─ session [middleware.express · 1ms]
   └─ /api/v1/health [request_handler.express · 0ms]
```

### 搜尋錯誤

```
mcp__spotlight__search_errors 帶有篩選器：{"timeWindow": 300}
```

返回帶有堆疊追蹤 (stack traces) 的執行階段錯誤和異常。

### 搜尋日誌

```
mcp__spotlight__search_logs 帶有篩選器：{"timeWindow": 300}
```

返回應用程式日誌條目。

## 瀏覽器除錯 (Chrome DevTools MCP)

使用 Chrome DevTools MCP 工具進行瀏覽器自動化：

### 開啟頁面

```
mcp__chrome-devtools__new_page 帶有 url: "http://localhost:3000/login"
mcp__chrome-devtools__navigate_page 帶有 url: "http://localhost:3000", type: "url"
```

### 擷取快照 (Snapshot)

```
mcp__chrome-devtools__take_snapshot
```

根據無障礙樹 (accessibility tree) 返回頁面的文字快照，每個元素都有唯一的 `uid` 識別碼。

### 與元素互動

```
mcp__chrome-devtools__click 帶有 uid: "1_5"
mcp__chrome-devtools__fill 帶有 uid: "1_4", value: "test@example.com"
mcp__chrome-devtools__hover 帶有 uid: "1_3"
```

### 螢幕截圖 (Screenshots)

```
mcp__chrome-devtools__take_screenshot
mcp__chrome-devtools__take_screenshot 帶有 fullPage: true
mcp__chrome-devtools__take_screenshot 帶有 filePath: "/tmp/debug.png"
```

### 主控台與網路

```
mcp__chrome-devtools__list_console_messages
mcp__chrome-devtools__list_network_requests
mcp__chrome-devtools__get_network_request 帶有 reqid: 123
```

### 頁面管理

```
mcp__chrome-devtools__list_pages
mcp__chrome-devtools__select_page 帶有 pageId: 1
mcp__chrome-devtools__close_page 帶有 pageId: 2
```

## 端對端 (End-to-End) 除錯工作流程

### 範例：除錯登入失敗

```
# 1. 開啟登入頁面
mcp__chrome-devtools__new_page url: "http://localhost:3000/login"

# 2. 擷取快照以查看表單
mcp__chrome-devtools__take_snapshot

# 3. 填寫表單並提交 (使用快照中的 uid)
mcp__chrome-devtools__fill uid: "1_4", value: "test@example.com"
mcp__chrome-devtools__click uid: "1_5"  # 繼續按鈕
mcp__chrome-devtools__take_snapshot     # 查看密碼欄位
mcp__chrome-devtools__fill uid: "2_2", value: "wrongpassword"
mcp__chrome-devtools__click uid: "2_5"  # 登入按鈕

# 4. 檢查 PM2 日誌中的追蹤 ID
pnpm exec pm2 logs lightdash-api --lines 10 --nostream | grep POST

# 輸出：[a1b2c3d4...] POST /api/v1/user/login/password 401 - 85ms

# 5. 在 Spotlight 中查找完整追蹤
mcp__spotlight__get_traces traceId: "a1b2c3d4"

# 6. 檢查錯誤
mcp__spotlight__search_errors filters: {"timeWindow": 60}
```

### 範例：除錯緩慢的 API 呼叫

```
# 1. 檢查按效能排序的近期追蹤
mcp__spotlight__search_traces filters: {"timeWindow": 300}

# 2. 找到緩慢的追蹤並獲取詳細資訊
mcp__spotlight__get_traces traceId: "<trace-id>"

# 3. 查看 span 詳解以尋找瓶頸
# - db.* span 顯示資料庫查詢時間
# - middleware.express 顯示中介軟體開銷
# - 尋找 N+1 查詢、缺少的索引、過大的結果集
```

### 範例：除錯表單提交錯誤

```
# 1. 即時監控錯誤
mcp__spotlight__search_errors filters: {"timeWindow": 60}

# 2. 在瀏覽器中重現問題
mcp__chrome-devtools__click uid: "submit_button_uid"

# 3. 立即再次檢查錯誤
mcp__spotlight__search_errors filters: {"timeWindow": 60}

# 4. 獲取背景資訊的追蹤
mcp__spotlight__search_traces filters: {"timeWindow": 60}
mcp__spotlight__get_traces traceId: "<trace-id>"
```

### 範例：擷取狀態以供調查

```
mcp__chrome-devtools__take_screenshot filePath: "/tmp/debug-state.png"
mcp__chrome-devtools__take_snapshot
mcp__chrome-devtools__list_console_messages
mcp__chrome-devtools__list_network_requests
```

## 追蹤屬性 (寬事件 - Wide Events)

追蹤除了時間資訊外，還包含背景屬性：

| 屬性 | 範例 | 說明 |
|-----------|---------|-------------|
| `http.route` | `/api/v1/projects/:projectUuid` | 路由模式 |
| `http.status_code` | `200` | 回應狀態碼 |
| `http.method` | `GET` | HTTP 方法 |
| `sentry.op` | `db`, `http.server` | 操作類型 |
| `db.system` | `postgresql` | 資料庫類型 |

## 常見除錯情境

| 症狀 | 檢查項目 |
|---------|---------------|
| 401 Unauthorized | 追蹤授權中介軟體，檢查 session/JWT span |
| 403 Forbidden | 檢查追蹤屬性中的使用者權限 (user ability/permissions) |
| 404 Not Found | 驗證路由是否存在，檢查資源查找 span |
| 400 Bad Request | 在追蹤/錯誤日誌中尋找驗證錯誤 |
| 回應緩慢 | 檢查 span 詳解，尋找緩慢的 db.* 或外部呼叫 |
| 空結果 | 驗證查詢參數，檢查資料庫查詢 span |
| 500 Server Error | 使用 `search_errors` 查看堆疊追蹤與背景資訊 |

## 快速指令參考

| 動作 | 指令 |
|--------|---------|
| 查看所有日誌 | `pnpm pm2:logs` |
| 查看 API 日誌 (非阻塞) | `pnpm exec pm2 logs lightdash-api --lines 20 --nostream` |
| 檢查程序狀態 | `pnpm pm2:status` |
| 重啟 API | `pnpm pm2:restart:api` |
| 最近追蹤 | `mcp__spotlight__search_traces {"timeWindow": 300}` |
| 追蹤詳細資訊 | `mcp__spotlight__get_traces "<8 字元前綴>"` |
| 最近錯誤 | `mcp__spotlight__search_errors {"timeWindow": 300}` |
| 瀏覽器快照 | `mcp__chrome-devtools__take_snapshot` |
| 開啟 Spotlight UI | http://localhost:8969 |

## 測試使用者憑證

用於測試需要驗證的流程：
- **電子郵件**：demo@lightdash.com
- **密碼**：demo_password!
