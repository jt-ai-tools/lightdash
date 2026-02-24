# 基於 Slug 的測試指南 (Slug-Based Testing Guide)

本文件概述了 Lightdash 儀表板和圖表中基於 Slug 功能的全面測試覆蓋範圍。

## 總覽

Lightdash 支援使用 Slug (易於閱讀的識別碼) 而非 UUID 來存取儀表板和圖表。例如：
- **UUID**：`/projects/123/dashboards/abc-def-123-456`
- **Slug**：`/projects/123/dashboards/jaffle-dashboard`

為了向後相容，這兩種方式均受支援。

## 測試覆蓋範圍

### 1. 儀表板測試 (`cypress/e2e/app/dashboard.cy.ts`)

新增了 5 個新的測試案例：

#### a. 基本 Slug 存取
- **測試**：`Should access dashboard by slug instead of UUID`
- **覆蓋範圍**：驗證儀表板是否可以透過 Slug 存取並正確渲染。
- **關鍵斷言 (Assertions)**：儀表板已載入、圖塊已渲染、圖表已顯示。

#### b. 使用 Slug 時的篩選器持久性
- **測試**：`Should maintain dashboard filters when using slug`
- **覆蓋範圍**：確保在使用基於 Slug 的 URL 時，儀表板篩選器能正常運作。
- **關鍵斷言**：篩選器已套用、URL 包含 Slug + 篩選器、重新整理後仍保留狀態。

#### c. 透過 Slug 進行 API 存取
- **測試**：`Should access dashboard via API using slug`
- **覆蓋範圍**：測試帶有 Slug 參數的 REST API 端點。
- **關鍵斷言**：API 返回正確的儀表板，包含 Slug 和 UUID。

#### d. 錯誤處理
- **測試**：`Should handle invalid dashboard slug gracefully`
- **覆蓋範圍**：驗證針對不存在的 Slug 是否有正確的錯誤訊息。
- **關鍵斷言**：錯誤訊息顯示得當。

### 2. 圖表測試 (`cypress/e2e/app/chartSlugs.cy.ts`)

建立了一個包含 10 個全面測試案例的新測試檔案：

#### 基本功能
1. **Slug 存取**：透過 Slug URL 存取已儲存的圖表。
2. **圖表編輯**：編輯透過 Slug 存取的圖表。
3. **API 存取**：使用 Slug 透過 API 獲取圖表。
4. **錯誤處理**：優雅地處理無效的 Slug。

#### 進階功能
5. **URL 分享**：使用 Slug 分享圖表 URL。
6. **查詢執行**：使用基於 Slug 的存取方式執行圖表查詢。
7. **排程傳送**：為透過 Slug 存取的圖表建立排程。
8. **CSV 匯出**：在透過 Slug 存取時匯出圖表資料。
9. **儀表板整合**：將透過 Slug 存取的圖表加入儀表板。

### 3. API 測試 (`cypress/e2e/api/slugs.cy.ts`)

建立了一個全面的 API 測試套件，包含 16 個測試案例，分為 5 個部分：

#### 儀表板 API 測試
1. 透過 Slug 獲取儀表板。
2. 透過 UUID 獲取儀表板 (向後相容性)。
3. 處理不存在的 Slug (404 錯誤)。
4. 更新透過 Slug 存取的儀表板。
5. 使用 Slug 獲取儀表板視圖。

#### 圖表 API 測試
6. 透過 Slug 獲取圖表。
7. 透過 UUID 獲取圖表 (向後相容性)。
8. 處理不存在的 Slug (404 錯誤)。
9. 更新透過 Slug 存取的圖表。
10. 使用衍生自 Slug 的 UUID 獲取圖表歷史記錄。
11. 使用衍生自 Slug 的 UUID 獲取圖表篩選器。

#### 互換性測試
12. 驗證 Slug 和 UUID 返回相同的儀表板。
13. 驗證 Slug 和 UUID 返回相同的圖表。

#### 列表端點測試
14. 驗證儀表板列表中包含 Slug。
15. 驗證圖表摘要中包含 Slug。

### 4. 擴充後的儀表板 API 測試 (`cypress/e2e/api/dashboard.cy.ts`)

在現有的 API 測試套件中新增了 3 個測試案例：

1. **透過 Slug 獲取儀表板**：基本的 API 存取測試。
2. **建立並透過 Slug 存取**：完整的生命週期測試 (建立 → 透過 Slug 存取)。
3. **透過 Slug 更新**：使用 Slug 修改儀表板，並透過 UUID 驗證。

## 支援 Slug 的 API 端點

### 儀表板
- `GET /api/v1/dashboards/:dashboardUuidOrSlug`
- `PATCH /api/v1/dashboards/:dashboardUuidOrSlug`
- 返回：同時包含 `uuid` 和 `slug` 欄位的儀表板物件。

### 圖表
- `GET /api/v1/saved/:savedQueryUuidOrSlug`
- `PATCH /api/v1/saved/:savedQueryUuidOrSlug`
- 返回：同時包含 `uuid` 和 `slug` 欄位的圖表物件。

### SQL 圖表
- `GET /api/v1/projects/:projectUuid/sqlRunner/saved/slug/:slug`
- 專門用於基於 Slug 存取的獨立端點。

## 其他應加入測試的地方

### 1. 整合測試
**位置**：`packages/backend/src/services/DashboardService/DashboardService.test.ts`

建議的測試：
```typescript
describe('getByIdOrSlug', () => {
    it('should get dashboard by slug', async () => {
        // 測試服務層的 Slug 解析
    });
    
    it('should get dashboard by UUID', async () => {
        // 測試向後相容性
    });
});
```

### 2. 模型層測試
**位置**：`packages/backend/src/models/DashboardModel/DashboardModel.test.ts`

建議的測試：
```typescript
describe('DashboardModel.getByIdOrSlug', () => {
    it('should query by slug when slug provided', async () => {
        // 測試資料庫查詢邏輯
    });
});
```

### 3. 前端單元測試
**位置**：`packages/frontend/src/hooks/dashboard/useDashboard.test.ts`

建議的測試：
```typescript
describe('useDashboardQuery with slug', () => {
    it('should fetch dashboard using slug', async () => {
        // 測試 React hook 行為
    });
});
```

### 4. 搜尋功能
**位置**：`packages/e2e/cypress/e2e/api/search.cy.ts`

考慮加入：
- 搜尋結果應包含 Slug。
- 點擊搜尋結果應導覽至 Slug URL。

### 5. 嵌入 (Embedding) 測試
**位置**：`packages/e2e/cypress/e2e/app/embed.cy.ts` (如果有的話)

考慮加入：
- 可透過 Slug 存取嵌入式儀表板。
- 可透過 Slug 存取嵌入式圖表。

### 6. 排程器 (Scheduler) 測試
**位置**：`packages/backend/src/scheduler/SchedulerTask.test.ts`

考慮加入：
- 排程傳送可與基於 Slug 的引用配合使用。
- 排程器中的儀表板/圖表解析使用 Slug。

### 7. 以程式碼定義內容 (Content as Code) 測試
**位置**：`packages/e2e/cypress/e2e/api/contentAsCode.cy.ts`

已經有一些 Slug 測試！考慮擴展：
- 使用 Slug 上傳內容。
- 透過 Slug 下載特定項目。
- 在同步過程中保留 Slug。

### 8. 權限/存取控制測試
**位置**：`packages/backend/src/services/PermissionsService/PermissionsService.test.ts`

考慮加入：
- 權限檢查能與 Slug 正確配合運作。
- 私有儀表板的 Slug 存取被適當地拒絕。

### 9. 分析 (Analytics) 測試
**位置**：`packages/backend/src/analytics/`

考慮驗證：
- 對於基於 Slug 的存取，檢視事件能被正確追蹤。
- 分析能區分 UUID 和 Slug 存取模式。

### 10. 遷移測試
**位置**：`packages/backend/src/database/migrations/`

考慮加入：
- 為現有內容生成 Slug。
- Slug 的唯一性約束。
- 名稱變更時的 Slug 更新。

## 測試資料參考

### 種子儀表板
- **名稱**："Jaffle dashboard"
- **Slug**：`jaffle-dashboard`

### 種子圖表
- **名稱**："How much revenue do we have per payment method?"
- **Slug**：`how-much-revenue-do-we-have-per-payment-method`

- **名稱**："How many orders we have over time?"
- **Slug**：`how-many-orders-we-have-over-time`

- **名稱**："Which customers have not recently ordered an item?"
- **Slug**：`which-customers-have-not-recently-ordered-an-item`

## 執行測試

### 執行所有 Slug 相關測試
```bash
# 儀表板測試
pnpm test:e2e --spec "cypress/e2e/app/dashboard.cy.ts"

# 圖表 Slug 測試
pnpm test:e2e --spec "cypress/e2e/app/chartSlugs.cy.ts"

# API Slug 測試
pnpm test:e2e --spec "cypress/e2e/api/slugs.cy.ts"

# 擴充後的儀表板 API 測試
pnpm test:e2e --spec "cypress/e2e/api/dashboard.cy.ts"
```

### 執行所有 E2E 測試
```bash
pnpm test:e2e
```

## 關鍵實作細節

### 後端
1. **路由層 (Router Level)**：`dashboardRouter.ts` 和 `savedChartRouter.ts` 接受 `/:idOrSlug` 參數。
2. **服務層 (Service Level)**：`DashboardService.getByIdOrSlug()` 和 `SavedChartService.get()` 處理 Slug 解析。
3. **模型層 (Model Level)**：`DashboardModel.getByIdOrSlug()` 和 `SavedChartModel.get()` 透過 Slug 或 UUID 查詢。

### 前端
1. **URL 路由**：React Router 在路徑參數中同時接受 Slug 和 UUID。
2. **Hooks**：`useDashboardQuery()` 和 `useSavedQuery()` 可與兩種識別碼配合使用。
3. **API 呼叫**：`lightdashApi` 向後端發送 Slug 或 UUID。

## 最佳實踐

1. **務必同時測試 Slug 和 UUID** —— 確保向後相容性。
2. **測試錯誤案例** —— 無效的 Slug、不存在的資源。
3. **測試狀態持久性** —— 篩選器、參數、視圖狀態。
4. **測試 API 和 UI** —— 兩層都應支援 Slug。
5. **測試交叉引用** —— 儀表板中的圖表、儀表板圖塊等。

## 未來考量

1. **Slug 衝突** —— 如何處理重複的 Slug？
2. **Slug 變更** —— 當儀表板/圖表重新命名時會發生什麼？
3. **重新導向** —— 舊 Slug 是否應重新導向至新 Slug？
4. **分析 (Analytics)** —— 追蹤 Slug 使用量與 UUID 使用量的對比。
5. **效能** —— Slug 查找與 UUID 相比是否有任何效能影響？

## 貢獻

新增涉及儀表板或圖表的新功能時：
1. 確保包含對 Slug 的支援。
2. 在適當的測試檔案中加入對應的測試。
3. 如果出現新的測試模式，請更新此指南。
4. 同時考慮 API 和 UI 的測試覆蓋範圍。
