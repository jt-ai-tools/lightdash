# Lightdash SDK 測試應用程式 (Lightdash SDK Test App)

這是一個由 Vite 驅動的 React 應用程式，旨在測試並演示 Lightdash SDK 的功能。

## 前置要求

在執行測試應用程式之前，請確保您已從 Lightdash 儲存庫的根目錄安裝了所有依賴套件：

```bash
pnpm install
```

## 入門指南

### 1. 建置相依套件

`sdk-test-app` 依賴於 `@lightdash/sdk` 和 `@lightdash/common`。您應先建置這些相依套件。您可以使用根目錄的腳本：

```bash
pnpm sdk-build
```

### 2. 啟動開發伺服器

您可以使用 `pnpm` 工作區指令啟動 `sdk-test-app`：

```bash
pnpm -F @lightdash/sdk-test-app dev
```

或者，進入該套件目錄並直接執行：

```bash
cd packages/sdk-test-app
pnpm dev
```

預設情況下，應用程式將可在 `http://localhost:3002` 存取。

## 使用應用程式

當應用程式在瀏覽器中執行時：

1. 點擊右上方角落的 **Config** 按鈕。
2. 輸入 Lightdash **Embed URL** (嵌入 URL)。
   - 嵌入 URL 通常如下所示：`https://{{lightdash_instance}}/embed/{{dashboard_uuid}}#{{embed_token}}`
3. 點擊 **Set URL**。
4. 應用程式將自動從提供的 URL 中提取 `instanceUrl` 和 `token`，以渲染嵌入式組件。

## 可用的腳本

在 `packages/sdk-test-app` 目錄中，您可以執行：

- `pnpm dev`：啟動 Vite 開發伺服器 (等同於 `vite`)。
- `pnpm start`：執行 `vite serve`。
- `pnpm build`：建置用於生產環境的應用程式。
