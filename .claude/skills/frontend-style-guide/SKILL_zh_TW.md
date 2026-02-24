---
name: frontend-style-guide
description: 在開發 React 元件、將 Mantine v6 遷移至 v8 或進行前端樣式開發時，套用 Lightdash 前端風格指南。在編輯 TSX 檔案、修復樣式問題，或使用者提到 Mantine、樣式或 CSS 模組時使用。
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Lightdash 前端風格指南 (Lightdash Frontend Style Guide)

在處理 `packages/frontend/` 中的任何前端元件時，請套用這些規則。

## Mantine 8 遷移

**關鍵任務**：我們正在從 Mantine 6 遷移至 8。當您遇到 v6 元件時，請務必將其升級。

## 元件檢查清單 (Component Checklist)

建立/更新元件時：

- [ ] 使用 `@mantine-8/core` 導入。
- [ ] 不使用 `style`、`styles` 或 `sx` 屬性 (props)。
- [ ] 檢查 Mantine 文件/類型以了解可用的元件屬性。
- [ ] 優先使用元件內建的樣式屬性 (inline-style component props) 進行樣式設定 (並遵循 <= 3 個屬性規則)。
- [ ] 當元件屬性無法使用，或需要超過 3 個內建樣式屬性時，請使用 CSS 模組 (CSS modules)。
- [ ] 使用主題值 ('md', 'lg', 'xl' 或 'ldGray.1', 'ldGray.2', 'ldDark.1', 'ldDark.2' 等)，而非幻數 (magic numbers)。
- [ ] 在 CSS 模組中使用 Mantine 顏色時，務必使用主題感知變數：
  - `--mantine-color-${color}-text`：用於填充背景上的文字
  - `--mantine-color-${color}-filled`：用於填充背景 (強烈顏色)
  - `--mantine-color-${color}-filled-hover`：用於懸停時的填充背景
  - `--mantine-color-${color}-light`：用於淺色背景
  - `--mantine-color-${color}-light-hover`：用於懸停時的淺色背景 (淺色)
  - `--mantine-color-${color}-light-color`：用於淺色背景上的文字
  - `--mantine-color-${color}-outline`：用於外框線
  - `--mantine-color-${color}-outline-hover`：用於懸停時的外框線

## 快速遷移指南

```tsx
// ❌ Mantine 6
import { Button, Group } from '@mantine/core';

<Group spacing="xs" noWrap>
    <Button sx={{ mt: 20 }}>點擊</Button>
</Group>;

// ✅ Mantine 8
import { Button, Group } from '@mantine-8/core';

<Group gap="xs" wrap="nowrap">
    <Button mt={20}>點擊</Button>
</Group>;
```

## 關鍵屬性變更 (Key Prop Changes)

- `spacing` → `gap`
- `noWrap` → `wrap="nowrap"`
- `sx` → 元件屬性 (例如：`mt`, `w`, `c`) 或 CSS 模組
- `leftIcon` → `leftSection`
- `rightIcon` → `rightSection`

## 樣式最佳實踐

### 核心原則：主題優先 (Theme First)

**目標是盡可能使用主題預設值。** 樣式覆寫 (Style overrides) 應該是例外，而非規則。

### 樣式層級 (Styling Hierarchy)

1. **最佳**：無自定義樣式 (使用主題預設值)。
2. **主題擴充**：對於重複出現的模式，請將其加入 `mantine8Theme.ts`。
3. **元件屬性**：簡單的覆寫 (1-3 個屬性，如 `mt="xl" w={240}`)。
4. **CSS 模組**：複雜的樣式或超過 3 個屬性。

### 絕對不要使用

- `styles` 屬性 (請務必改用 CSS 模組)。
- `sx` 屬性 (這是 v6 的屬性)。
- `style` 屬性 (內聯樣式)。

### 主題擴充 (適用於重複模式)

如果您發現自己多次套用相同的樣式覆寫，請將其加入 `mantine8Theme.ts` 的主題設定中：

```tsx
// 位於 src/mantine8Theme.ts - 在 components 物件內
components: {
    Button: Button.extend({
        styles: {
            root: {
                minWidth: '120px',
                fontWeight: 600,
            }
        }
    }),
}
```

### 特定上下文的覆寫

#### 元件內建樣式屬性 (1-3 個簡單屬性)

```tsx
// ✅ 良好
<Button mt="xl" w={240} c="blue.6">提交</Button>

// ❌ 不良 - 屬性過多，請改用 CSS 模組
<Button mt={20} mb={20} ml={10} mr={10} w={240} c="blue.6" bg="white">提交</Button>
```

常見的內建樣式屬性：

- 版面 (Layout)：`mt`, `mb`, `ml`, `mr`, `m`, `p`, `pt`, `pb`, `pl`, `pr`
- 尺寸 (Sizing)：`w`, `h`, `maw`, `mah`, `miw`, `mih`
- 顏色 (Colors)：`c` (顏色), `bg` (背景)
- 字體 (Font)：`ff`, `fs`, `fw`
- 文字 (Text)：`ta`, `lh`

#### CSS 模組 (複雜樣式或超過 3 個屬性)

在元件所在的同一個資料夾中建立一個 `.module.css` 檔案：

```css
/* Component.module.css */
.customCard {
    transition: transform 0.2s ease;
    cursor: pointer;
}

.customCard:hover {
    transform: translateY(-2px);
    box-shadow: var(--mantine-shadow-lg);
}
```

```tsx
import styles from './Component.module.css';

<Card className={styles.customCard}>{/* 內容 */}</Card>;
```

**不要包含 `.css.d.ts` 檔案** —— Vite 會自動處理。

## 顏色指南

**優先使用預設的元件顏色** —— Mantine 會自動處理主題切換。

當您需要自定義顏色時，請使用我們的自定義色階以相容於深色模式：

```tsx
// ❌ 不良 - 標準 Mantine 顏色 (對深色模式支援較差)
<Text c="gray.6">次要文字</Text>

// ✅ 良好 - 使用 ldGray 用於邊框和中性元素
<Text c="ldGray.6">次要文字</Text>

// ✅ 良好 - 使用 ldDark 用於在淺色模式下顯示為深色的元素
<Button bg="ldDark.8" c="ldDark.0">深色按鈕</Button>

// ✅ 良好 - 使用前景/背景變數
<Text c="foreground">主要文字</Text>
<Box bg="background">主背景</Box>
```

### 自定義色階 (Custom Color Scales)

| 標記 (Token) | 用途 |
| ------------ | -------------------------------------------------- |
| `ldGray.0-9` | 邊框、細微文字、中性 UI 元素 |
| `ldDark.0-9` | 在淺色模式下具有深色背景的按鈕/徽章 |
| `background` | 頁面/卡片背景 |
| `foreground` | 主要文字顏色 |

### CSS 模組中的深色模式

使用 `@mixin dark` 進行特定主題的覆寫：

```css
.clickableRow {
    &:hover {
        background-color: var(--mantine-color-ldGray-0);

        @mixin dark {
            background-color: var(--mantine-color-ldDark-5);
        }
    }
}
```

另一種方法：使用 CSS `light-dark()` 函式進行單行主題切換：

```css
.clickableRow:hover {
    background-color: light-dark(
        var(--mantine-color-ldGray-0),
        var(--mantine-color-ldDark-5)
    );
}
```

## 務必使用主題標記 (Theme Tokens)

```tsx
// ❌ 不良 - 使用幻數
<Box p={16} mt={24}>

// ✅ 良好 - 使用主題標記
<Box p="md" mt="lg">
```

## 注意相依關係

如果某個元件被遷移為使用 Mantine 8 的 `Menu.Item`，請確保其父元件也使用 Mantine 8 的 `Menu`。

## 移除無用的樣式

在將樣式移至 CSS 模組之前，請檢查是否真的需要它們：

```tsx
// ❌ 不必要 - display: block 對 flex 子元素沒有影響
<Flex justify="flex-end">
    <Button style={{display: 'block'}}>提交</Button>
</Flex>

// ✅ 較佳 - 完全移除該樣式
<Flex justify="flex-end">
    <Button>提交</Button>
</Flex>
```

## 主題感知元件邏輯

對於需要知道目前主題的 JavaScript 邏輯：

```tsx
import { useMantineColorScheme } from '@mantine/core';

const MyComponent = () => {
    const { colorScheme } = useMantineColorScheme();
    const iconColor = colorScheme === 'dark' ? 'blue.4' : 'blue.6';
    // ...
};
```

## 可重複使用的元件 (Reusable Components)

### 互動視窗 (Modals)

- **務必使用來自 `components/common/MantineModal` 的 `MantineModal`** —— 絕不要直接使用 Mantine 的 `Modal`。
- 參見 `stories/Modal.stories.tsx` 了解使用範例。
- 對於互動視窗內的表單：在表單上使用 `id`，並在提交按鈕上使用 `form="form-id"`。
- 對於互動視窗內的警示：使用 `Callout`，變體 (variants) 分別為 `danger`, `warning`, `info`。

### 標註 (Callouts)

- 使用來自 `components/common/Callout` 的 `Callout`。
- 變體：`danger`, `warning`, `info`。

### 多型可點擊容器 (Polymorphic Clickable Containers)

當您需要一個既是版面容器又是可點擊的元素時使用——這可以避免原生 `<button>` 背景/邊框重設的問題。

- **`PolymorphicGroupButton`** (來自 `components/common/PolymorphicGroupButton`) —— 一個具備多型特性且設定了 `cursor: pointer` 的 `Group` (flex row)。用於當作單一按鈕使用的水平元素組。
- **`PolymorphicPaperButton`** (來自 `components/common/PolymorphicPaperButton`) —— 一個具備多型特性且設定了 `cursor: pointer` 的 `Paper` (卡片表面)。用於卡片式的可點擊表面。

兩者都接受其基礎元件的所有屬性 (`GroupProps` / `PaperProps`)，外加一個用於指定底層元素的 `component` 屬性。

```tsx
// ✅ 可點擊的列，且不會有原生按鈕的樣式問題
<PolymorphicGroupButton component="div" gap="sm" onClick={handleClick}>
    <MantineIcon icon={IconFolder} />
    <Text>標籤</Text>
</PolymorphicGroupButton>

// ✅ 可點擊的卡片表面
<PolymorphicPaperButton component="div" p="md" onClick={handleClick}>
    卡片內容
</PolymorphicPaperButton>

// ❌ 應避免 - 原生 <button> 在選單和面板中會帶來多餘的背景/邊框
<UnstyledButton>
    <Group>...</Group>
</UnstyledButton>
```

### 截斷文字 (TruncatedText)

- 當文字可能超出限制寬度時，請使用來自 `components/common/TruncatedText` 的 `TruncatedText`。
- 傳遞 `maxWidth` (數字或字串) 以控制截斷邊界。
- **僅當文字確實被截斷時**，才會自動顯示帶有全文的工具提示 (避免為短名稱顯示過多工具提示)。
- 預設為 `fz="sm"`；可透過標準 `Text` 屬性進行覆寫。

```tsx
// ✅ 良好 - 截斷長名稱，僅在需要時顯示工具提示
<TruncatedText maxWidth={200}>{item.name}</TruncatedText>

// ✅ 接受任何 Text 屬性
<TruncatedText maxWidth="100%" fw={500}>{space.name}</TruncatedText>
```

## Mantine 文件

所有元件清單及文件連結 (LLM 友善格式)：`https://mantine.dev/llms.txt`
