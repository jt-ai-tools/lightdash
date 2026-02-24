# 工作流程參考 (Workflows Reference)

常見 Lightdash 開發模式的詳細範例與 CI/CD 配置。

## 模式 1：直接部署 (Direct Deployment)

簡單且直接——將變更直接部署到您的專案。

```bash
# 在本地端修改 dbt/YAML 檔案
lightdash deploy --target prod
lightdash upload
```

**何時使用：**
- 獨立開發者或小型團隊。
- 單一環境。
- 無 CI/CD 流水線。
- 需要快速迭代。

## 模式 2：預覽優先開發 (Preview-First Development)

在套用到主專案之前，先在隔離環境中測試變更。

```bash
# 建立預覽環境
lightdash preview --name "feature-x"

# 在預覽環境中迭代變更
lightdash upload --force

# 準備就緒後：停止預覽，部署到主專案
lightdash stop-preview --name "feature-x"
lightdash config set-project --name "Production"
lightdash deploy --target prod
lightdash upload
```

**何時使用：**
- 多個團隊成員協作。
- 希望在推送前進行測試。
- 跨越多個模型/圖表的複雜變更。

## 模式 3：CI/CD 流水線 (CI/CD Pipeline)

合併至主分支時自動部署。

### GitHub Actions

```yaml
# .github/workflows/lightdash-deploy.yml
name: Deploy to Lightdash
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      LIGHTDASH_API_KEY: ${{ secrets.LIGHTDASH_API_KEY }}
      LIGHTDASH_URL: https://app.lightdash.cloud
      LIGHTDASH_PROJECT: ${{ secrets.PROJECT_UUID }}
      CI: true
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Lightdash CLI
        run: npm install -g @lightdash/cli

      - name: Setup Python (for dbt)
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dbt
        run: pip install dbt-core dbt-postgres  # 或您的適配器 (adapter)

      - name: Deploy to Lightdash
        run: |
          lightdash deploy --target prod
          lightdash upload --force
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - deploy

deploy-lightdash:
  stage: deploy
  image: node:20
  only:
    - main
  variables:
    LIGHTDASH_API_KEY: $LIGHTDASH_API_KEY
    LIGHTDASH_URL: https://app.lightdash.cloud
    LIGHTDASH_PROJECT: $PROJECT_UUID
    CI: "true"
  before_script:
    - npm install -g @lightdash/cli
    - pip install dbt-core dbt-postgres
  script:
    - lightdash deploy --target prod
    - lightdash upload --force
```

### CircleCI

```yaml
# .circleci/config.yml
version: 2.1

jobs:
  deploy:
    docker:
      - image: cimg/node:20.0
    environment:
      CI: "true"
    steps:
      - checkout
      - run:
          name: Install Lightdash CLI
          command: npm install -g @lightdash/cli
      - run:
          name: Install dbt
          command: pip install dbt-core dbt-postgres
      - run:
          name: Deploy to Lightdash
          command: |
            lightdash deploy --target prod
            lightdash upload --force

workflows:
  deploy-on-main:
    jobs:
      - deploy:
          filters:
            branches:
              only: main
```

**何時使用：**
- 團隊使用 Pull Requests。
- 想要自動化、可重複的部署。
- 需要部署的稽核軌跡。

## 模式 4：PR 預覽環境 (PR Preview Environments)

為每個 Pull Request 建立預覽，並自動清理。

### GitHub Actions - 建立預覽

```yaml
# .github/workflows/lightdash-preview.yml
name: Lightdash Preview
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  preview:
    runs-on: ubuntu-latest
    env:
      LIGHTDASH_API_KEY: ${{ secrets.LIGHTDASH_API_KEY }}
      LIGHTDASH_URL: https://app.lightdash.cloud
      CI: "true"
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Lightdash CLI
        run: npm install -g @lightdash/cli

      - name: Setup dbt
        run: pip install dbt-core dbt-postgres

      - name: Create Preview
        run: lightdash start-preview --name "pr-${{ github.event.number }}"

      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '🔍 Lightdash 預覽已建立：`pr-${{ github.event.number }}`'
            })
```

### GitHub Actions - 清理預覽

```yaml
# .github/workflows/lightdash-preview-cleanup.yml
name: Cleanup Lightdash Preview
on:
  pull_request:
    types: [closed]

jobs:
  cleanup:
    runs-on: ubuntu-latest
    env:
      LIGHTDASH_API_KEY: ${{ secrets.LIGHTDASH_API_KEY }}
      LIGHTDASH_URL: https://app.lightdash.cloud
      CI: "true"
    steps:
      - name: Install Lightdash CLI
        run: npm install -g @lightdash/cli

      - name: Stop Preview
        run: lightdash stop-preview --name "pr-${{ github.event.number }}"
```

**何時使用：**
- 希望在 PR 中獲得預覽連結。
- 多個審閱者需要查看變更。
- 複雜的審批工作流程。

## 模式 5：下載-編輯-上傳 (Download-Edit-Upload)

將現有在 UI 中建立的內容納入版本控制。

```bash
# 1. 列出可用專案並設定要下載的來源專案
lightdash config list-projects
lightdash config set-project --name "Production"

# 2. 下載內容
lightdash download --nested

# 3. 檢查下載內容
ls -la lightdash/

# 4. 根據需要編輯 YAML 檔案
# ... 進行修改 ...

# 5. 驗證變更
lightdash lint --path ./lightdash

# 6. 上傳變更
lightdash upload --force

# 7. 提交至 Git
git add lightdash/
git commit -m "以程式碼形式新增圖表與儀表板"
```

**下載後的目錄結構：**
```
lightdash/
├── charts/
│   ├── sales/
│   │   ├── monthly-revenue.yml
│   │   └── top-customers.yml
│   └── marketing/
│       └── campaign-performance.yml
└── dashboards/
    ├── sales/
    │   └── executive-summary.yml
    └── marketing/
        └── campaign-overview.yml
```

**何時使用：**
- 現有圖表/儀表板是在 UI 中建立的。
- 想要開始以程式碼管理內容。
- 需要進行批次編輯。
- 正在遷移到 GitOps 工作流程。

## 模式 6：多環境晉升 (Multi-Environment Promotion)

透過晉升工作流程分隔開發、預發布 (staging) 和生產專案。

### 手動晉升

```bash
# 列出可用的專案 (不含預覽專案)
lightdash config list-projects

# 開發環境 (Development)
lightdash config set-project --name "Dev"
lightdash deploy --target dev
lightdash upload

# 在開發環境測試...

# 晉升至預發布環境 (Staging)
lightdash config set-project --name "Staging"
lightdash deploy --target staging
lightdash upload

# 在預發布環境測試...

# 晉升至生產環境 (Production)
lightdash config set-project --name "Production"
lightdash deploy --target prod
lightdash upload
```

### CI/CD 多環境部署

```yaml
# .github/workflows/lightdash-multi-env.yml
name: Deploy to Lightdash

on:
  push:
    branches:
      - develop
      - staging
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      LIGHTDASH_API_KEY: ${{ secrets.LIGHTDASH_API_KEY }}
      LIGHTDASH_URL: https://app.lightdash.cloud
      CI: "true"
    steps:
      - uses: actions/checkout@v4

      - name: Install tools
        run: |
          npm install -g @lightdash/cli
          pip install dbt-core dbt-postgres

      - name: Deploy to Dev
        if: github.ref == 'refs/heads/develop'
        env:
          LIGHTDASH_PROJECT: ${{ secrets.DEV_PROJECT_UUID }}
        run: |
          lightdash deploy --target dev
          lightdash upload --force

      - name: Deploy to Staging
        if: github.ref == 'refs/heads/staging'
        env:
          LIGHTDASH_PROJECT: ${{ secrets.STAGING_PROJECT_UUID }}
        run: |
          lightdash deploy --target staging
          lightdash upload --force

      - name: Deploy to Production
        if: github.ref == 'refs/heads/main'
        env:
          LIGHTDASH_PROJECT: ${{ secrets.PROD_PROJECT_UUID }}
        run: |
          lightdash deploy --target prod
          lightdash upload --force
```

**何時使用：**
- 存在多個 Lightdash 專案。
- 每個環境有不同的 dbt 目標 (targets)。
- 正式晉升流程。
- 需要在生產環境前測試變更。

## 環境變數參考 (Environment Variables Reference)

| 變數 | 說明 |
|----------|-------------|
| `LIGHTDASH_API_KEY` | 用於身分驗證的 API 金鑰 |
| `LIGHTDASH_URL` | Lightdash 實例 URL |
| `LIGHTDASH_PROJECT` | 要部署的專案 UUID |
| `CI` | 設定為 `true` 以自動核准提示 |
| `DBT_PROJECT_DIR` | dbt 專案路徑 |
| `DBT_PROFILES_DIR` | dbt 設定檔 (profiles) 路徑 |

## 祕密資訊設定 (Secrets Setup)

### GitHub Actions

1. 前往存放庫 Settings > Secrets and variables > Actions。
2. 新增祕密 (secrets)：
   - `LIGHTDASH_API_KEY` - 來自 Lightdash 設定的 API 金鑰。
   - `PROJECT_UUID` - 來自 Lightdash URL 的專案 UUID。

### GitLab CI

1. 前往 Settings > CI/CD > Variables。
2. 新增變數 (需勾選 masked)：
   - `LIGHTDASH_API_KEY`
   - `PROJECT_UUID`

## 模式 7：圖表查詢驗證 (Chart Query Validation)

在部署前，驗證圖表查詢是否能成功對資料倉庫執行。

```bash
# 驗證單一圖表是否能執行
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml

# 驗證並檢查結果
lightdash run-chart -p ./lightdash/charts/monthly-revenue.yml -o /tmp/results.csv
```

**何時使用：**
- 修改圖表 YAML 檔案之後。
- 將圖表變更部署到生產環境之前。
- 在 CI 流水線中儘早發現毀損的查詢。

**注意：**

- 僅支援指標查詢圖表 (帶有 `tableName` + `metricQuery`)。SQL 圖表無法以這種方式執行。
- 指標查詢中引用的所有語義層欄位 (維度、指標、自定義維度等) 必須已經部署到 Lightdash 專案中。

## CI 中的驗證 (Validation in CI)

在部署前加入驗證步驟：

```yaml
- name: Lint Lightdash content
  run: lightdash lint --path ./lightdash --format json

- name: Validate against server
  run: lightdash validate --project ${{ secrets.PROJECT_UUID }}
```
