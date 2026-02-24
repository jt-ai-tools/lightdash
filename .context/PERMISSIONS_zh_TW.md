# 權限系統 (Permissions System)

本文件涵蓋了 Lightdash 的權限運作方式，包括自定義角色、範圍 (scopes)、CASL 能力 (abilities) 以及整個應用程式中的權限執行。

## 架構概覽

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           權限流程 (PERMISSION FLOW)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. 定義 (DEFINITION)               2. 儲存 (STORAGE)                        │
│  ┌─────────────────────┐           ┌─────────────────────┐                  │
│  │ scopes.ts           │           │ 資料庫              │                  │
│  │ - 70 多個範圍        │           │ - roles 資料表      │                  │
│  │ - getConditions()   │           │ - scoped_roles      │                  │
│  │ - 分組/修飾符        │           │ - memberships       │                  │
│  └─────────────────────┘           └─────────────────────┘                  │
│           │                                 │                                │
│           ▼                                 ▼                                │
│  3. 能力建構 (ABILITY BUILDING - 執行階段)                                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │ getUserAbilityBuilder()                                               │   │
│  │ ├─ 系統角色？ → projectMemberAbility[role](member, builder)          │   │
│  │ └─ 自定義角色？ → buildAbilityFromScopes(scopes, context, builder)   │   │
│  │                     └─ 對於每個範圍：                                 │   │
│  │                        ├─ 解析："manage:Dashboard@space"             │   │
│  │                        ├─ 獲取條件：scope.getConditions(ctx)          │   │
│  │                        └─ builder.can('manage', 'Dashboard', conds)   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│           │                                                                  │
│           ▼                                                                  │
│  4. 執行 (ENFORCEMENT)                                                       │
│  ┌─────────────────────┐           ┌─────────────────────┐                  │
│  │ 後端 (Backend)       │           │ 前端 (Frontend)      │                  │
│  │ user.ability.cannot │           │ user.ability.can    │                  │
│  │ → ForbiddenError    │           │ → 條件式 UI          │                  │
│  └─────────────────────┘           └─────────────────────┘                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**關鍵技術：**
- **CASL** - 適用於 JavaScript 的同構授權函式庫。
- **自定義角色 (Custom Roles)** - 用於精細權限控制的企業級功能。

---

## 核心概念

### 範圍 (Scopes)

範圍是 Lightdash 中最基本的權限單位。每個範圍定義了可以對哪些資源執行哪些動作。

**格式：** `動作:主體` (action:Subject) 或 `動作:主體@修飾符` (action:Subject@modifier)

**範例：**
- `view:Dashboard` - 檢視儀表板。
- `manage:Dashboard@space` - 在使用者具有編輯者/管理員權限的空間中編輯儀表板。
- `manage:ScheduledDeliveries@self` - 管理使用者自己的排程傳送。

**範圍分組 (Scope Groups)** (定義於 `packages/common/src/types/scopes.ts`)：

| 分組 | 用途 |
|-------|---------|
| `CONTENT` | 儀表板、圖表、空間、評論、標籤 |
| `PROJECT_MANAGEMENT` | 專案設定、排程傳送、工作 (jobs) |
| `ORGANIZATION_MANAGEMENT` | 組織設定、成員、群組、邀請連結 |
| `DATA` | SQL 執行器、探索 (explore)、底層資料、匯出 |
| `SHARING` | 匯出為 CSV/圖像/PDF |
| `AI` | AI 代理功能 (企業版) |
| `SPOTLIGHT` | 指標樹、Spotlight 配置 (企業版) |

**修飾符 (Modifiers)：**

| 修飾符 | 意義 | 範例 |
|----------|---------|---------|
| `@self` | 使用者自己的資源 | `manage:ScheduledDeliveries@self` |
| `@public` | 公開/非私有資源 | `manage:Space@public` |
| `@assigned` | 使用者被分配到的資源 (管理員) | `manage:Space@assigned` |
| `@space` | 使用者具有編輯者以上角色的空間中的資源 | `manage:Dashboard@space` |
| `@preview` | 僅限預覽專案 | `create:Project@preview` |

### CASL 能力 (Abilities)

CASL 是底層的授權函式庫。Lightdash 從範圍中建構 CASL 能力 (定義於 `packages/common/src/authorization/types.ts`)。

**AbilityAction 類型**：
- `create` - 建立新資源。
- `delete` - 刪除資源。
- `export` - 匯出資料。
- `manage` - 完整的增刪查改 (CRUD) + 特殊操作。
- `promote` - 將內容晉升到空間。
- `update` - 更新現有資源。
- `view` - 唯讀存取。

**CaslSubjectNames** (約 35 種主體類型)：
```
AiAgent, AiAgentThread, Analytics, ChangeCsvResults, CompileProject,
ContentAsCode, CustomSql, Dashboard, DashboardComments, DashboardCsv,
DashboardImage, DashboardPdf, Explore, ExportCsv, GoogleSheets, Group,
InviteLink, Job, JobStatus, MetricsTree, Organization,
OrganizationMemberProfile, OrganizationWarehouseCredentials,
PersonalAccessToken, PinnedItems, Project, SavedChart, ScheduledDeliveries,
SemanticViewer, SourceCode, Space, SpotlightTableConfig, SqlRunner, Tags,
UnderlyingData, Validation, VirtualView
```

### 系統角色 vs 自定義角色

**系統角色 (System Roles)** - 具有預定義權限的內建角色。這些角色是標準化的，開箱即用。

| 角色 | 繼承自 | 關鍵新增功能 |
|------|---------------|---------------|
| `viewer` (檢視者) | - | 檢視公開內容，匯出 CSV |
| `interactive_viewer` (互動式檢視者) | viewer | 探索資料、排程傳送、空間級別編輯 |
| `editor` (編輯者) | interactive_viewer | 建立空間、管理公開空間、標籤 |
| `developer` (開發者) | editor | SQL 執行器、驗證、編譯、預覽專案 |
| `admin` (管理員) | developer | 完整的專案管理、所有內容存取權限 |

**自定義角色 (Custom Roles)** (企業版) - 由管理員定義並明確分配範圍的角色：
- 無繼承關係 - 範圍是明確分配的。
- 儲存在資料庫中 (`roles` + `scoped_roles` 資料表)。
- 可以混合搭配任何範圍。

---

## 範圍如何轉換為 CASL 權限

### `getConditions()` 函式

每個範圍定義了一個 `getConditions()` 函式，根據上下文 (context) 返回 CASL 條件：

```typescript
// packages/common/src/authorization/scopes.ts

{
    name: 'manage:Dashboard@space',
    description: '在您具有編輯者或管理員權限的空間中編輯儀表板',
    isEnterprise: false,
    group: ScopeGroup.CONTENT,
    getConditions: (context) => [
        // 返回 CASL 的條件 - 使用者在空間中必須具有編輯者或管理員角色
        addAccessCondition(context, SpaceMemberRole.EDITOR),
        addAccessCondition(context, SpaceMemberRole.ADMIN),
    ],
}
```

### 範圍上下文 (Scope Context)

`ScopeContext` 為條件評估提供執行階段資訊：

```typescript
// packages/common/src/types/scopes.ts

type ScopeContext = {
    userUuid: string;
    scopes: Set<ScopeName>;
    isEnterprise: boolean;
    organizationRole?: string;
    permissionsConfig?: {
        pat: { enabled: boolean; allowedOrgRoles: string[] };
    };
} & (
    | { organizationUuid: string; projectUuid?: never }
    | { projectUuid: string; organizationUuid?: never }
);
```

### 條件建構器 (Condition Builders)

**`addUuidCondition`** - 將專案/組織 UUID 加入條件中：
```typescript
const addUuidCondition = (context, modifiers) => ({
    ...(context.organizationUuid
        ? { organizationUuid: context.organizationUuid }
        : { projectUuid: context.projectUuid }),
    ...modifiers,
});
```

**`addAccessCondition`** - 加入空間存取要求：
```typescript
const addAccessCondition = (context, role) => ({
    ...addUuidCondition(context),
    access: {
        $elemMatch: {
            userUuid: context.userUuid || false,
            ...(role ? { role } : {}),
        },
    },
});
```

---

## 權限建構器 (Permission Builders)

### 關鍵檔案

| 建構器 | 位置 | 用途 |
|---------|----------|---------|
| `getUserAbilityBuilder` | `packages/common/src/authorization/index.ts` | 主要入口 - 建構使用者的完整能力 |
| `buildAbilityFromScopes` | `packages/common/src/authorization/scopeAbilityBuilder.ts` | 將範圍轉換為 CASL 規則 |
| `projectMemberAbilities` | `packages/common/src/authorization/projectMemberAbility.ts` | 專案的系統角色 → CASL |
| `applyOrganizationMemberAbilities` | `packages/common/src/authorization/organizationMemberAbility.ts` | 組織角色 → CASL |
| `PROJECT_ROLE_TO_SCOPES_MAP` | `packages/common/src/authorization/roleToScopeMapping.ts` | 將系統角色映射到範圍陣列 |

### `getUserAbilityBuilder` 流程

```typescript
// packages/common/src/authorization/index.ts

export const getUserAbilityBuilder = ({
    user,
    projectProfiles,
    permissionsConfig,
    customRoleScopes,
    customRolesEnabled,
    isEnterprise,
}) => {
    const builder = new AbilityBuilder<MemberAbility>(Ability);

    // 1. 套用組織級別的能力
    applyOrganizationMemberAbilities({
        role: user.role,
        member: { organizationUuid, userUuid },
        builder,
        permissionsConfig,
    });

    // 2. 為每個專案套用專案級別的能力
    projectProfiles.forEach((profile) => {
        if (profile.roleUuid && customRolesEnabled) {
            // 自定義角色 → 使用範圍
            buildAbilityFromScopes({
                projectUuid: profile.projectUuid,
                userUuid: user.userUuid,
                scopes: customRoleScopes[profile.roleUuid],
                isEnterprise,
            }, builder);
        } else {
            // 系統角色 → 使用預定義能力
            projectMemberAbilities[profile.role](profile, builder);
        }
    });

    return builder;
};
```

---

## 權限在應用程式中如何運作

### 後端執行

權限在服務層 (service layer) 使用 `user.ability.cannot()` 進行檢查：

```typescript
// packages/backend/src/services/PinningService/PinningService.ts:113

if (user.ability.cannot('manage', subject('PinnedItems', project))) {
    throw new ForbiddenError('您沒有釘選項目的權限');
}
```

**常見模式：**
```typescript
import { subject } from '@casl/ability';
import { ForbiddenError } from '@lightdash/common';

// 檢查權限
if (user.ability.cannot('action', subject('Subject', { projectUuid, ...conditions }))) {
    throw new ForbiddenError('自定義錯誤訊息');
}
```

**錯誤類型：**
- `ForbiddenError` (403) - 使用者已驗證但缺乏權限。
- `AuthorizationError` (401) - 使用者未驗證。

### 前端執行

前端使用 `user.ability.can()` 進行條件式渲染：

```typescript
// packages/frontend/src/pages/Settings.tsx

// 透過 useUser hook 獲取 user 物件
const { user } = useUser();

// 條件式渲染
{user?.ability.can('manage', 'PersonalAccessToken') && (
    <MenuItem>個人存取權杖 (Personal Access Tokens)</MenuItem>
)}

// 條件式邏輯
if (user?.ability.can('manage', 'Organization')) {
    // 顯示管理員選項
}
```

**AbilityContext** (雖然可用，但 `user.ability` 更常用)：
```typescript
// packages/frontend/src/providers/Ability/context.ts
import { AbilityContext } from './context';
const ability = useContext(AbilityContext);
```

### PAT (個人存取權杖) 權限

PAT 權限根據組織配置進行動態調整：

```typescript
// packages/common/src/authorization/scopeAbilityBuilder.ts

const handlePatConfigApplication = (context, builder) => {
    const { pat } = context?.permissionsConfig || {};

    // 如果使用者的組織角色啟用了 PAT，則加入 PAT 權限
    if (pat?.enabled && pat?.allowedOrgRoles?.includes(context.organizationRole)) {
        builder.can('manage', 'PersonalAccessToken');
    }
};
```

### 嵌入式 (JWT) 權限

嵌入式儀表板為匿名使用者使用受限的、基於權杖的權限。

---

## 如何新增範圍/權限

### 第 1 步：定義範圍

加入至 `packages/common/src/authorization/scopes.ts`：

```typescript
{
    name: 'manage:NewFeature',  // 格式：動作:主體 或 動作:主體@修飾符
    description: '在自定義角色 UI 中顯示的說明',
    isEnterprise: false,  // 企業版專屬功能請設為 true
    group: ScopeGroup.PROJECT_MANAGEMENT,  // 選擇適當的分組
    getConditions: (context) => [
        addUuidCondition(context),  // 使用輔助工具或自定義條件
    ],
},
```

### 第 2 步：新增 CASL 主體 (如果是新的主體類型)

如果您的範圍使用了新的主體，請加入至 `packages/common/src/authorization/types.ts`：

```typescript
export type CaslSubjectNames =
    | 'AiAgent'
    | 'Dashboard'
    | 'NewFeature'  // 依字母順序加入此處
    | // ...
```

### 第 3 步：加入系統角色映射

加入至 `packages/common/src/authorization/roleToScopeMapping.ts`。這使得該範圍可以透過系統角色獲得：

```typescript
const BASE_ROLE_SCOPES = {
    [ProjectMemberRole.DEVELOPER]: [
        // ... 現有範圍
        'manage:NewFeature',  // 加入到適當的角色
    ],
};
```

### 第 4 步：更新系統角色能力建構器

加入至 `packages/common/src/authorization/projectMemberAbility.ts`：

```typescript
developer(member, { can }) {
    projectMemberAbilities.editor(member, { can });
    // ... 現有能力
    can('manage', 'NewFeature', {
        projectUuid: member.projectUuid,
    });
},
```

如果是組織級別，也要更新 `packages/common/src/authorization/organizationMemberAbility.ts`。

### 第 5 步：在服務層中執行

在您的服務中加入權限檢查：

```typescript
// packages/backend/src/services/NewFeatureService.ts

import { subject } from '@casl/ability';
import { ForbiddenError } from '@lightdash/common';

async updateFeature(user: SessionUser, projectUuid: string, data: UpdateData) {
    if (user.ability.cannot('manage', subject('NewFeature', { projectUuid }))) {
        throw new ForbiddenError('您沒有管理此功能的權限');
    }
    // ... 實作內容
}
```

### 第 6 步：加入前端檢查

加入 UI 權限檢查：

```typescript
// 在 React 元件中
const { user } = useUser();

if (user?.ability.can('manage', 'NewFeature')) {
    return <NewFeatureButton />;
}
return null;
```

### 第 7 步：測試權限

1. 對範圍條件進行**單元測試**。
2. 對服務執行進行**整合測試**。
3. 使用不同角色對完整流程進行 **E2E 測試**。

---

## 向後相容性

修改權限時，請考慮對現有客戶的影響，尤其是可能無法接收自動更新的私有部署 (self-hosted) 版本。

### 指導原則

1. **新範圍必須加入到系統角色中** - 使用系統角色 (viewer, editor, admin 等) 的客戶應該能自動獲得新功能的存取權限，無需手動配置。

2. **不要破壞現有的權限檢查** - 更改現有範圍控制的內容可能會破壞自定義角色。私有部署客戶無法自動更新其自定義角色配置。

3. **新行為是否可以使用現有範圍？** - 在建立新範圍之前，請先問：現有範圍是否已經涵蓋了此動作？重複使用範圍可以降低複雜性。

4. **對現有行為變更使用棄用模式 (deprecation patterns)** - 永遠不要在不通知的情況下更改權限控制的內容。

### 更改現有行為

如果您需要更改權限控制的內容：

**第 1 步：保持舊行為正常運作**
```typescript
// 保持舊範圍運作
{
    name: 'manage:Dashboard',
    // ... 仍然控制它一直以來控制的內容
}
```

**第 2 步：為新行為加入新範圍**
```typescript
// 加入具有明確名稱的新範圍
{
    name: 'manage:DashboardAdvanced',
    description: '進階儀表板功能 (v2)',
    // ...
}
```

**第 3 步：加入系統角色**
```typescript
// 確保系統角色使用者獲得新能力
[ProjectMemberRole.EDITOR]: [
    'manage:Dashboard',        // 保留現有的
    'manage:DashboardAdvanced', // 加入新的
],
```

**第 4 步：記錄棄用資訊**
```typescript
// scopes.ts - 在說明中加入棄用通知
{
    name: 'manage:Dashboard',
    description: '[已棄用：請針對 X 使用 manage:DashboardAdvanced] 管理儀表板',
    // ...
}
```

### 自定義角色注意事項

自定義角色儲存在資料庫中，帶有明確的範圍名稱。當您執行以下操作時：

| 變更 | 對自定義角色的影響 |
|--------|------------------------|
| 新增範圍 | 無影響 - 可供分配 |
| 重新命名範圍 | **破壞性變更** - 自定義角色會失去權限 |
| 移除範圍 | **破壞性變更** - 自定義角色會失去權限 |
| 更改範圍行為 | **隱性破壞性變更** - 自定義角色會受影響 |

**針對私有部署客戶：**
- 資料庫遷移可以將新範圍加入系統角色。
- 無法自動更新自定義角色的 `scoped_roles` 項目。
- 必須提供清晰的升級文件。

### 棄用檢查清單

棄用某個範圍時：

- [ ] 建立具備新行為的替代範圍。
- [ ] 將替代範圍加入到適當的系統角色中。
- [ ] 更新舊範圍的說明，加入棄用通知。
- [ ] 在發佈說明 (release notes) 中加入遷移指南。
- [ ] 規劃移除時間表 (建議保留 2 個以上的大版本)。
- [ ] 當檢查已棄用的範圍時，加入主控台 (console) 警告。

---

## 資料庫綱要 (Database Schema)

### `roles` 資料表

```sql
CREATE TABLE roles (
    role_uuid UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    organization_uuid UUID REFERENCES organizations(organization_uuid),
    owner_type VARCHAR(50) NOT NULL CHECK (owner_type IN ('user', 'system')),
    created_by UUID REFERENCES users(user_uuid),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (organization_uuid, name)
);
```

### `scoped_roles` 資料表

```sql
CREATE TABLE scoped_roles (
    role_uuid UUID NOT NULL REFERENCES roles(role_uuid) ON DELETE CASCADE,
    scope_name VARCHAR(255) NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(user_uuid),
    PRIMARY KEY (role_uuid, scope_name)
);
```

### 角色分配

角色透過成員關係資料表進行分配：
- `project_memberships.role_uuid`
- `organization_memberships.role_uuid`
- `project_group_access.role_uuid`

---

## 關鍵檔案參考

### Common 套件 (`packages/common/src/`)

| 檔案 | 用途 |
|------|---------|
| `authorization/scopes.ts` | 所有 70 多個範圍的定義 |
| `authorization/types.ts` | CASL 動作/主體類型 |
| `authorization/index.ts` | `getUserAbilityBuilder` 入口點 |
| `authorization/scopeAbilityBuilder.ts` | 範圍 → CASL 轉換 |
| `authorization/projectMemberAbility.ts` | 專案系統角色能力 |
| `authorization/organizationMemberAbility.ts` | 組織系統角色能力 |
| `authorization/roleToScopeMapping.ts` | 系統角色 → 範圍映射 |
| `authorization/parseScopes.ts` | 範圍名稱解析工具 |
| `types/scopes.ts` | 範圍類型定義, ScopeContext |

### Backend 套件 (`packages/backend/src/`)

| 檔案 | 用途 |
|------|---------|
| `models/RolesModel.ts` | 角色增刪查改操作 |
| `services/RolesService/RolesService.ts` | 角色業務邏輯 |
| `controllers/OrganizationRolesController.ts` | 組織角色 API 端點 |
| `controllers/ProjectRolesController.ts` | 專案角色 API 端點 |
| `database/migrations/20250807212731_add_custom_roles.ts` | 綱要遷移 |

### Frontend 套件 (`packages/frontend/src/`)

| 檔案 | 用途 |
|------|---------|
| `providers/Ability/AbilityProvider.tsx` | AbilityContext 提供者 |
| `providers/Ability/context.ts` | AbilityContext 定義 |
| `hooks/user/useUser.ts` | 具有能力存取權的 User hook |

---

## 常見模式與範例

### 新增僅限企業版的範圍

```typescript
// scopes.ts
{
    name: 'manage:AdvancedAnalytics',
    description: '存取進階分析功能',
    isEnterprise: true,  // 這是關鍵標記
    group: ScopeGroup.DATA,
    getConditions: addDefaultUuidCondition,
}
```

當上下文中的 `isEnterprise: false` 時，企業版範圍會被過濾掉。

### 新增具有空間級別條件的範圍

```typescript
// scopes.ts
{
    name: 'manage:Report@space',
    description: '在您具有編輯者權限的空間中管理報告',
    isEnterprise: false,
    group: ScopeGroup.CONTENT,
    getConditions: (context) => [
        addAccessCondition(context, SpaceMemberRole.EDITOR),
        addAccessCondition(context, SpaceMemberRole.ADMIN),
    ],
}
```

### 檢查多個權限

```typescript
// 後端 - 多個權限中的任何一個
const canManage = user.ability.can('manage', subject('Dashboard', { projectUuid }));
const canCreate = user.ability.can('create', subject('Dashboard', { projectUuid }));

if (!canManage && !canCreate) {
    throw new ForbiddenError('...');
}

// 前端 - 結合檢查
const canEdit = user?.ability.can('manage', 'Dashboard')
    || user?.ability.can('update', 'Dashboard');
```

### 基於資源狀態的動態權限

```typescript
// 檢查具有資源條件的權限
const dashboard = await getDashboard(dashboardUuid);

if (user.ability.cannot('manage', subject('Dashboard', {
    projectUuid: dashboard.projectUuid,
    isPrivate: dashboard.isPrivate,
    access: dashboard.access,  // 空間存取陣列
}))) {
    throw new ForbiddenError('...');
}
```

---

## CASL 能力檢查深挖

了解 CASL 如何評估權限對於編寫正確的授權程式碼至關重要。CASL 使用 MongoDB 風格的查詢匹配來處理條件。

### `manage` 動作 (超級權限)

`manage` 是 CASL 的特殊關鍵字，它匹配**所有動作** (create, view, update, delete, export 等)：

```typescript
// 能力定義
can('manage', 'Dashboard', { projectUuid: 'abc-123' });

// 以下全部返回 TRUE：
ability.can('view', subject('Dashboard', { projectUuid: 'abc-123' }));    // ✅
ability.can('update', subject('Dashboard', { projectUuid: 'abc-123' }));  // ✅
ability.can('delete', subject('Dashboard', { projectUuid: 'abc-123' }));  // ✅
ability.can('create', subject('Dashboard', { projectUuid: 'abc-123' }));  // ✅
ability.can('manage', subject('Dashboard', { projectUuid: 'abc-123' }));  // ✅
```

**使用案例：** 管理員角色通常使用 `manage` 進行全面控制：
```typescript
// projectMemberAbility.ts - 管理員獲得全面控制
can('manage', 'Dashboard', { projectUuid: member.projectUuid });
```

### 條件匹配：精確匹配

當權限檢查條件與能力條件完全匹配時：

```typescript
// 能力定義
can('view', 'Dashboard', { projectUuid: 'abc-123', isPrivate: false });

// 使用完全相同的條件進行檢查
ability.can('view', subject('Dashboard', {
    projectUuid: 'abc-123',
    isPrivate: false
}));  // ✅ TRUE - 精確匹配
```

### 條件匹配：檢查的屬性少於能力定義

當能力定義了條件，但檢查時提供的屬性較少：

```typescript
// 能力定義 - 需要 projectUuid 和 isPrivate
can('view', 'Dashboard', { projectUuid: 'abc-123', isPrivate: false });

// 檢查時缺少條件屬性
ability.can('view', subject('Dashboard', {
    projectUuid: 'abc-123'
    // 缺少 isPrivate！
}));  // ❌ FALSE - 無法驗證 isPrivate: false 條件
```

**為什麼？** 如果未提供屬性，CASL 無法驗證 `isPrivate: false` 條件。這是一個**安全預設值**——資料缺失即拒絕。

### 條件匹配：檢查的屬性多於能力定義

當檢查時提供的屬性多於能力定義所要求的：

```typescript
// 能力定義 - 僅檢查 projectUuid
can('view', 'Dashboard', { projectUuid: 'abc-123' });

// 檢查時包含額外屬性
ability.can('view', subject('Dashboard', {
    projectUuid: 'abc-123',
    isPrivate: true,           // 額外 - 忽略
    name: 'My Dashboard',      // 額外 - 忽略
    createdAt: new Date()      // 額外 - 忽略
}));  // ✅ TRUE - projectUuid 匹配，額外屬性被忽略
```

**為什麼？** CASL 僅檢查能力中定義的條件。主體上的額外屬性不會影響結果。

### 條件匹配：數值不匹配

當條件數值不匹配時：

```typescript
// 能力定義
can('view', 'Dashboard', { projectUuid: 'abc-123' });

// 檢查時使用了不同的 projectUuid
ability.can('view', subject('Dashboard', {
    projectUuid: 'xyz-789'  // 數值不同！
}));  // ❌ FALSE - projectUuid 不匹配
```

### 複雜條件：$elemMatch

對於基於陣列的條件 (如空間存取)：

```typescript
// 能力定義 - 使用者在空間存取陣列中必須具有 EDITOR 角色
can('manage', 'Dashboard', {
    projectUuid: 'abc-123',
    access: {
        $elemMatch: {
            userUuid: 'user-456',
            role: 'editor'
        }
    }
});

// 檢查 - 使用者在存取陣列中且具有 editor 角色
ability.can('manage', subject('Dashboard', {
    projectUuid: 'abc-123',
    access: [
        { userUuid: 'user-456', role: 'editor' },  // ✅ 匹配！
        { userUuid: 'user-789', role: 'viewer' }
    ]
}));  // ✅ TRUE

// 檢查 - 使用者不在存取陣列中
ability.can('manage', subject('Dashboard', {
    projectUuid: 'abc-123',
    access: [
        { userUuid: 'other-user', role: 'editor' }  // 使用者不同
    ]
}));  // ❌ FALSE
```

### 多個能力 (OR 邏輯)

當多個 `can()` 呼叫定義了相同的動作/主體時，它們以 OR 邏輯組合：

```typescript
// 能力定義 - 如果滿足其中一個條件，使用者即可檢視
can('view', 'Dashboard', { isPrivate: false });                        // 公開儀表板
can('view', 'Dashboard', { access: { $elemMatch: { userUuid: 'user-123' } } }); // 他們有存取權限的儀表板

// 檢查公開儀表板 (使用者沒有存取權限項目)
ability.can('view', subject('Dashboard', {
    isPrivate: false,
    access: []
}));  // ✅ TRUE - 匹配第一條規則

// 檢查具有存取權限的私有儀表板
ability.can('view', subject('Dashboard', {
    isPrivate: true,
    access: [{ userUuid: 'user-123', role: 'viewer' }]
}));  // ✅ TRUE - 匹配第二條規則

// 檢查沒有存取權限的私有儀表板
ability.can('view', subject('Dashboard', {
    isPrivate: true,
    access: [{ userUuid: 'other-user', role: 'viewer' }]
}));  // ❌ FALSE - 兩條規則都不匹配
```

### 常見錯誤

**檢查時忘記傳遞條件**
```typescript
// 能力要求 projectUuid
can('view', 'Dashboard', { projectUuid: 'abc-123' });

// 錯誤：檢查時未使用 subject() - 沒有可匹配的條件
ability.can('view', 'Dashboard');  // ❌ FALSE - 未提供條件

// 正確：檢查時使用 subject() 並提供條件
ability.can('view', subject('Dashboard', { projectUuid: 'abc-123' }));  // ✅ TRUE
```

---

## 疑難排解

### 權限意外被拒絕

1. 檢查 `scopes.ts` 中是否存在該範圍。
2. 驗證該範圍是否包含在該使用者的角色中 (系統角色或自定義角色)。
3. 檢查 `isEnterprise` 標記是否與部署環境匹配。
4. 驗證條件是否與正在存取的資源匹配。
5. 檢查主體名稱拼字是否有誤 (區分大小寫)。

### 自定義角色無效

1. 確保 `customRolesEnabled` 為 true。
2. 驗證角色是否透過 `project_memberships.role_uuid` 分配。
3. 檢查 `scoped_roles` 是否包含預期的範圍。
4. 確認範圍是否有效 (存在於 `scopes.ts` 中)。

### 前端權限檢查未更新

1. 確保在角色更改後重新獲取使用者資料。
2. 檢查 TanStack Query 的快取失效機制。
3. 驗證能力物件是從最新的使用者資料中讀取的。
