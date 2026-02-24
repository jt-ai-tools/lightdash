# Snowflake 專案範本 (Snowflake Project Template)

這是一個適用於 Snowflake 的 Lightdash 專案範本。

**前置作業**

1. [安裝 Lightdash CLI](https://docs.lightdash.com/guides/cli/how-to-install-the-lightdash-cli)
2. [登入 Lightdash](https://docs.lightdash.com/guides/cli/cli-authentication)
3. 準備好 Snowflake 的憑證

**建立您的第一個模型**

更新 `./lightdash/models/users.yml`
  - 將 `sql_from` 更新為您想在 Lightdash 中探索的資料表名稱。
  - 更新 `dimensions` (維度) 和 `metrics` (指標) 以定義您的語義層。
  
您可以執行以下 CLI 指令來檢查您的 YAML 檔案是否有任何錯誤：

```
lightdash lint
```
  
**建立您的第一個 Lightdash 專案**

使用 CLI 部署到 Lightdash：

```
lightdash deploy --create --no-warehouse-credentials
```

**更新您的 Lightdash 專案**
成功部署第一個專案後，您可以編輯 `.yml` 檔案並透過執行以下指令重新部署專案：

```
lightdash deploy --no-warehouse-credentials
```

**使用 AI 進行開發**

如果您使用 Cursor / Claude Code / Kilo Code (或任何其他 Copilot) 進行開發，建議進行以下設定：
- 提供 Lightdash `.yml` 格式的連結給您的 Copilot：https://raw.githubusercontent.com/lightdash/lightdash/refs/heads/main/packages/common/src/schemas/json/model-as-code-1.0.json
- 要求您的 Copilot 在做出任何更動後，務必執行 `lightdash lint`。
- 確保您的 Copilot 能夠存取您的資料倉庫架構 (warehouse schema)，這能極大地加快生成 YAML 檔案的速度。
