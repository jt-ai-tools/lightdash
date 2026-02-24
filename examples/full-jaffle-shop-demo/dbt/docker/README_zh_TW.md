# 如何建立 Jaffle Shop 資料庫

此目錄包含在本地啟動資料庫所需的檔案，其中包含來自 jaffle shop 專案的所有資料。
這對於測試或僅是探索此 dbt 專案中的資料非常有用。

**運作方式**

Docker compose 用於將多個相關服務一起執行。在這種情況下，我們執行兩個服務：

1. `postgres`：這是我們的資料庫，我們可以連接它並使用 SQL 查詢資料。
2. `dbt`：這是一個執行 [dbt-core](https://github.com/dbt-labs/dbt-core) 的服務，它將此 jaffle-shop 專案轉換為 postgres 中的有用資料。


## 步驟 1. 獲取程式碼

- 不打算對 Jaffle Shop 示範中的資料模型進行任何更改？請看**選項 1**。
- 打算對 Jaffle Shop 示範中的資料模型進行一些更改？請看**選項 2**。

### 選項 1：
開啟您喜歡的終端機並複製此儲存庫：

```shell
git clone git@github.com:lightdash/jaffle_shop
cd jaffle_shop/docker
```

### 選項 2：
點擊 GitHub 畫面右上角的 `fork` 按鈕來 Fork Jaffle Shop 儲存庫。

開啟您喜歡的終端機並複製您的新儲存庫：

```shell
git clone git@github.com:your_profile_name/jaffle_shop # 將 your_profile_name 替換為正確的數值
cd jaffle_shop/docker
```


## 步驟 2. 安裝 Docker

您需要[安裝 Docker](https://docs.docker.com/get-docker/)。

## 步驟 3. 建立資料庫並填入 jaffle 資料

執行腳本：

```shell
./start.sh
```

這將啟動一個 postgres 資料庫，然後執行 dbt 以填入 Jaffle Shop 資料！

第一次執行此指令時，下載所需的 docker 映像檔可能需要較長時間。

## 步驟 4. 檢查是否成功

您可以手動連接到 postgres 資料庫以檢查其中是否包含資料：

```shell
./connect.sh
```

您現在將進入 postgres 主控台，嘗試以下 SQL 指令：

```sql
select * from jaffle.payments;
```

如果您沒有看到任何資料，表示某些地方出錯了。

**要退出**，請鍵入 `Ctrl-d` (同時按下 control 鍵和 `d` 鍵)。

## 步驟 5. 從其他工具 (例如 Lightdash!!) 連接

您可以使用以下資訊將任何工具連接到您的 postgres 資料庫：

```yaml
port: 5432
host: localhost ( 如果從另一個 docker 容器存取，則使用 'host.docker.internal' )
user: postgres
password: password
database: postgres
schema: jaffle
ssl: false ( 或 'disabled' )
```

## 步驟 6. 停止所有服務

筆記型電腦快沒電了？停止所有服務並停止浪費電力：

```shell
./stop.sh
```
