# 後端整合測試 (Backend Integration Tests)

本指南說明如何執行 Lightdash 後端的整合測試。

## 前置要求

1. **環境變數**
   ```bash
   # 企業版功能所需
   LIGHTDASH_LICENSE_KEY=your-license-key
   
   # AI 代理測試所需
   OPENAI_API_KEY=your-openai-api-key
   
   # PostgreSQL 連接字串
   PGCONNECTIONURI=postgresql://user:password@localhost:5432/lightdash
   ```

2. **建置後端**
   整合測試需要已編譯的 JavaScript 檔案來執行遷移 (migrations) 和種子資料 (seeds)：
   ```bash
   pnpm -F backend build
   ```

3. **測試資料庫**
   測試設定會自動使用名為 `{您的資料庫}_test` 的資料庫。例如，如果您主要使用的資料庫是 `lightdash`，測試資料庫將會是 `lightdash_test`。
   
   請手動建立測試資料庫：
   ```bash
   createdb lightdash_test
   ```

## 執行整合測試

```bash
# 執行所有整合測試
pnpm -F backend test:integration

# 以開發模式執行 (watch mode)
pnpm -F backend test:integration:dev
```

## 編寫整合測試

整合測試應：
- 使用 `.integration.test.ts` 或 `.integration.spec.ts` 命名規範。
- 放置在 `src/ee/**` 目錄中。
- 使用 `setupIntegrationTest()` 輔助工具進行資料庫和應用程式設定。
- 執行完畢後自行清理 (設定程序會自動處理)。

## 疑難排解

1. **找不到資料庫錯誤**
   - 確保測試資料庫已建立：`createdb {您的資料庫}_test`

2. **遷移錯誤**
   - 確保您已建置後端：`pnpm -F backend build`
   - 檢查主資料庫中的遷移是否已是最新狀態。

3. **授權金鑰錯誤**
   - 確保環境變數中已設定 `LIGHTDASH_LICENSE_KEY`。

4. **OpenAI API 錯誤**
   - 如果未設定 `OPENAI_API_KEY`，需要 OpenAI 的測試將會跳過。
   - 設定有效的 API 金鑰以執行 AI 代理測試。
