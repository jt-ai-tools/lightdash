# 前端 (Frontend)

目錄：

- [入門指南](#入門指南)
- [關鍵技術/函式庫](#關鍵技術函式庫)
- [架構](#架構)
    - [UI](#ui)
    - [功能 (Features)](#功能-features)
    - [API](#api)
    - [頁面 (Pages)](#頁面-pages)

## 入門指南

本套件不應單獨執行。相反地，您應該遵循貢獻指引文件中[設定開發環境](../../.github/CONTRIBUTING_zh_TW.md#設定開發環境)章節的說明。

## 關鍵技術/函式庫

- [React](https://reactjs.org/)
- [Vite](https://vitejs.dev/)
- [Mantine](https://mantine.dev/)
- [React Query](https://react-query.tanstack.com/)
- [Echarts](https://echarts.apache.org/en/index.html)

## 架構 (Architecture)

> **注意：** 任何不符合此結構的資料夾應被視為舊版 (legacy)，並應進行重構。

**範例結構：**

- UI
    - Molecules (分子)
    - Organisms (有機體)
- Features (功能)
    - User (使用者)
        - Hooks
        - Components (元件)
        - Modals (互動視窗)
        - Utils (工具函式)
        - Providers (提供者)
    - Organization (組織)
    - Project (專案)
    - Chart (圖表)
    - Dashboard (儀表板)
    - Space (空間)
    - Visualization (視覺化)
- API
- Pages (頁面)

此結構提供兩個進入點 (透過 `features` 或 `pages`)，這使得新開發人員更容易學習程式碼庫。此外，它消除了抽象的全域資料夾，減少了潛在的雜亂堆放區。

> 靈感來源：[功能驅動的資料夾結構 (Feature-driven folder structure)](https://profy.dev/article/react-folder-structure)

### UI

靈感來自於[原子設計結構 (Atomic Design Structure)](https://bootcamp.uxdesign.cc/from-atoms-to-pages-implementing-atomic-design-in-react-2c91d1031e7c)。

#### ~~Atoms (原子)~~

我們不應該需要這個資料夾，因為 [Mantine](https://mantine.dev/) 應該在這個層級提供所有元件。

#### Molecules (分子)

由一個或多個原子組件組成。它們應僅包含執行其預期功能所需的最小邏輯和狀態量。分子組件的範例包括表單欄位、卡片和其他由多個原子組件組成的類似 UI 元素。

準則：

- 元件將在多個地方重複使用。
- 不能管理內部狀態。

Lint 限制：

- 不能導入程式碼庫其餘部分的檔案。

#### Organisms (有機體)

有機體由一個或多個分子或原子組件組成。它們的範疇往往較大，並為 UI 提供結構感。範例包括標頭 (headers)、頁尾 (footers) 和側邊欄 (sidebars)。

準則：

- 可以管理基本的內部狀態。例如：`const [isOpen, setIsOpen] = useState<boolean>(false)`。

Lint 限制：

- 僅能導入來自 Molecules 的檔案。

### Features (功能)

應用程式的每個主要功能 (也就是知識領域) 都應該有一個資料夾。一個很好的指標是我們如何建構 API 路由。例如：org, user, project, chart, dashboard。
還有一些大型的 UI 功能也值得擁有自己的資料夾。例如：visualizations。
每個功能都應該有 `hooks`, `components`, `modals`, `utils`, `provider` 等子資料夾。

### API

應僅包含與我們的 API 進行互動所需的端點 (endpoints) 和類型。

準則：

- 檔案應與後端的 router/controller 檔案一一對應。
- 純函式 (Pure functions)。
- 不要包含 hooks，這些應在功能 (feature) 的 `hooks` 資料夾中定義。

Lint 限制：

- 不能導入前端程式碼庫其餘部分的檔案。

### Pages (頁面)

這應與我們的網站路由一一對應。
