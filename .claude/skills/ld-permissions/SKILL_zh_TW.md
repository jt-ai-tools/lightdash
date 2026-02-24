---
name: ld-permissions
description: Lightdash 基於 CASL 的授權系統指南。當處理範圍 (scopes)、自定義角色、能力 (abilities)、權限、ForbiddenError、授權或存取控制時使用。協助新增範圍、除錯權限問題、理解權限流程以及建立自定義角色。
allowed-tools: Read, Grep, Glob, Task
---

# 權限與授權指南 (Permissions & Authorization Guide)

此技能協助您處理 Lightdash 基於 CASL 的權限系統，包括範圍、自定義角色和授權執行。

## 您需要什麼幫助？

1. **新增範圍/權限** - 新增權限的逐步指南。
2. **除錯權限問題** - 疑難排解為什麼使用者無法存取某些內容。
3. **理解權限流程** - 學習權限如何端對端運作。
4. **處理自定義角色** - 建立或修改具有特定範圍的自定義角色。

## 快速參考

### 關鍵檔案

| 用途 | 位置 |
|---------|----------|
| 範圍定義 | `packages/common/src/authorization/scopes.ts` |
| CASL 類型 | `packages/common/src/authorization/types.ts` |
| 能力建構器 (Ability builder) | `packages/common/src/authorization/index.ts` |
| 系統角色能力 | `packages/common/src/authorization/projectMemberAbility.ts` |
| 角色與範圍映射 | `packages/common/src/authorization/roleToScopeMapping.ts` |
| 範圍至 CASL 轉換 | `packages/common/src/authorization/scopeAbilityBuilder.ts` |

### 常見模式

**後端權限檢查：**
```typescript
import { subject } from '@casl/ability';
import { ForbiddenError } from '@lightdash/common';

if (user.ability.cannot('manage', subject('Dashboard', { projectUuid }))) {
    throw new ForbiddenError('您沒有權限');
}
```

**前端權限檢查：**
```typescript
const { user } = useUser();

if (user?.ability.can('manage', 'Dashboard')) {
    return <EditButton />;
}
```

或封裝在 CASL 元件中：

```tsx
import { Can } from '../../providers/Ability';

<Can I="manage" a="Dashboard">
    <EditButton />
</Can>
```

## 完整文件

如需完整文件，請參閱：`.context/PERMISSIONS_zh_TW.md`

內容包括：
- 顯示完整權限流程的架構圖。
- 所有範圍分組與修飾符 (@self, @public, @space 等)。
- 自定義角色的資料庫綱要。
- 新增範圍的逐步指南。
- 疑難排解指南。

## 新增範圍 (快速指南)

1. 在 `packages/common/src/authorization/scopes.ts` 中**定義範圍**：
```typescript
{
    name: 'manage:NewFeature',
    description: '自定義角色 UI 的說明',
    isEnterprise: false,
    group: ScopeGroup.PROJECT_MANAGEMENT,
    getConditions: (context) => [addUuidCondition(context)],
}
```

2. 在 `packages/common/src/authorization/types.ts` 中**加入主體 (Subject)** (如果是新的類型)。

3. 在 `packages/common/src/authorization/roleToScopeMapping.ts` 中**加入系統角色**。

4. 在 `packages/common/src/authorization/projectMemberAbility.ts` 中**更新能力建構器**。

5. 使用 `user.ability.cannot()` 在**服務中執行**檢查。

6. 使用 `user?.ability.can()` **加入前端檢查**。

## 疑難排解權限問題

當使用者遇到 "ForbiddenError" 時：

1. **檢查範圍是否存在** —— 該範圍是否定義在 `scopes.ts` 中？
2. **檢查角色分配** —— 使用者的角色是否包含此範圍？
3. **檢查條件** —— CASL 條件是否與資源相符？
4. **檢查企業版標記** —— 是否設定為 `isEnterprise: true` 但部署環境非企業版？
5. **檢查主體名稱** —— 是否與 `CaslSubjectNames` 中的名稱完全匹配 (區分大小寫)？

使用 grep 找出檢查權限的位置：
```bash
grep -r "ability.cannot.*'manage'.*'YourSubject'" packages/backend/src/services/
```

請描述您想要完成的任務，或要求我解釋權限系統的任何層面。
