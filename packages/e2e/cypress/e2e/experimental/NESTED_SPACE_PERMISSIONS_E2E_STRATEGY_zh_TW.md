# 巢狀空間權限 E2E 測試策略 (Nested Space Permissions E2E Testing Strategy)

## 總覽

本文件概述了巢狀空間權限功能的全面 E2E 測試策略。此功能允許巢狀空間從其父級鏈繼承權限 (累加模型)，或透過切斷繼承關係來定義自己的明確權限。

## 待測試的關鍵功能需求

### 1. 權限繼承模型

- 巢狀空間預設繼承父級權限 (`inheritParentPermissions: true`)。
- 權限是**累加的** —— 子空間會聚合來自所有祖先的權限。
- 當一個使用者出現在繼承鏈中的多個空間時，以**最高角色為準 (highest role wins)**。
- 根空間：`inheritParentPermissions` 等同於 `!isPrivate` (公開空間繼承自專案，私有空間是獨立的)。

### 2. 中斷繼承

- 巢狀空間可以將 `inheritParentPermissions` 切換為 `false` (「非同步」狀態)。
- 當停用繼承時，**所有有效權限都會被複製**到該空間作為直接權限。
- 中斷後，僅套用直接權限 (不再繼承自父級)。

### 3. 新增權限 (累加)

- 即使在繼承狀態下，空間仍可以**新增額外權限** (與繼承的權限累加)。
- 這些直接權限與繼承的權限疊加。

### 4. UI/UX 需求

- 即使是無法存取的空間，導覽列 (Breadcrumbs) 仍應顯示其父級名稱。
- 每個導覽節點應指示 `hasAccess` 狀態。
- 刪除影響應顯示所有受影響的空間 (包括可見名稱但無法存取的空間)。
- 空間設定應清楚顯示有效權限。

### 5. 邊緣案例

- 級聯刪除具有無法存取子空間的父空間。
- 對巢狀空間中的內容 (圖表/儀表板) 進行權限檢查。
- 搜尋端點遵循巢狀權限。
- 在具有不同權限模型的空間之間移動內容。

---

## 測試資料結構

### 現有的種子資料 (SPACE_TREE_1, SPACE_TREE_2)

```
管理員擁有的 (SPACE_TREE_1):
├── Parent Space 1 (公開, 繼承自專案)
│   ├── Child Space 1.1
│   │   ├── Grandchild Space 1.1.1
│   │   └── Grandchild Space 1.1.2
│   ├── Child Space 1.2
│   │   ├── Grandchild Space 1.2.1
│   │   └── Grandchild Space 1.2.2
│   │       └── Great Grandchild Space 1.2.2.1
│   └── Child Space 1.3
│       └── Grandchild Space 1.3.1
│           └── Great Grandchild Space 1.3.1.1
│
├── Parent Space 2 (私有, 無額外存取權)
│   └── Child Space 2.1
│       └── Grandchild Space 2.1.1
│
├── Parent Space 3 (私有, 編輯者具有 EDITOR 存取權)
│   └── Child Space 3.1
│
└── Parent Space 5 (私有, 透過 SEED_GROUP_2 具有群組存取權)
    └── Child Space 5.1

編輯者擁有的 (SPACE_TREE_2):
└── Parent Space 4 (私有)
    └── Child Space 4.1
```

### 需要新增的測試資料

我們需要為繼承測試填入特定場景的種子資料：

```
繼承測試樹 (新):
├── Inherit Root (公開)
│   ├── Inherit Child (inherit=true)
│   │   └── Inherit Grandchild (inherit=true)
│   └── Unsynced Child (inherit=false, 為特定使用者設定明確的 VIEWER)
│       └── Restricted Grandchild (從 Unsynced Child 繼承 inherit=true)
│
└── Private Root (私有, 僅限管理員)
    ├── Additive Child (inherit=true, 為編輯者使用者新增 EDITOR)
    │   └── Deep Additive (inherit=true)
    └── Isolated Child (inherit=false, 僅特定使用者具有存取權)
```

---

## 測試類別

### 類別 1：API 測試 —— 權限繼承邏輯

**檔案：`packages/e2e/cypress/e2e/api/nestedSpacePermissions.cy.ts`**

#### 1.1 基本繼承行為

```typescript
describe('Nested Space Permission Inheritance', () => {
    describe('Default inheritance behavior', () => {
        it(
            'should create nested space with inheritParentPermissions=true by default',
        );
        it('should inherit permissions from public parent space');
        it(
            'should inherit permissions from private parent space with explicit access',
        );
        it('should aggregate permissions from entire ancestry chain');
    });

    describe('Highest role wins', () => {
        it(
            'should return highest role when user has different roles in chain (VIEWER + EDITOR = EDITOR)',
        );
        it('should return ADMIN when user has ADMIN anywhere in chain');
        it('should maintain direct access flag correctly');
    });

    describe('Breaking inheritance', () => {
        it(
            'should copy all effective permissions when setting inheritParentPermissions=false',
        );
        it('should only use direct permissions after breaking inheritance');
        it('should not inherit new permissions added to parent after breaking');
    });
});
```

#### 1.2 存取控制場景

```typescript
describe('Access Control with Inheritance', () => {
    describe('View access', () => {
        it('admin should see all spaces regardless of inheritance');
        it('editor should see public spaces and spaces with access in chain');
        it(
            'viewer should only see public spaces and spaces with explicit access',
        );
        it('user with access to parent should see inheriting child');
        it(
            'user with access to parent should NOT see unsynced child without direct access',
        );
    });

    describe('Manage access', () => {
        it('user with EDITOR role on parent can manage inheriting child');
        it('user with EDITOR role on parent cannot manage unsynced child');
        it(
            'user with direct ADMIN on child can manage regardless of parent access',
        );
    });

    describe('Content access', () => {
        it('user can view chart in space where they have inherited access');
        it('user cannot view chart in unsynced space without direct access');
        it('user can create dashboard in space with inherited EDITOR role');
    });
});
```

#### 1.3 新增權限 (累加模型)

```typescript
describe('Additive Permissions', () => {
    it('should allow adding user access to inheriting space');
    it('should combine inherited + direct permissions');
    it('should show hasDirectAccess=true for directly added user');
    it('should show hasDirectAccess=false for inherited user');
    it('should allow adding group access to inheriting space');
});
```

#### 1.4 邊緣案例

```typescript
describe('Edge Cases', () => {
    describe('Deep nesting', () => {
        it(
            'should correctly aggregate permissions through 4+ levels of nesting',
        );
        it('should respect inheritance break at any level in chain');
    });

    describe('Mixed inheritance states', () => {
        it(
            'inheriting child of unsynced parent inherits from unsynced parent only',
        );
        it('permissions stop at first inherit=false in ancestry chain');
    });

    describe('Permission changes propagation', () => {
        it(
            'adding permission to parent should immediately affect inheriting children',
        );
        it(
            'removing permission from parent should immediately affect inheriting children',
        );
        it('changes to parent should not affect unsynced children');
    });
});
```

---

### 類別 2：API 測試 —— 空間操作

**檔案：`packages/e2e/cypress/e2e/api/nestedSpaceOperations.cy.ts`**

#### 2.1 具有繼承關係的空間增刪查改 (CRUD)

```typescript
describe('Space CRUD with Inheritance', () => {
    describe('Create space', () => {
        it(
            'should create root space with inheritParentPermissions based on isPrivate',
        );
        it(
            'should create nested space with inheritParentPermissions=true by default',
        );
        it(
            'should create nested space with explicit inheritParentPermissions=false',
        );
        it('should validate parentSpaceUuid exists in same project');
    });

    describe('Update space', () => {
        it('should toggle inheritParentPermissions from true to false');
        it('should toggle inheritParentPermissions from false to true');
        it('should not allow changing isPrivate for nested spaces');
        it('should copy permissions when breaking inheritance');
    });

    describe('Delete space', () => {
        it('should cascade delete to nested spaces');
        it('should get delete impact showing all affected spaces');
        it(
            'should show restricted space names in delete impact even without access',
        );
    });
});
```

#### 2.2 移動操作

```typescript
describe('Move Space Operations', () => {
    it('should move space to different parent');
    it('should move space to root level');
    it('should recalculate effective permissions after move');
    it('should require appropriate permissions on both source and target');
});
```

#### 2.3 空間存取管理

```typescript
describe('Space Access Management', () => {
    describe('Add access', () => {
        it('should add user access to space');
        it('should add group access to space');
        it('should not duplicate existing access');
    });

    describe('Remove access', () => {
        it('should remove user access from space');
        it('should remove group access from space');
        it('should not remove inherited access (only direct)');
    });

    describe('Clear all access', () => {
        it('should clear all direct user and group access');
        it('should leave inherited permissions intact');
    });
});
```

---

### 類別 3：API 測試 —— 導覽連結 (Breadcrumbs) 與導覽

**檔案：`packages/e2e/cypress/e2e/api/nestedSpaceBreadcrumbs.cy.ts`**

```typescript
describe('Breadcrumb Access Information', () => {
    it('should include breadcrumbs with access info for each ancestor');
    it('should show hasAccess=true for accessible ancestors');
    it('should show hasAccess=false for inaccessible ancestors');
    it('should always show space names in breadcrumbs regardless of access');
    it('should compute breadcrumb access correctly with inheritance chain');
});
```

---

### 類別 4：API 測試 —— 搜尋與內容 API

**檔案：`packages/e2e/cypress/e2e/api/nestedSpaceSearch.cy.ts`**

```typescript
describe('Search with Nested Permissions', () => {
    describe('Space search', () => {
        it('should return spaces with inherited access in search results');
        it('should not return unsynced spaces without direct access');
        it('should return nested spaces matching search query');
    });

    describe('Content search', () => {
        it('should return charts/dashboards in spaces with inherited access');
        it('should not return content in spaces without access');
    });

    describe('Content API', () => {
        it('v2 content endpoint respects nested space permissions');
        it('charts list excludes content in inaccessible nested spaces');
        it('dashboards list excludes content in inaccessible nested spaces');
    });
});
```

---

### 類別 5：UI 測試 —— 空間設定與權限

**檔案：`packages/e2e/cypress/e2e/app/nestedSpacePermissions.cy.ts`**

```typescript
describe('Nested Space Permissions UI', () => {
    describe('Space settings panel', () => {
        it('should show inheritance toggle for nested spaces');
        it('should hide inheritance toggle for root spaces');
        it('should show effective permissions list');
        it('should distinguish inherited vs direct permissions in UI');
        it('should show confirmation when breaking inheritance');
    });

    describe('Adding permissions', () => {
        it('should allow adding user to inheriting space');
        it('should allow adding group to inheriting space');
        it('should show newly added permission as direct');
    });

    describe('Breaking inheritance', () => {
        it('should show warning about copying permissions');
        it('should update permissions list after breaking');
        it('should show all previously inherited as now direct');
    });
});
```

---

### 類別 6：UI 測試 —— 導覽與可見性

**檔案：`packages/e2e/cypress/e2e/app/nestedSpaceNavigation.cy.ts`**

```typescript
describe('Nested Space Navigation', () => {
    describe('Space browser', () => {
        it('should show nested spaces user has access to');
        it('should hide nested spaces user cannot access');
        it('should show parent spaces even when child is unsynced');
    });

    describe('Breadcrumb navigation', () => {
        it('should show all ancestor names in breadcrumbs');
        it('should indicate inaccessible ancestors visually');
        it('should allow clicking accessible ancestors');
        it('should disable click on inaccessible ancestors');
    });

    describe('Space tree in modals', () => {
        it('should show accessible nested spaces in save location picker');
        it('should show accessible nested spaces in move dialog');
        it('should hide inaccessible spaces in tree');
    });
});
```

---

### 類別 7：UI 測試 —— 刪除流程

**檔案：`packages/e2e/cypress/e2e/app/nestedSpaceDelete.cy.ts`**

```typescript
describe('Nested Space Delete Flow', () => {
    describe('Delete impact preview', () => {
        it('should show all affected child spaces in delete dialog');
        it('should show names of restricted child spaces');
        it('should show content counts for each affected space');
        it('should indicate which spaces user has access to');
    });

    describe('Cascade delete', () => {
        it('should delete parent and all children on confirm');
        it(
            'should work even when children have different inheritance settings',
        );
    });
});
```

---

### 類別 8：基於角色的存取測試

**檔案：`packages/e2e/cypress/e2e/api/nestedSpaceRoles.cy.ts`**

```typescript
describe('Role-Based Nested Space Access', () => {
    describe('Admin role', () => {
        it('can see all spaces regardless of inheritance');
        it('can manage all spaces');
        it('can toggle inheritance on any space');
        it('can delete parent with inaccessible children');
    });

    describe('Editor role', () => {
        it('can see public spaces and inherited access');
        it('can create nested spaces in accessible parents');
        it('can manage spaces with EDITOR+ role');
        it('cannot see private unsynced spaces without access');
    });

    describe('Viewer role', () => {
        it('can see public spaces and directly shared spaces');
        it('cannot create spaces');
        it('cannot modify space permissions');
        it('can view content in spaces with inherited access');
    });

    describe('Interactive Viewer role', () => {
        it('has same visibility as viewer for spaces');
        it('can manage spaces where they have EDITOR/ADMIN role');
    });
});
```

---

## 測試實作順序

### 階段 1：核心權限邏輯 (API 測試)

1. `nestedSpacePermissions.cy.ts` —— 基本繼承行為。
2. `nestedSpaceOperations.cy.ts` —— 增刪查改操作。

### 階段 2：存取控制 (API 測試)

3. `nestedSpaceRoles.cy.ts` —— 基於角色的存取。
4. `nestedSpaceSearch.cy.ts` —— 搜尋與內容 API。

### 階段 3：UI 流程

5. `nestedSpaceNavigation.cy.ts` —— 導覽與可見性。
6. `nestedSpacePermissions.cy.ts` (UI) —— 設定面板。
7. `nestedSpaceDelete.cy.ts` —— 刪除流程。

### 階段 4：邊緣案例

8. `nestedSpaceBreadcrumbs.cy.ts` —— 導覽連結存取資訊。
9. 現有檔案中的其他邊緣案例測試。

---

## 測試資料設定方法

### 選項 A：使用現有種子 + 動態建立

- 使用現有的 SPACE_TREE_1/2 進行基本測試。
- 在測試設定中動態建立額外空間。
- 測試結束後進行清理。

### 選項 B：新增種子資料

- 新增 `06_inheritance_test_spaces.ts` 種子檔案。
- 建立專門用於繼承測試的空間。
- 更可靠，但需要在測試環境進行遷移。

**建議**：先從選項 A 開始以保持靈活性，待功能穩定後再遷移至選項 B 以供持續整合 (CI) 使用。

---

## 需要的輔助函式

```typescript
// cypress/support/spaceUtils.ts

// 建立具有特定繼承設定的巢狀空間
function createNestedSpace(opts: {
    projectUuid: string;
    parentSpaceUuid: string;
    name: string;
    inheritParentPermissions?: boolean;
}): Chainable<Space>;

// 切換繼承並驗證權限複製
function toggleInheritance(
    spaceUuid: string,
    inherit: boolean,
): Chainable<Space>;

// 驗證有效權限是否符合預期
function verifyEffectivePermissions(
    spaceUuid: string,
    expected: Array<{ userUuid: string; role: SpaceRole; isDirect: boolean }>,
): Chainable<void>;

// 獲取具有完整權限詳情的空間
function getSpaceWithPermissions(spaceUuid: string): Chainable<Space>;

// 驗證使用者是否可以/不可以存取空間
function verifySpaceAccess(
    spaceUuid: string,
    userEmail: string,
    expectedAccess: boolean,
): Chainable<void>;
```

---

## 功能標記 (Feature Flag) 考量

`NestedSpacesPermissions` 功能標記控制繼承是否啟用。測試應：

1. 對所有巢狀權限測試**假設功能標記為開啟 (ON)**。
2. (可選) 測試功能標記關閉 (OFF) 時的向後相容性。
3. 在測試描述中記錄任何依賴標記的行為。

---

## 追蹤指標

1. 權限組合的測試覆蓋率。
2. 權限密集型測試的執行時間。
3. UI 權限測試的穩定性 (Flakiness rate)。

---

## 已知問題 / 待辦事項

1. [ ] 必須啟用功能標記測試才能通過。
2. [ ] 種子資料可能需要針對繼承場景進行更新。
3. [ ] 某些 UI 元素可能尚不存在 (權限切換開關)。
4. [ ] 深層巢狀的效能測試待定。
