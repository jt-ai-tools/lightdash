# 實驗性 E2E 測試 (Experimental E2E Tests)

此資料夾包含實驗性的 E2E 測試，預設情況下**不包含在 CI 中**。

這些測試針對仍處於開發階段 (PoC 階段) 的功能，在功能穩定之前，預期會出現測試失敗的情況。

## 執行實驗性測試

### 開啟 Cypress UI (互動模式)

```bash
# 從儲存庫根目錄執行
pnpm -F e2e cypress:open:experimental

# 或從 packages/e2e 執行
pnpm cypress:open:experimental
```

### 以 headless 模式執行

```bash
# 從儲存庫根目錄執行
pnpm -F e2e cypress:run:experimental

# 或從 packages/e2e 執行
pnpm cypress:run:experimental
```

### 執行特定的實驗性測試檔案

```bash
pnpm -F e2e cypress run --spec 'cypress/e2e/experimental/nestedSpacePermissions.api.cy.ts'
```

## 目前的實驗性測試

### 巢狀空間權限 (Nested Space Permissions) (`nestedSpacePermissions.*.cy.ts`)

針對巢狀空間權限功能的測試，包括：

- 巢狀空間可以從父級繼承權限 (預設)。
- 巢狀空間可以中斷繼承並定義明確的權限。
- 權限在祖先鏈中是累加的。

**前置要求：**

- 必須啟用功能標記 `nested-spaces-permissions`。
- 開發伺服器正在執行且已載入種子資料。

**檔案：**

- `nestedSpacePermissions.api.cy.ts` - API 層級測試 (目前 15/16 通過)。
- `nestedSpacePermissions.ui.cy.ts` - UI 互動測試。
- `NESTED_SPACE_PERMISSIONS_E2E_STRATEGY.md` - 完整的測試策略文件。

**已知失敗的測試：**

- `should copy permissions when setting inheritParentPermissions=false` - 當中斷繼承時的權限複製邏輯可能尚未完全實作。請檢查 `SpaceService.updateSpace()` 的實作。

## 將測試移至 CI

當功能穩定且測試能持續通過時：

1. 將測試檔案從 `experimental/` 移至適當的資料夾 (`api/` 或 `app/`)。
2. 測試將自動包含在 CI 執行中。
3. 更新策略文件，或如果不再需要則將其移除。
