# Lightdash Iframe 測試應用程式 (Lightdash Iframe Test App)

這是一個用於測試嵌入式 Lightdash 儀表板並監控 postMessage 事件的 React 應用程式。此工具可協助開發人員驗證 iframe 嵌入功能，並對父應用程式與嵌入的 Lightdash 內容之間的事件通訊進行除錯。

## 功能

- **即時事件監控**：即時顯示來自嵌入式儀表板的 postMessage 事件。
- **事件篩選**：按類型 (filterChanged, tabChanged, error 等) 篩選事件。
- **安全性驗證**：檢查來源 (Origin) 以確保 postMessage 處理的安全。
- **事件歷史記錄**：包含時間戳記的所有接收事件的持久日誌。
- **環境文件**：內建 Lightdash 伺服器配置的設定說明。

## 快速入門

### 1. 安裝與執行

```bash
cd packages/iframe-test-app
pnpm install
pnpm dev
```

該應用程式將可在 `http://localhost:5173` 存取。

### 2. 配置 Lightdash 伺服器

在測試之前，請確保您的 Lightdash 伺服器已設定必要的環境變數。這些變數可以放在您的 `.env.development.local` 檔案中。

```bash
# 啟用 iframe 嵌入 (需要企業版授權)
EMBEDDING_ENABLED=true

# 啟用事件系統
EMBED_EVENT_SYSTEM_ENABLED=true

# 啟用 postMessage 事件
EMBED_EVENT_SYSTEM_POST_MESSAGE_ENABLED=true

# 配置允許的網域 (包含此測試應用程式的網域)
LIGHTDASH_IFRAME_EMBEDDING_DOMAINS=http://localhost:5173,https://your-app-domain.com

# 選填：速率限制配置
EMBED_EVENT_RATE_LIMIT_MAX_EVENTS=10
EMBED_EVENT_RATE_LIMIT_WINDOW_MS=1000
```

### 3. 在 Lightdash 中生成嵌入 URL

#### 方法 1：儀表板設定 (建議)

1. 在 Lightdash 中**開啟您的儀表板**。
2. 點擊右上方角落的 **"..." 選單**。
3. 從下拉選單中選擇 **"Embed" (嵌入)**。
4. **配置嵌入設定**：
   - 設定過期時間 (選填)。
   - 配置用於資料篩選的使用者屬性 (選填)。
5. **複製生成的嵌入 URL**。

### 4. 測試整合

1. 在測試應用程式中**輸入您的嵌入 URL** (例如：您在先前步驟中生成並複製的 URL)。
2. **設定目標來源 (target origin)** 以匹配您的應用程式 (在此案例中為 `http://localhost:5173`)。
3. 點擊 **"Load Iframe" (載入 Iframe)** 以嵌入儀表板。
4. 在嵌入的儀表板中**操作篩選器**。
5. 在事件監控 (Event Monitor) 面板中**監控事件**。

## 安全性考量

- **來源驗證**：應用程式會驗證 postMessage 事件是否來自預期的 Lightdash 伺服器來源。
- **目標來源**：務必指定正確的目標來源，以防止未經授權的訊息攔截。
- **網域白名單**：配置 `LIGHTDASH_IFRAME_EMBEDDING_DOMAINS` 以限制哪些網域可以嵌入您的內容。

## 疑難排解

### 未接收到事件

1. **檢查環境變數** —— 確保 `EMBED_EVENT_SYSTEM_ENABLED=true` 且 `EMBED_EVENT_SYSTEM_POST_MESSAGE_ENABLED=true`。
2. **驗證網域配置** —— 確保您的應用程式網域已包含在 `LIGHTDASH_IFRAME_EMBEDDING_DOMAINS` 中。
3. **檢查來源匹配** —— 確保目標來源與您的 Lightdash 伺服器來源完全一致。

### 嵌入 URL 無法載入

1. **驗證嵌入功能已啟用** —— 檢查您的 Lightdash 伺服器上是否設定了 `EMBEDDING_ENABLED=true`。
2. **檢查企業版授權** —— 對於私有部署執行個體，嵌入功能需要企業版授權。
3. **驗證 URL 格式** —— 確保嵌入 URL 遵循正確格式：`https://your-lightdash.com/embed/dashboard/{uuid}`。
4. **檢查網路存取** —— 確保您的測試應用程式可以連線到 Lightdash 伺服器。

### 事件未被篩選

1. **與儀表板互動** —— 事件僅由使用者互動觸發 (如更改篩選器、切換分頁)。
2. **檢查速率限制** —— 驗證您未超過配置的速率限制。
3. **瀏覽器開發者工具** —— 檢查瀏覽器控制台是否有任何 JavaScript 錯誤。

### 加入新的事件類型

若要監控額外的 Lightdash 事件：

1. 在 `SetupInstructions.tsx` 中更新事件類型文件。
2. 如果需要，在 `types.ts` 中加入類型定義。
3. 事件監控會自動偵測任何以 `lightdash:` 為前綴的事件。

## 資源

- [Lightdash 嵌入環境變數](https://docs.lightdash.com/self-host/customize-deployment/environment-variables#embedding)
- [如何嵌入 Lightdash 內容](https://docs.lightdash.com/guides/how-to-embed-content#how-to-embed-content)
- [Lightdash API 文件](https://docs.lightdash.com/references/api)
- [Lightdash 儀表板文件](https://docs.lightdash.com/get-started/exploring-data/dashboards)
