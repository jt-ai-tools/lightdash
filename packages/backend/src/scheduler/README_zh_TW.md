# 排程器 (Scheduler)

## 排程器工作者 (Scheduler worker)

排程器工作者從隊列中取出工作，並執行 `SchedulerTask` 中的特定方法。

它還執行 CronJob，每日生成當天的所有工作。

所有任務都被封裝在 `tryOrTimeout` 方法中，該方法會在一段時間後「殺死 (kill)」Promise 並解鎖工作者。

## 排程器任務 (Scheduler tasks)

在排程器上執行的工作邏輯。我們有一些任務，例如：

### handleScheduledDelivery

這是所有排程傳送 (所有排程類型和目標) 的主要進入點。

一個排程傳送如果類型是 `image` 或 `csv`，則可以有多個目標 (slack/email)；但對於 `type==Gsheets`，我們僅執行一個子任務 (且它沒有目標，關於 Gsheets 的詳細資訊位於 `schedulerOptions` 中)。

對於 Gsheets，我們不獲取頁面資料 (即下載 slack 或 email「多個」目標所需的 CSV 或圖像)，對於 Gsheets，我們只需排程 Gsheets 任務 (並記錄日誌 + 分析) (見下文)。

這樣一來，一旦我們將這些任務加入排程器儀表板，我們應該會看到：

    對於 google 上傳：handle -> gsheetsUpload
    對於 slack/email：handle -> slackNotification + emailNotification

### sendEmailNotification / sendSlackNotification

獲取在 `handleScheduledDelivery` 中生成的頁面資料詳情，並使用 `slackClient/emailClient` 將資訊發送至 `channel/recipient` (頻道/收件者)。

### uploadGsheets

此任務不依賴於 `handleScheduledDelivery` 中的 `pageData`，相反地，此方法會執行 `runQuery` 以從資料倉庫獲取資料列 (rows)，並使用 `GoogleDriveClient` 直接上傳至 `gsheets`。

### downloadCsv

### compileProject (編譯專案)

### testAndCompileProject (測試並編譯專案)

### validateProject (驗證專案)
