## Lightdash CLI

Lightdash 命令列介面工具

## 如何安裝

`npm i -g @lightdash/cli`

## 用法

```
用法: lightdash [選項] [指令]

選項:
  -h, --help      顯示指令說明

指令:
  version         輸出版本號
  [dbt_command]   執行 dbt 指令
  help [command]  顯示指令說明
```

例如：`lightdash test` 會執行 `dbt test`

## 開發

首先建置套件：

```shell
pnpm cli-build
```

然後使用 `node` 指向 `dist/index.js` 檔案來執行 CLI 指令。

### 來自 Lightdash 根目錄的範例

Lightdash 登入：

```
node ./packages/cli/dist/index.js login http://localhost:3000
```

Lightdash 編譯 (compile)：

```
node ./packages/cli/dist/index.js compile --project-dir ./examples/full-jaffle-shop-demo/dbt --profiles-dir ./examples/full-jaffle-shop-demo/profiles
```

Lightdash 生成 (generate)：

```
node ./packages/cli/dist/index.js generate --project-dir ./examples/full-jaffle-shop-demo/dbt --profiles-dir ./examples/full-jaffle-shop-demo/profiles
```

Lightdash 預覽 (preview)：

```
node ./packages/cli/dist/index.js preview --project-dir ./examples/full-jaffle-shop-demo/dbt --profiles-dir ./examples/full-jaffle-shop-demo/profiles
```

Lightdash 執行 (run)：

```
node ./packages/cli/dist/index.js dbt run --project-dir ./examples/full-jaffle-shop-demo/dbt --profiles-dir ./examples/full-jaffle-shop-demo/profiles -s
```

### 測試不同的 dbt 版本

如果您想測試不同的 dbt 版本，可以將套件中 "execa" 呼叫裡的字串 `dbt` 替換為 `dbt${您的版本}`，例如：`dbt1.8`。

## 自動化、CI 與代理 (Agentic) 用法

CLI 支援非互動式用法，適用於 CI/CD 流水線和代理式 LLM 編碼工具 (如 Claude Code, Cursor, Windsurf 等)。

`--non-interactive` 標記專為會被互動式提示阻斷執行的環境而設計，例如自動化流水線，或者當 AI 編碼代理代表您執行 CLI 指令時。

### 全域選項

| 標記 | 說明 |
|------|-------------|
| `--non-interactive` | 停用所有互動式提示。指令會盡可能自動選擇預設值。專為 CI/CD 和代理式編碼工具設計。 |

### 指令特定選項

| 指令 | 標記 | 說明 |
|---------|------|-------------|
| `login` | `--token <token>` | 使用個人存取權杖 (token) 進行驗證 (繞過 OAuth) |
| `login` | `--email <email>` | 使用電子郵件和密碼登入 |
| `login` | `--project <uuid>` | 登入後透過 UUID 選擇特定專案 |
| `deploy` | `-y, --assume-yes` | 對所有確認提示自動回答 "yes" |
| `generate` | `-y, --assume-yes` | 對提示自動回答 "yes" |
| `dbt run` | `-y, --assume-yes` | 對提示自動回答 "yes" |
| `rename` | `-y, --assume-yes` | 對提示自動回答 "yes" |

### 環境變數

| 變數 | 說明 |
|----------|-------------|
| `CI=true` | 等同於 `--non-interactive` |
| `LIGHTDASH_API_KEY` | 用於驗證的 API 權杖 (可用於代替 `--token`) |

### 自動化腳本範例

```bash
# 使用權杖登入 (在非互動模式下自動選擇第一個專案)
lightdash login https://app.lightdash.cloud 
  --token $LIGHTDASH_API_KEY 
  --non-interactive

# 使用權杖和特定專案登入
lightdash login https://app.lightdash.cloud 
  --token $LIGHTDASH_API_KEY 
  --project abc-123-uuid 
  --non-interactive

# 使用電子郵件/密碼登入
# 選項 1：使用環境變數 (建議使用 - 可避免出現在 shell 歷史記錄中)
export LIGHTDASH_CLI_EMAIL=demo@lightdash.com
export LIGHTDASH_CLI_PASSWORD='your_password'
lightdash login http://localhost:3000

# 選項 2：互動式密碼提示 (密碼不會出現在 shell 歷史記錄中)
lightdash login http://localhost:3000 --email demo@lightdash.com
# 系統將提示您安全地輸入密碼

# 以非互動方式部署至現有專案
lightdash deploy 
  --project-dir ./dbt 
  --profiles-dir ./profiles 
  --non-interactive

# 以非互動方式建立新專案
lightdash deploy 
  --create "我的新專案" 
  --assume-yes 
  --non-interactive 
  --project-dir ./dbt 
  --profiles-dir ./profiles
```

### 非互動模式下的行為

當設定了 `--non-interactive` (或 `CI=true`) 時：
- **專案選擇**：自動選擇第一個可用的專案。
- **確認提示**：除非提供了 `--assume-yes`，否則將失敗並顯示描述性錯誤。
- **OAuth 登入**：無法使用 —— 請改用 `--token` 或配合 `LIGHTDASH_CLI_PASSWORD` 環境變數使用 `--email`。

### 電子郵件/密碼登入

您可以透過 CLI 使用電子郵件/密碼驗證：

```bash
# 選項 1：環境變數 (建議)
export LIGHTDASH_CLI_EMAIL=demo@lightdash.com
export LIGHTDASH_CLI_PASSWORD='your_password'
lightdash login http://localhost:3000

# 選項 2：互動式密碼提示
lightdash login http://localhost:3000 --email demo@lightdash.com
# 系統將要求輸入密碼 (不會顯示在 shell 歷史記錄中)
```

**注意**：對於生產環境的 CI/CD 流水線，建議改用個人存取權杖與 `--token`。

### Claude Code / 代理工具：包含特殊字元的密碼

使用 Claude Code 或類似的代理式編碼工具時，包含特殊字元 (如 `!`) 的密碼即使正確，也可能會失敗並顯示 "Email and password not recognized"。

**原因**：字元 (如 `!`) 在 bash 中具有特殊含義 (歷史擴展)。即使使用單引號，某些 shell 仍會對其進行解讀，導致密碼在到達 CLI 之前就已毀損。

**解決方案**：使用 heredoc 將密碼寫入檔案，這會將內容視為完全的字面量 (literal)：

```bash
# 使用 heredoc 將密碼寫入檔案 (繞過所有 shell 轉義)
cat > /tmp/lightdash_pass.txt << 'EOF'
your_password_with_special_chars!
EOF

# 從檔案設定環境變數
export LIGHTDASH_CLI_EMAIL=demo@lightdash.com
export LIGHTDASH_CLI_PASSWORD=$(cat /tmp/lightdash_pass.txt)

# 使用環境變數登入
lightdash login http://localhost:3000 --non-interactive

# 清理檔案
rm /tmp/lightdash_pass.txt
```

**重要**：`<< 'EOF'` 語法 (EOF 帶有引號) 至關重要 —— 它能防止 shell 對內容進行任何解讀。

CLI 支援以下用於身分驗證的環境變數：

| 變數 | 說明 |
|----------|-------------|
| `LIGHTDASH_CLI_EMAIL` | 登入電子郵件 (可代替 `--email`) |
| `LIGHTDASH_CLI_PASSWORD` | 電子郵件登入密碼 (與 `--email` 配合使用) |
