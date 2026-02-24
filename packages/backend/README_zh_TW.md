# 後端 (Backend)

目錄：

## 入門指南

本套件不應直接執行。相反地，您應該遵循貢獻指引文件中[設定開發環境](../../.github/CONTRIBUTING_zh_TW.md#設定開發環境)章節的說明。

## 關鍵技術/函式庫

- [Node.js](https://nodejs.org/en/)
- [Express](https://expressjs.com/)
- [Knex](http://knexjs.org/)
- [PostgreSQL](https://www.postgresql.org/)

## 架構 (Architecture)

**概覽**

- ~~routers~~ (舊版)
- controllers (控制器)
- services (服務)
- models (模型)
- database (資料庫)
    - migrations (遷移)
    - seeds (種子資料)
    - entities (實體)
- clients (用戶端)
- projectAdapters (專案適配器)
- dbt

### ~~Routers~~

舊版資料夾。應重構為 controllers。

### Controllers (控制器)

控制器負責處理來自 API 的請求與回應。它們應盡可能保持精簡，將業務邏輯委派給 services。

當對控制器或控制器中使用的類型進行更改時，您還應該生成相應的 HOA 檔案。您可以透過執行 `pnpm generate-api` 來完成。

準則：

- 每個端點應呼叫 1 個 service 動作。
- 使用 HOA 定義來定義參數 (params) 和主體 (body) 類型。

限制：

- 僅能導入 services。

### Services (服務)

服務負責處理業務邏輯和追蹤。它們往往是後端最龐大且最複雜的部分。

準則：

- 為所有公開方法加入追蹤 (tracking)。
- 為所有公開方法加入權限檢查。

限制：

- 不能導入 controllers 和其他 services。
- 可以導入 models, clients 和 projectAdapters。

### Models (模型)

模型負責處理資料庫邏輯。它們應盡可能保持精簡。

準則：

- 如果沒有結果，`get` 方法應該報錯。
- 如果沒有結果，`find` 方法**不應**報錯。
- `create` 和 `update` 方法應返回所建立實體的 UUID。
- 應僅使用來自其他模型的靜態方法。

限制：

- 僅能導入 entities 並使用其他 models。

### Database (資料庫)

#### Entities (實體)

實體負責定義最新資料庫結構的類型。

#### Migrations (遷移)

遷移負責處理資料庫結構的變更。

準則：

- 除了 `up` 和 `down` 方法外，不應匯出常數或函式。

限制：

- 不能導入任何內容。

實用的開發腳本：

- 遷移資料庫 - `pnpm -F backend migrate`
- 回滾資料庫 - `pnpm -F backend rollback`
- 回滾最後一次遷移 - `pnpm -F backend rollback-last`
- 建立新的遷移檔案 - `pnpm -F backend create-migration <migration-name>`

#### Seeds (種子資料)

種子資料負責在資料庫中填入初始資料。這些資料用於開發和測試目的。

### Clients (用戶端)

用戶端負責處理與外部服務的通訊。

限制：

- 不能導入任何內容。

### Project adapters (專案適配器)

專案適配器負責處理與外部服務的通訊，旨在獲取 dbt 專案檔案。

限制：

- 不能導入任何內容。

### dbt

dbt 負責處理與 dbt 的通訊。

限制：

- 不能導入任何內容。

## 實用腳本

### 資料庫遷移與回滾工具 (Database Migration and Rollback Tool)

**檔案：** `packages/backend/src/migrateOrRollbackDatabase.ts`

此腳本提供自動化的資料庫遷移和回滾功能，在回滾過程中遇到遺失的遷移檔案時特別有用。

#### ⚠️ 重要免責聲明

**關鍵警告**：此腳本會修改您的資料庫，並可能導致不可逆的資料遺失。

- 在進行任何資料庫操作之前，**務必建立完整的資料庫備份**。
- 先在開發環境中測試流程。
- **我們不對因使用此腳本而可能發生的任何問題、資料損壞或資料遺失負責**。
- 使用此工具需自擔風險和責任。
- 確保您擁有修改資料庫所需的權限和授權。

#### 用法

**開發環境：**

```bash
pnpm -F backend migrate-or-rollback-database:dev
```

**生產環境：**

```bash
pnpm -F backend migrate-or-rollback-database
```

#### 功能說明

1. **檢查遷移狀態**：分析當前資料庫遷移狀態。
2. **處理遺失檔案**：如果需要，從 GitHub 下載遺失的遷移檔案。
3. **執行操作**：根據要求執行向前遷移或回滾。
4. **清理**：移除下載的臨時檔案。

### 使用者密碼覆寫工具 (User Password Override Tool)

**檔案：** `packages/backend/src/overrideUserPassword.ts`

此腳本允許管理員直接透過命令列重設使用者的密碼。

#### ⚠️ 重要免責聲明

**安全性警告**：此腳本會修改使用者驗證資料。

- 在修改使用者資料之前，**務必確保已備份資料庫**。
- 僅將此工具用於合法的管理目的。
- 執行前請核對目標使用者的電子郵件。
- **我們不對可能發生的任何安全性問題或資料遺失負責**。
- 使用此工具需自擔風險和責任。

#### 用法

**開發環境：**

```bash
cd packages/backend
npx tsx src/overrideUserPassword.ts <user-email> <new-password>
```

**生產環境：**

```bash
cd packages/backend
node dist/overrideUserPassword.js <user-email> <new-password>
```

#### 參數

- `<user-email>`：要更改密碼的使用者電子郵件地址。
- `<new-password>`：要為該使用者設定的新密碼。

#### 範例

```bash
npx tsx src/overrideUserPassword.ts user@example.com newSecurePassword123
```
