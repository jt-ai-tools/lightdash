## 如何在 Lightdash 中使用此專案

### 安裝 Lightdash：
利用我們的安裝腳本輕鬆在本地執行 Lightdash。查看[文件頁面](https://docs.lightdash.com/get-started/setup-lightdash/install-lightdash#deploy-locally-with-our-installation-script)了解更多詳情。
```bash
git clone https://github.com/lightdash/lightdash
cd lightdash
./install.sh

# 當系統提示時，選擇 "fast" 設定 (選項 1)
```

### dbt 連接：

- 類型：github
- 個人存取權杖 (personal access token)：(遵循[文件說明](https://docs.lightdash.com/get-started/setup-lightdash/connect-project/#personal-access-token)獲取)
- 儲存庫：lightdash/jaffle_shop
- 分支：main
- 專案目錄路徑：/

### 資料倉庫連接：

首先遵循[這些說明](./docker/README_zh_TW.md)為此 jaffle shop 專案執行 postgres 資料庫。

- 類型：postgres
- 主機：host.docker.internal
- 使用者：postgres
- 密碼：password
- 資料庫：postgres
- 結構 (schema)：jaffle
- 埠號：5432
- SSL：停用 (disable)

## 測試 dbt 專案：`jaffle_shop`

`jaffle_shop` 是一家虛構的電子商務商店。此 dbt 專案將來自應用程式資料庫的原始資料轉換為可用於分析的客戶和訂單模型。

### 這個儲存庫是什麼？
這個儲存庫是：
- 一個自給自足的遊樂場 dbt 專案，可用於測試腳本並傳達一些核心 dbt 概念。

這個儲存庫**不是**：
- 教學課程 —— 請查看[入門教學](https://docs.getdbt.com/tutorial/setting-up)。特別是，此儲存庫包含一些反模式 (anti-patterns) 以使其自給自足，即使用種子資料 (seeds) 而非來源資料 (sources)。
- 最佳實踐的示範 —— 請查看 [dbt Learn Demo](https://github.com/fishtown-analytics/dbt-learn-demo-v2-archive) 儲存庫。我們希望保持此專案儘可能簡單。因此，我們選擇不實作：
    - 我們的標準檔案命名模式 (這在大型專案中更有意義，而非這個只有五個模型的專案)
    - Pull Request 流程
    - CI/CD 整合
- 示範如何將 dbt 用於高度複雜的專案，或示範進階功能 (如巨集、套件、掛鉤、操作) —— 我們在這裡只是想保持簡單！

### 這個儲存庫包含什麼？
此儲存庫包含 [種子資料 (seeds)](https://docs.getdbt.com/docs/building-a-dbt-project/seeds)，其中包括來自虛構應用程式的一些 (假) 原始資料。

原始資料由客戶 (customers)、訂單 (orders) 和付款 (payments) 組成，其實體關係圖 (ERD) 如下：

![Jaffle Shop ERD](/etc/jaffle_shop_erd.png)


### 執行此專案
要開始執行此專案：
1. 遵循[這些說明](https://docs.getdbt.com/docs/installation)安裝 dbt。

2. 複製此儲存庫。

3. 從命令列進入 `jaffle_shop` 目錄：
```bash
$ cd jaffle_shop
```

4. 遵循[這些說明](https://docs.getdbt.com/docs/configure-your-profile)設定名為 `jaffle_shop` 的設定檔 (profile) 以連接到資料倉庫。如果您可以存取資料倉庫，則可以使用那些憑證 —— 我們建議將您的 [目標結構 (target schema)](https://docs.getdbt.com/docs/configure-your-profile#section-populating-your-profile) 設定為新結構 (只要您有正確的權限，dbt 就會為您建立結構)。如果您無法存取現有的資料倉庫，也可以設定本地 postgres 資料庫並在設定檔中連接到它。

5. 從命令列確保您的設定檔已正確設定：
```bash
$ dbt debug
```

6. 載入帶有示範資料集的 CSV 檔案。這會將 CSV 實體化為目標結構中的資料表。請注意，典型的 dbt 專案**不需要此步驟**，因為 dbt 假設您的原始資料已經在資料倉庫中。
```bash
$ dbt seed
```

7. 執行模型：
```bash
$ dbt run
```

> **注意：** 如果此步驟失敗，可能意味著您需要對 models 資料夾中的 SQL 進行微調，以適應目標資料庫的 SQL 風格。如果您使用的是社群貢獻的適配器，請務必考慮這一點。

8. 測試模型的輸出：
```bash
$ dbt test
```

9. 為專案生成文件：
```bash
$ dbt docs generate
```

10. 查看專案文件：
```bash
$ dbt docs serve
```

### 什麼是 jaffle？
Jaffle 是一種邊緣壓實密封的烤三明治。Jaffle 於 1949 年在邦代 (Bondi) 發明，是澳洲的經典美食。密封的邊緣讓食客可以享用三明治內部的液體內餡，這些內餡在烹飪過程中溫度會接近地核。通常在夜晚外出後回家食用，最經典的內餡是罐裝義大利麵，而我個人最喜歡的是剩下的燉牛肉配融化的起司。

---
有關 dbt 的更多資訊：
- 閱讀 [dbt 簡介](https://docs.getdbt.com/docs/introduction)。
- 閱讀 [dbt 觀點](https://docs.getdbt.com/docs/about/viewpoint)。
- 加入 [dbt 社群](http://community.getdbt.com/)。
---
