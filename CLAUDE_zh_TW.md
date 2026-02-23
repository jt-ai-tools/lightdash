# CLAUDE.md

本文件為 Claude Code (claude.ai/code) 在此儲存庫中工作時提供指導。

## 專案概述

Lightdash 是一個開源的商業智慧工具（Looker 的替代方案），它連接到 dbt 專案以實現自助式分析。這是一個使用現代 Web 技術構建的 TypeScript monorepo。

## 架構

**Monorepo 結構** (pnpm workspaces):

-   `packages/common/` - 共用的公用程式、類型和業務邏輯
-   `packages/backend/` - 帶有數據庫層的 Node.js/Express API 伺服器
-   `packages/frontend/` - 使用 Vite 構建系統的 React Web 應用程式
-   `packages/warehouses/` - 資料倉儲客戶端適配器（BigQuery, Snowflake, Postgres 等）
-   `packages/cli/` - 用於 dbt 專案管理的命令列介面
-   `packages/e2e/` - Cypress 端對端測試

**關鍵技術：**

-   後端：Express.js, Knex.js ORM, PostgreSQL, TSOA (OpenAPI 生成)
-   前端：React 19, Mantine v8 UI, Emotion 樣式, TanStack Query
-   構建：pnpm workspaces, TypeScript 專案引用, Vite

## 常用開發命令

-   假設開發伺服器 (dev-server) 始終在運行
-   始終使用套件特定的命令，以加快 linting/類型檢查/測試。

**代碼質量：**

```bash
pnpm -F common lint
pnpm -F backend lint
pnpm -F frontend lint
pnpm -F common typecheck
pnpm -F backend typecheck
pnpm -F frontend typecheck
```

**測試：**

```bash
pnpm -F common test
pnpm -F backend test:dev:nowatch # 僅運行修改過的文件測試
```

**API 生成：**

從 TSOA 控制器生成 OpenAPI 規範，在控制器更改時需要運行

```bash
pnpm generate-api
```

Chart-as-code JSON schema 是從後端 OpenAPI 生成的：

```bash
pnpm generate:chart-as-code-schema
pnpm check:chart-as-code-schema
```

**資料庫遷移 (Migrations)：**

```bash
# 建立新的遷移
pnpm -F backend create-migration migration_name_with_underscores

# 執行遷移
pnpm -F backend migrate

# 回滾最後一次遷移
pnpm -F backend rollback-last
```

## 開發工作流程

1. **套件管理**：使用 `pnpm` (v9.15.5+) - 絕不使用 npm 或 yarn
2. **TypeScript**：所有套件都使用 TypeScript，並帶有專案引用進行類型檢查
3. **Linting**：使用 Airbnb 配置的 ESLint，強制執行 `no-floating-promises`
4. **Pre-commit**：Husky + lint-staged 對暫存文件運行 linting/格式化
5. **資料庫**：使用 Knex.js 進行遷移和查詢構建
6. **API**：TSOA 從 TypeScript 控制器生成 OpenAPI 規範
7. **授權**：基於 CASL 的授權，具備多個身份驗證提供者

## 套件特定注意事項

**後端 (`packages/backend/`):**

-   使用基於 session 的身份驗證的 Express.js
-   資料庫遷移位於 `src/database/migrations/`
-   控制器使用 TSOA 裝飾器進行 API 生成
-   使用 node-cron 調度程序執行後台任務

**前端 (`packages/frontend/`):**

-   使用 Vite 進行快速開發和構建
-   帶有自定義主題的 Mantine v8 組件庫
-   使用 Monaco Editor 進行 SQL 編輯
-   使用 TanStack Query 進行伺服器狀態管理

**共用套件 (`packages/common/`):**

-   跨套件使用的共用類型和公用程式
-   使用 CASL 的授權邏輯
-   發布為 `@lightdash/common`

## TypeScript 專案引用 (Project References)

**重要**：SDK 構建更改後，套件使用 TypeScript 專案引用以獲得正確的 IDE 支援：

-   所有套件都啟用了 `"composite": true`
-   前端和後端透過 tsconfig.json 中的 `"references"` 引用 common 套件
-   Common 套件構建多個目標：ESM (`dist/esm`), CJS (`dist/cjs`), Types (`dist/types`)
-   從 common 導入的 Web workers 應使用構建後的 ESM 路徑：`@lightdash/common/dist/esm/[module]`

## 關鍵配置文件

-   `/tsconfig.json` - TypeScript 專案引用
-   `/pnpm-workspace.yaml` - Workspace 配置
-   `/.eslintrc.js` - 全局 linting 規則
-   `/package.json` - 根目錄腳本和依賴管理
-   `.env.development.local` - 本地開發環境變數

## 測試記憶

-   使用 Chrome DevTools MCP 與前端 Web 應用進行交互
-   測試用戶登入為 demo@lightdash.com 和 'demo_password!'
-   使用 `./scripts/reset-db.sh` 重置資料庫、執行遷移並使用開發數據填充資料庫

## 專案當前狀態

-   客戶支援問題處於 milestone 184

## Issue 管理

-   錯誤使用標籤 🐛 bug

## 代碼風格記憶

-   絕不使用鴨子類型 (duck typing)，不要使用可以具有不同類型的參數，讓類型具有意圖
-   **偏好嚴格的對象形狀**：從必要屬性開始，僅在真正需要時才將其設為選填
    -   ✅ 優：`{ charts: Chart[] }` - 可以是空數組
    -   ❌ 避：`{ charts?: Chart[] }` - 不清楚是缺失還是為空
-   **使用 null 表示缺失值**：當某個值可能不存在時，偏好顯式的 null 而非選填屬性
    -   ✅ 優：`{ createdBy: User | null }` - 顯式缺失
    -   ❌ 避：`{ createdBy?: User }` - 存在性模糊
-   **何時可以接受選填屬性**：
    -   向後兼容性要求
    -   省略具有語義含義的 API 設計模式
    -   具有合理默認值的配置對象
-   **始終將 `JSON.parse` 包裝在 try/catch 中**：解析錯誤會導致應用崩潰。失敗時，考慮顯示警告訊息或回退到合理的默認值。

## TypeScript 公用程式

-   **對窮舉式 switch 語句使用 `assertUnreachable`**：在 switch 語句中處理聯合類型時，在 default 情況下使用 `assertUnreachable` 以確保 TypeScript 捕捉到缺失的情況
    -   ✅ 優：`default: return assertUnreachable(value, 'Unknown status');`
    -   ❌ 避：`default: throw new Error('Unknown status');`
    -   從 `@lightdash/common` 導入：`import { assertUnreachable } from '@lightdash/common';`
    -   這在添加新的聯合類型成員時提供了編譯時安全性

## 安全最佳實踐

### 倉儲憑證保護

**關鍵**：在向倉儲配置添加新的憑證欄位時，請務必檢查它們是否包含不應透過 API 響應公開的敏感數據。

**位置**：`packages/common/src/types/projects.ts`

`sensitiveCredentialsFieldNames` 數組控制哪些欄位會從 API 響應中移除：

```typescript
export const sensitiveCredentialsFieldNames = [
    'user',
    'password',
    'keyfileContents',
    'personalAccessToken',
    'privateKey',
    'privateKeyPass',
    'sshTunnelPrivateKey',
    'sslcert',
    'sslkey',
    'sslrootcert',
    'token',
    'refreshToken',
    'oauthClientId',
    'oauthClientSecret',
    // 在此處添加任何新的敏感欄位！
] as const;
```

**當添加新的倉儲身份驗證方法時：**

1. **識別敏感欄位**：任何包含密碼、令牌、密鑰、秘密或可用於身份驗證的標識符的欄位
2. **添加到 sensitiveCredentialsFieldNames**：這確保欄位透過 `Omit<CreateXxxCredentials, SensitiveCredentialsFieldNames>` 被移除
3. **測試 API 響應**：驗證敏感數據不會出現在 GET /api/v1/projects/{uuid} 的響應中
4. **敏感欄位範例**：
    - OAuth client secrets (相當於密碼)
    - Refresh tokens (可用於獲取訪問令牌)
    - Access tokens (直接身份驗證)
    - 私鑰、證書
    - 資料庫密碼
    - 個人訪問令牌
5. **潛在敏感欄位範例**（根據判斷）：
    - OAuth client IDs (敏感度較低，但隱藏是最佳實踐)
    - 用戶名 (通常被視為 PII)

**運作方式**：

-   `CreateXxxCredentials` 類型包含所有欄位，包括敏感欄位（用於建立/更新）
-   `XxxCredentials` 類型是 `Omit<CreateXxxCredentials, SensitiveCredentialsFieldNames>`（用於 API 響應）
-   `ProjectModel.get()` 在返回給 API 控制器之前使用此數組過濾憑證
-   `ProjectModel.getWithSensitiveFields()` 僅供內部使用，返回未經過濾的數據

## 開發故障排除

-   如果執行 dbt 出現問題，請確保儲存庫根目錄有一個安裝了 dbt-core 和 dbt-postgres 的 python3 venv

## 檢查本地資料庫以進行偵錯

您可以使用 `psql` 直接連接到本地開發資料庫：

**範例：**

```bash
# 查看表格的 schema
psql -c "\d cached_explores"

# 查詢專案
psql -c "SELECT project_uuid, name FROM projects LIMIT 5;"
```

## 使用個人訪問令牌訪問 API

您可以使用 `curl` 調試本地 API 端點

**範例：**

```bash
# 列出專案中的所有空間
curl -H "Authorization: ApiKey $LDPAT" "$SITE_URL/api/v1/projects/PROJECT_UUID/spaces"

# 列出組織中的專案
curl -H "Authorization: ApiKey $LDPAT" "$SITE_URL/api/v1/org/projects"

# 僅獲取根級空間 (使用 v2 內容 API)
curl -H "Authorization: ApiKey $LDPAT" "$SITE_URL/api/v2/content?contentTypes=space&projectUuids=PROJECT_UUID&page=1&pageSize=25"
```
