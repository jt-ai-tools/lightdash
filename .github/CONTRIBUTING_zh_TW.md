# 為 Lightdash 做出貢獻

感謝您抽空參與貢獻 ❤️ 我們鼓勵並重視所有類型的貢獻！

## 目錄

-   [行為準則](#行為準則)
-   [如何尋求幫助](#如何尋求幫助)
-   參與貢獻：
    -   [報告錯誤](#如何報告錯誤)
    -   [請求功能](#如何請求新功能)
    -   [貢獻代碼](#如何為-lightdash-貢獻代碼)
-   [提交 Pull Request](#提交-pull-request)
-   [設定開發環境](#設定開發環境)
-   [加入 Lightdash 團隊](#加入-lightdash-團隊)

## 行為準則

本專案及所有參與者均受 [Lightdash 行為準則](CODE_OF_CONDUCT_zh_TW.md) 的約束。參與本專案即表示您被期望遵守此準則。請向 <support@lightdash.com> 舉報任何不當行為。

## 如何尋求幫助

回答您問題的實用資源：

-   [文檔](https://docs.lightdash.com)
-   [Issues](https://github.com/lightdash/lightdash/issues)

如果您找不到問題的答案，請加入我們的 [Slack 社群](https://join.slack.com/t/lightdash-community/shared_invite/zt-2wgtavou8-VRhwXI%7EQbjCAHQs0WBac3w) 並前往 `#help` 頻道。

## 如何報告錯誤

> 安全漏洞可以透過 GitHub 儲存庫的 Security 標籤提交，或發送電子郵件至 <security@lightdash.com>。

我們使用 GitHub Issues 來追蹤錯誤和異常。如果您在專案中遇到問題：

-   建立一個 [Issue](https://github.com/lightdash/lightdash/issues/new)。（由於目前無法確定這是否為錯誤，我們請您先不要將其稱為錯誤，也不要為 Issue 添加標籤。）
-   解釋您預期的行為以及實際發生的行為。
-   請提供儘可能多的上下文資訊，並描述其他人可以自行遵循以重現該問題的**重現步驟**。這通常包括您的代碼。對於優秀的錯誤報告，您應該隔離問題並建立一個精簡的測試案例。

## 如何請求新功能

增強建議作為 [GitHub Issues](https://github.com/lightdash/lightdash/issues) 進行追蹤。

-   為 Issue 使用一個**清晰且具描述性的標題**。
-   提供儘可能詳細的**建議增強功能的逐步說明**。
-   **描述當前行為**並**解釋您希望看到的行為**及其原因。在此處您也可以說明哪些替代方案對您無效。
-   您可以**包含螢幕截圖和動畫 GIF**，這有助於演示步驟或指出與建議相關的部分。
-   **解釋為什麼這項增強功能對大多數 Lightdash 用戶有用**。您也可以指出其他解決得更好的專案，這些專案可以作為靈感來源。

## 如何為 Lightdash 貢獻代碼

> ### 法律聲明
>
> 在為本專案做出貢獻時，您必須同意您擁有內容 100% 的著作權，您擁有該內容必要的權利，並且您貢獻的內容可以根據專案授權條款提供。

在為 Lightdash 貢獻代碼之前，您必須完成以下步驟：

1. **加入我們的 Slack 社群**：前往我們的 [Slack 社群](https://join.slack.com/t/lightdash-community/shared_invite/zt-2wgtavou8-VRhwXI%7EQbjCAHQs0WBac3w) 並在 `#community-contributors` 頻道介紹自己。
2. **挑選一個 Issue**：瀏覽現有的 [Issues](https://github.com/lightdash/lightdash/issues?q=state%3Aopen%20label%3A%22%F0%9F%91%8B%20open-contribution%22) 並選擇一個標有 `open-contribution` 標籤的任務。
3. **認領您的 Issue**：使用此範本在 `#community-contributors` Slack 頻道中發布訊息：

    ` Hi Lightdash team, I'd like to work on this open-contribution issue: [在此處貼上您的 issue 連結]`

4. **開始進行**：一旦您被指派了該 Issue，就可以開始您的貢獻。在修改代碼時，請確保閱讀我們的 `CLAUDE.md` 文件，以了解我們的編碼方式。
5. **提交 PR**：準備就緒後，為您的更改建立一個 Pull Request。這將觸發 GitHub Actions 來驗證您的更改。請等待其完整執行完畢，並確保修復 GitHub Actions 標註的任何問題。

> 重要提示：如果不遵循這些步驟，Pull Request 將不會被審核。

> 請多包涵：我們是一個小團隊，正盡最大努力快速審核貢獻，但審核您的 PR 可能需要一些時間 - 特別是當更改較大或與我們當前的開發週期不一致時。感謝您的耐心配合！

剛接觸開源嗎？查看這個免費系列：[如何在 GitHub 上為開源專案做出貢獻](https://egghead.io/courses/how-to-contribute-to-an-open-source-project-on-github)

## 提交 Pull Request

Lightdash 是一個社群專案，因此始終歡迎 Pull Requests。但在進行重大更改之前，最好先建立一個 Issue 進行討論並獲得維護者的同意（請參閱[此處](#如何為-lightdash-貢獻代碼)所需的貢獻步驟）。

如有疑問，請保持您的 Pull Requests 盡量精簡。為了讓 Pull Request 有最大的被接受機會，請不要在同一個 Pull Request 中捆綁超過一個功能或錯誤修復。建立兩個較小的 PR 通常比建立一個大的 PR 更好。

1. Fork 儲存庫。
2. 將 Fork 複製到您的本地機器並添加 upstream 遠端：

```sh
git clone https://github.com/<您的用戶名>/lightdash.git
cd lightdash
git remote add upstream https://github.com/lightdash/lightdash.git
```

3. 將本地 `main` 分支與上游分支同步：

```sh
git checkout main
git pull upstream main
```

4. 使用 pnpm 安裝依賴項（不支援 npm/yarn）：

```sh
pnpm install
```

5. 建立一個新的主題分支：

```sh
git checkout -b my-topic-branch
```

6. 進行更改、提交並推送至您的 Fork：

```sh
git push -u origin HEAD
```

7. 前往 [GitHub 儲存庫](https://github.com/lightdash/lightdash/pulls) 並提交一個 Pull Request。

核心團隊正在監控 Pull Requests。我們將審核您的 PR，並決定合併它、請求更改或關閉它並提供解釋。

#### 提交 (Commit) 與 Pull Request 命名規範

我們遵循 [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) 標準。

```
<類型>[可選範圍]: <描述>
```

例如：

```
feat: add table calculations
fix: remove infinite loop during login
docs: add page about metrics
style: add more space
```

請注意，**feat** 和 **fix** 通常用於為最終用戶提供價值的更改，因此它們會觸發發布（版本更新）。如果您正在對文檔、樣式或系統的其他部分進行更改，請使用適當的標籤以避免額外的開銷。

您可以在此處查看所有 [支援的類型](https://github.com/commitizen/conventional-commit-types/blob/v3.0.0/index.json)。

#### 合併策略

我們使用 `squash & merge`（壓縮並合併）以保持 main 分支歷史記錄整潔。

#### 樣式指南

我們的樣式指南應透過執行 prettier 和 eslint 的 pre-commit hook 來強制執行。審核者仍可針對以前未遇過的情況請求臨時更改。

## 設定開發環境

套件概覽：

-   [`frontend` - React 前端](../packages/frontend/README_zh_TW.md)
-   [`backend` - Node.js 後端](../packages/backend/README_zh_TW.md)
-   `common` - 所有其他套件之間的共用代碼
-   `cli` - 命令列介面
-   `e2e` - 端對端和整合測試
-   `warehouses` - 用於連接不同資料庫的類別

#### 使用 GitHub Codespaces / VS Code Remote Containers

設定開發環境最快的方法是使用 GitHub Codespaces 或 VS Code Remote Containers。這提供了：

-   所有依賴項
-   用於開發的 Postgres 資料庫
-   一個範例 dbt 專案
-   預先配置好的代碼編輯器

開始步驟：

-   在 GitHub 中[建立 codespace](https://docs.github.com/en/codespaces/developing-in-codespaces/creating-a-codespace)
-   在 VS Code 中[安裝 Remote Containers 擴充功能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

連接後，在 VS Code 終端機中執行以下命令：

```shell
# 設定資料庫
pnpm -F backend migrate
pnpm -F backend seed

# 在開發模式下執行 Lightdash 前端和後端
pnpm dev
```

#### 使用 Docker compose

或者，您可以使用 docker compose 建立開發環境：

```shell
# 複製 Lightdash 儲存庫
git clone https://github.com/lightdash/lightdash
```

將 `.env.development` 複製到一個名為 `.env.development.local` 的新文件中，並執行以下 `docker compose up` 命令：

```shell
# 建立 docker 容器
# 注意：在下一步之前，請確保您的 Docker 擁有 4GB 記憶體（Docker -> 設定 -> 資源），您應該可以在此處調整數值。

docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local up --detach --remove-orphans
```

準備就緒後，進入開發容器並執行以下命令：

```shell
# 連接到容器
docker exec -it lightdash-app-lightdash-dev-1 bash

# 跳過 playwright 下載
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true

# 安裝依賴項並構建 common 套件
./scripts/build.sh

# 設定 dbt
./scripts/seed-jaffle.sh

# 設定資料庫
./scripts/migrate.sh
./scripts/seed-lightdash.sh

# 在開發模式下執行 Lightdash 前端和後端
pnpm dev # http://localhost:3000

# 在開發模式下登入
# 當瀏覽至 http://localhost:3000 時，您將看到登入頁面，您可以使用我們的演示登入詳細資訊：

# 電子郵件地址：demo@lightdash.com
# 密碼：demo_password!

# 或者以生產模式執行
# pnpm build
# pnpm start # http://localhost:8080
```

注意事項：

-   如果您更改了 `/packages/common` 內的文件，應在執行 `pnpm dev` 之前執行 `pnpm common-build`
-   如果您更改了 `/packages/warehouses` 內的文件，應在執行 `pnpm dev` 之前執行 `pnpm warehouses-build`
-   如果您重新命名文件，容器可能無法識別更改。要解決此問題，請停止容器並重新啟動。
-   如果您需要更改任何環境變數，可以透過編輯 `.env.development.local` 並重新執行上述 `docker compose up` 命令來實現。
-   在 macOS 上，您可能需要向 `/etc/hosts` 文件添加一個項目，將 `minio` 映射到 `127.0.0.1`，以便能夠透過名稱訪問容器。

當您想停止時：

```shell
docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local stop
```

當您想啟動時：

```shell
docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local start
```

#### 在本地測試 SSH 隧道

要在本地開發環境中測試 Lightdash 的 SSH 隧道：

1. **前往專案連接高級設定**
    - 在 Lightdash UI 中，瀏覽至您的專案連接設定。
    - 展開高級設定並將 `Use SSH tunnel` 設置為 **true**。

2. **添加 SSH 隧道配置**
    - SSH 遠端主機：`ssh-server`
    - SSH 遠端埠：`2222`
    - SSH 用戶名：`sshuser`

3. **生成金鑰對**
    - 使用 UI 為隧道生成新的 SSH 金鑰對。

4. **複製公鑰**
    - 從 UI 複製生成的公鑰。
    - 打開您的 `.env.development.local` 文件並設置：
        ```
        DEV_SSH_PUBLIC_KEY="<在此處貼上您的公鑰>"
        ```

5. **重啟 Docker Compose**
    - 重新執行以下命令以套用新的 SSH 金鑰：
        ```sh
        docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local up --detach --remove-orphans
        ```

這將使用您的新公鑰更新 SSH 伺服器容器，讓您能夠從本地 Lightdash 實例測試 SSH 隧道連接。

#### 在本地測試 Prometheus 指標

開發環境包含用於監控 Lightdash 指標的 Prometheus。使用方法：

1. **啟動開發環境**並啟用 Prometheus：

    ```shell
    docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local up --detach --remove-orphans
    ```

2. **驗證 Prometheus 正在運行**：
    - Prometheus UI: http://localhost:9091
    - Lightdash 指標端點: http://localhost:9090/metrics

3. **配置 Prometheus 設定**（選填）：
    - 編輯 `.env.development.local` 進行自定義：
        ```
        LIGHTDASH_PROMETHEUS_ENABLED=true
        LIGHTDASH_PROMETHEUS_PORT=9090
        LIGHTDASH_PROMETHEUS_PATH=/metrics
        ```

4. **在 Prometheus 中查看指標**：
    - 瀏覽至 http://localhost:9091
    - 使用表達式瀏覽器查詢 Lightdash 指標
    - 範例查詢：`queue_size`, `nodejs_eventloop_utilization`

Prometheus 配置每 5 秒自動從後端服務抓取一次 Lightdash 指標。

#### 使用 Mailpit 在本地測試電子郵件

開發環境包含 Mailpit，用於在本地測試電子郵件功能而不發送真實郵件。使用方法：

1. **啟動開發環境**（默認包含 Mailpit）：

    ```shell
    docker compose -p lightdash-app -f docker/docker-compose.dev.yml --env-file .env.development.local up --detach --remove-orphans
    ```

2. **訪問 Mailpit Web UI**：
    - 瀏覽至 http://localhost:8025
    - 所有從 Lightdash 發送的電子郵件都將顯示在這裡
    - 您可以查看完整的電子郵件內容、標頭和 HTML 渲染效果

3. **電子郵件配置**（已在 `.env.development` 中預先配置）：
    - SMTP 主機：`mailpit` (Docker 主機名)
    - SMTP 埠：`1025`
    - 本地開發不需要身份驗證

4. **測試電子郵件功能**：
    - 排程電子郵件發送
    - 用戶邀請郵件
    - 透過郵件分享警報
    - 密碼重置郵件

#### 使用 Mailpit 在本地測試電子郵件（不用 Docker）

如果您在不使用 Docker 的情況下執行 Lightdash，可以直接安裝並執行 Mailpit：

1. **安裝 Mailpit**：

    **macOS (使用 Homebrew):**
    ```shell
    brew install mailpit
    ```

    **Linux/macOS (使用安裝腳本):**
    ```shell
    sudo bash < <(curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh)
    ```

2. **執行 Mailpit**：
    ```shell
    mailpit
    ```

3. **在您的 `.env.development.local` 中配置 Lightdash**：
    ```shell
    SMTP_HOST=localhost
    SMTP_PORT=1025
    SMTP_SECURE=false
    SMTP_ALLOW_INVALID_CERT=false
    SMTP_SENDER_EMAIL=lightdash@localhost.com
    SMTP_SENDER_NAME=Lightdash
    ```

4. **訪問 Mailpit Web UI**：
    - 瀏覽至 http://localhost:8025

#### 下載存儲在本地 Docker 容器 MinIO 中的文件

使用 docker compose 設置開發時，已經有一個 MinIO 容器被設定為相容於 S3 的存儲，用於保存從應用程式導出的任何文件（如圖像、結果 csv 等）。

由於 MinIO 內部的 Docker 端點無法被宿主機（`localhost`）直接訪問，因此需要將其添加到計算機的 `/etc/hosts` 配置中，否則會失敗並出現 `DNS_PROBE_FINISHED_NXDOMAIN` 錯誤。

1. 以管理員權限使用文字編輯器編輯 hosts 文件：
   `sudo nano /etc/hosts`
2. 在文件末尾添加以下行：
   `127.0.0.1    minio`
3. 儲存文件

#### 不使用 Docker 設定開發環境

要在不使用 Docker 的情況下設定開發環境，在執行 Lightdash 之前需要以下先決條件：

-   node >= v18.x (推薦使用 20)
-   python >= 3.3
-   pnpm
-   postgres >= 12
-   dbt 1.7.x 別名為 `dbt1.7`

例如，在 macOS 上您可以遵循以下說明：

```shell
# 1 安裝 Homebrew
# 2 安裝 nvm 和其他必要的依賴項
# 3 使用 NVM 安裝指定的 node 版本
# 4 安裝 postgres 和 pgvector
# 5 使用 pip 安裝 dbt
# 6 複製儲存庫並在您的 IDE 中打開
# 7 將 .env.development 複製到 .env.development.local
# 8 編輯環境變數以匹配您的設置
# 9 安裝套件 (pnpm install)
# 10 構建 / 遷移 / 填充種子數據
# 執行
pnpm load:env pnpm dev
```

#### 如何執行單元測試

```shell
pnpm install
pnpm common-build
pnpm warehouses-build
pnpm test
```

#### 如何執行端對端 (e2e) 測試

在執行 e2e 測試之前，請確保應用程式已在本地執行。

```shell
pnpm e2e-open # 互動模式
pnpm e2e-run  # CLI 模式
```

#### 如何檢查代碼質量

```shell
pnpm lint
pnpm format
```

#### 開發 API 端點

API 端點寫在控制器中，位於 `packages/backend/src/controllers`。註冊控制器後，您需要重新生成 `routes.ts`：

```shell
pnpm generate-api
```

### 在本地執行 Headless 瀏覽器

Headless 瀏覽器用於生成 Slack 展開或排程發送所使用的圖像。

如果您想調試這些功能，應該在 Docker 上本地執行 headless 瀏覽器。

*(後續 Mac/Linux Docker 指令略過翻譯，保持原樣)*

## 加入 Lightdash 團隊

如果您有興趣加入我們的團隊，請查看我們的 [職缺公告欄](https://www.notion.so/gethubble/Job-Board-a2c7d872794b45deb7b76ad68701d750)！
