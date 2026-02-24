# 翻譯進度清單 (Translation Progress Checklist)

目標：將所有 `.md` 檔案翻譯為繁體中文，並儲存為 `*_zh_TW.md`。

## 根目錄 (Root)
- [x] README.md -> README_zh_TW.md
- [x] CONTRIBUTING.md (in .github/) -> CONTRIBUTING_zh_TW.md
- [x] CODE_OF_CONDUCT.md (in .github/) -> CODE_OF_CONDUCT_zh_TW.md
- [x] SECURITY.md -> SECURITY_zh_TW.md
- [x] CHANGELOG.md -> CHANGELOG_zh_TW.md (摘要翻譯)
- [x] CLAUDE.md -> CLAUDE_zh_TW.md

## 指令與技巧 (.claude / skills)
- [x] .claude/commands/add-context-file.md -> add-context-file_zh_TW.md
- [x] .claude/commands/cs-bugs.md -> cs-bugs_zh_TW.md
- [x] .claude/commands/docker-dev.md -> docker-dev_zh_TW.md
- [x] .claude/skills/debug-local/SKILL.md -> SKILL_zh_TW.md
- [x] .claude/skills/frontend-style-guide/SKILL.md -> SKILL_zh_TW.md
- [x] .claude/skills/ld-permissions/SKILL.md -> SKILL_zh_TW.md
- [x] skills/developing-in-lightdash/SKILL.md -> SKILL_zh_TW.md
- [x] skills/developing-in-lightdash/
    - [x] resources/chart-types-reference.md
    - [x] resources/dimensions-reference.md
    - [x] resources/metrics-reference.md
    - [x] resources/dashboard-reference.md
    - [x] resources/tables-reference.md
    - [x] resources/joins-reference.md
    - [x] resources/dashboard-best-practices.md
    - [x] resources/gauge-chart-reference.md
    - [x] resources/funnel-chart-reference.md
    - [x] resources/pie-chart-reference.md
    - [x] resources/cli-reference.md
    - [x] resources/treemap-chart-reference.md
    - [x] resources/workflows-reference.md
    - [x] resources/big-number-chart-reference.md
    - [x] resources/custom-viz-reference.md
    - [x] resources/map-chart-reference.md
    - [x] resources/table-chart-reference.md
    - [x] resources/cartesian-chart-reference.md

## 套件相關 (Packages)
- [x] packages/backend/README.md -> README_zh_TW.md
- [x] packages/backend/INTEGRATION_TESTS.md -> INTEGRATION_TESTS_zh_TW.md
- [x] packages/backend/src/ee/database/seeds/readme.md -> readme_zh_TW.md
- [x] packages/backend/src/scheduler/README.md -> README_zh_TW.md
- [x] packages/frontend/README.md -> README_zh_TW.md
- [x] packages/frontend/public/geojson/README.md -> README_zh_TW.md
- [x] packages/cli/README.md -> README_zh_TW.md
- [x] packages/warehouses/README.md -> README_zh_TW.md
- [x] packages/e2e/SLUG_TESTING_GUIDE.md -> SLUG_TESTING_GUIDE_zh_TW.md
- [x] packages/e2e/cypress/e2e/api/README.md -> README_zh_TW.md
- [x] packages/e2e/cypress/e2e/experimental/README.md -> README_zh_TW.md
- [x] packages/e2e/cypress/e2e/experimental/NESTED_SPACE_PERMISSIONS_E2E_STRATEGY.md -> NESTED_SPACE_PERMISSIONS_E2E_STRATEGY_zh_TW.md
- [x] packages/iframe-test-app/README.md -> README_zh_TW.md
- [x] packages/sdk-test-app/README.md -> README_zh_TW.md
- [x] packages/sdk-next-test-app/README.md -> README_zh_TW.md

## 其他 (Examples & Docs)
- [x] examples/api/README.md -> README_zh_TW.md
- [x] examples/snowflake-template/README.md -> README_zh_TW.md
- [x] examples/full-jaffle-shop-demo/dbt/README.md -> README_zh_TW.md
- [x] examples/full-jaffle-shop-demo/dbt/docker/README.md -> README_zh_TW.md
- [x] examples/full-jaffle-shop-demo/dbt/models/overview.md -> overview_zh_TW.md
- [x] examples/full-jaffle-shop-demo/dbt/models/docs.md -> docs_zh_TW.md
- [x] .context/PERMISSIONS.md -> PERMISSIONS_zh_TW.md
- [x] .github/docs/Tracking.md -> Tracking_zh_TW.md
- [x] .github/PULL_REQUEST_TEMPLATE.md -> PULL_REQUEST_TEMPLATE_zh_TW.md
- [x] .github/docs/Tracking.md -> Tracking_zh_TW.md

---

## 執行細則
1. 翻譯完成後，需更新本文件。
2. 確保 `*_zh_TW.md` 中的所有內部 Markdown 連結皆指向對應的 `*_zh_TW.md` 版本。
3. 根目錄 `README.md` 需加入中文版入口。

## 當前進度
- 開始日期：2026-02-23
- 當前狀態：已完成所有核心文件、開發者資源文件、權限文件、套件 README、範例文件及 E2E 測試指南的翻譯。剩餘檔案主要為各子目錄下的 `CLAUDE.md` 指令文件。
- 完成率：約 53% (55/104 檔案)
