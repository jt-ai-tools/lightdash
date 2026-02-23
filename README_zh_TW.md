<h1 align="center">
        <a target="_blank" href="https://www.lightdash.com"><img align="center" style="width:100%;" src="https://assets.website-files.com/62a9ae93cf7542032ae55b9c/62c5c71252b090df3224c706_gh-cover%20(2).png"> </a>
</h1>

<p align="center">開源的 Looker 替代方案。</p>

<div align="center">
        <a target="_blank" href="https://www.loom.com/share/c0805a236a994de397ac5142fdfe4b7f"><img align="center" style="max-width:300px;" src="/static/screenshots/lightdash_preview_chart_animation.gif"> </a>
</div>
<br>
<p align="center">
    <a href="http://www.lightdash.com"><b>官方網站</b></a> •
    <a href="https://www.loom.com/share/c0805a236a994de397ac5142fdfe4b7f"><b>觀看演示</b></a> •
    <a href="http://docs.lightdash.com/"><b>文檔</b></a> •
    <a href="https://join.slack.com/t/lightdash-community/shared_invite/zt-2wgtavou8-VRhwXI%7EQbjCAHQs0WBac3w"><b>加入 Slack 社群</b></a>
</p>
<div align="center">
<img src="https://img.shields.io/github/license/lightdash/lightdash" />
</div>

<div align="center">

### 讓公司中的每個人都能使用數據回答自己的問題

連接您的 dbt 專案 --> 在 dbt 中添加指標 (metrics) --> 與團隊分享洞察

如果您喜歡這個專案，請給我們一個星 ⭐️ (我們每獲得一個 GitHub 星，就會[種一棵樹](#lightdash-森林) 🌱)。

歡迎加入我們的團隊，[我們正在招聘](https://lightdash.notion.site/Lightdash-Job-Board-a2c7d872794b45deb7b76ad68701d750)。

</div>

## 功能特性：

- [x] 🙏 為用戶提供熟悉的界面，使用預定義指標進行自助服務
- [x] 👩‍💻 在 dbt 專案中透過 yaml 定義維度 (dimensions) 和指標
- [x] 🤖 從您的 dbt 模型中自動建立維度
- [x] 📖 為用戶同步 dbt 的描述和元數據 (metadata)
- [x] 🔍 輕鬆訪問圖表的底層記錄，並具備數據下鑽 (drill-down) 能力
- [x] 🧮 表格計算 (Table calculations) 讓您可以即時深入挖掘數據
- [x] 🕵️‍♀️ 血緣關係 (Lineage) 讓您查看模型的上游和下游依賴關係
- [x] 📊 針對指標提供全面且直觀的數據視覺化函式庫
- [x] 👷‍♂️ 儲存圖表並建立儀表板，與團隊分享您的洞察
- [x] 💻 強大的開發者體驗，包括預覽 BI 環境以及透過 CI/CD 進行自動化內容驗證
- [x] 🔄 探索所有圖表的版本歷史記錄，並可隨時還原
- [x] 🚀 透過 URL 輕鬆分享您的工作，或透過 Slack 或電子郵件排程發送

少了什麼嗎？查看我們的[待處理問題 (open issues)](https://github.com/lightdash/lightdash/issues)
看看您尋找的功能是否已經存在。如果沒有，我們非常歡迎您[提交新問題提出請求](https://github.com/lightdash/lightdash/issues/new/choose) 😊

## 演示 (Demo)

試用我們的[演示應用程式](https://demo.lightdash.com)！

## 快速入門

### 使用 Lightdash Cloud

您可以透過[註冊 Lightdash Cloud 免費試用](https://app.lightdash.cloud/register)來避免自行託管和設定 Lightdash 的麻煩。更多價格細節請參閱[此處](https://www.lightdash.com/pricing)。

### 一鍵部署

在 [Render](https://render.com) 上免費一鍵部署 Lightdash。

<div>

<a href="https://render.com/deploy?repo=https://github.com/lightdash/lightdash-deploy-render">
  <img src="https://render.com/images/deploy-to-render-button.svg" alt="Deploy to Render">
</a>

</div>

### 本地執行

利用我們的安裝腳本輕鬆在本地執行 Lightdash。

```bash
git clone https://github.com/lightdash/lightdash
cd lightdash
./scripts/install.sh
```

### 部署到正式環境

按照我們的 [Kubernetes 指南](https://docs.lightdash.com/self-host/self-host-lightdash)使用我們的[社群 Helm Charts](https://github.com/lightdash/helm-charts) 將 Lightdash 部署到正式環境。


## 入門步驟

步驟 1 - ⚡️ [自行託管 Lightdash (選填)](https://docs.lightdash.com/self-host/self-host-lightdash)

步驟 2 - 🔌 [連接專案](https://docs.lightdash.com/get-started/setup-lightdash/connect-project)

步驟 3 - 👩‍💻 [建立您的第一個指標](https://docs.lightdash.com/get-started/setup-lightdash/intro-metrics-dimensions)

## 社群支援

📣 如果您想要了解更多資訊，請前往我們的 [Slack 社群](https://join.slack.com/t/lightdash-community/shared_invite/zt-2wgtavou8-VRhwXI%7EQbjCAHQs0WBac3w)，在那裡您可以直接與 Lightdash 團隊及其他優秀的社群成員交流。我們非常樂意討論任何問題，從功能請求、實作細節、dbt 的特殊用法到迷因和 SQL 笑話！

您也可以透過以下方式關注 Lightdash：

- [Twitter](https://twitter.com/lightdash_devs)
- [LinkedIn](https://www.linkedin.com/company/lightdash)

## 關於 Lightdash

### 🗂 **將所有業務邏輯集中在一個地方。**

我們讓您直接在 dbt 專案中定義指標和維度，將所有業務邏輯集中在一個地方，並增加分析的上下文資訊。

不再需要為「四個不同的總收入值中哪一個才是**正確**的」而苦惱 (之後再感謝我們吧 😉)。

### 🤝 **建立對數據的信任。**

我們希望公司裡的每個人都覺得他們可以信任數據。那麼，為什麼不**展示**給他們看呢？

我們將您想要的數據品質上下文資訊引入您的 BI 工具中，讓人們知道數據是可信的。

### 🧱 **為用戶提供有意義的組件，讓他們自行回答數據問題。**

有了 Lightdash，您可以將 SQL 留給專家。我們為您的數據團隊提供所需的工具，以建立每個人都可以使用的指標和維度。

因此，業務中的任何人都可以組合、細分和過濾這些指標和維度，以回答他們自己的問題。

### 📖 **開源，直到永遠**

**Lightdash 是與我們的社群一起為社群而建立的。**

我們認為 BI 工具應該是負擔得起、可配置且安全的，而開源讓我們能同時實現這三點 🙂

### 🤑 **負擔得起的分析工具**

喜歡 Looker，但不喜歡 Looker 的價格標籤？

有了 Lightdash，我們提供免費的自行託管服務（全部都是開源的！），或者如果您正在尋找輕鬆的分析設置，也有價格合理的雲端服務選項。

## 文檔 (Docs)

對功能有疑問嗎？或者想看點讀物？請前往我們的 [Lightdash 文檔](https://docs.lightdash.com/) 查看我們的教學、參考文件、常見問題等。

## 報告錯誤與功能請求

想報告錯誤或請求新功能嗎？請提交 [Issue](https://github.com/lightdash/lightdash/issues/new/choose)。

## Lightdash 森林

我們正在 Lightdash 社群的幫助下種樹。

植樹是緩解氣候變化最簡單且最具成本效益的方法之一，透過吸收大氣中的二氧化碳。所以我們覺得在 Lightdash 成長的同時發展出一片森林是非常棒的事情。

想幫助我們發展森林嗎？

只需給這個 Repo 一個星！我們在 GitHub 上獲得的每一顆星都會種下一棵樹。 ⭐️ ➡️ 🌱

我們與 TIST 合作植樹，您可以在這裡閱讀相關資訊：https://program.tist.org/。

## 本地開發與貢獻

我們歡迎任何大小的貢獻，請查看[我們的指南](.github/CONTRIBUTING_zh_TW.md#contributing-to-lightdash)了解如何開始。

查看在本地開發 Lightdash 的[說明](.github/CONTRIBUTING_zh_TW.md#setup-development-environment)。

## 貢獻者 ✨

感謝這些優秀的人們 ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

*(此處略過貢獻者名單翻譯，保持原樣)*

本專案遵循 [all-contributors](https://github.com/all-contributors/all-contributors) 規範。歡迎任何形式的貢獻！
