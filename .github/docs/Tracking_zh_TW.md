# 追蹤 (Tracking)

我們都是資料愛好者，所以你知道我們熱愛圖表 ❤️📊 ...而且要構建圖表，我們需要資料 😝

## 摘要

在用戶端，事件是由使用者驅動的；在伺服器端，事件是由資料驅動的。

### 為什麼 Lightdash 要收集這些資料？

在用戶端，我們想了解使用者如何與我們的應用程式行為/互動。

範例：

-   點擊了導航按鈕
-   點擊了建立儀表板按鈕
-   開啟了設定互動視窗
-   使用了執行查詢快捷鍵

注意：用戶端事件並非完全可靠，因為使用者有多種方法可以阻止追蹤。

在伺服器端，我們想了解哪些功能正在被使用。

範例：

-   建立了包含 3 個圖表的儀表板
-   更新了類型為 BAR 的已儲存圖表

## 用戶端 (瀏覽器) 追蹤

在前端，我們有一個 React context/provider (`packages/frontend/src/providers/TrackingProvider.tsx`)，可以輕鬆地從任何元件追蹤事件，所有類型都定義在 `packages/frontend/src/types/Events.ts` 中。

### 事件命名規範

格式：`<元素名稱>.<動作>`
範例：`create_project_button.click`

### 追蹤頁面/互動視窗

在我們的路由中加入新頁面時，請務必使用 `<TrackPage/>` 封裝頁面元件。

範例：

```jsx
<Route path="/welcome">
    <TrackPage name={PageName.WELCOME}>
        <Welcome />
    </TrackPage>
</Route>
```

加入新的互動視窗頁面時，請設定 `type` 和 `category` 屬性。

範例：

```jsx
<TrackPage
    name={PageName.ORGANIZATION_SETTINGS}
    type={PageType.MODAL}
    category={CategoryName.SETTINGS}
>
    <OrganizationPanel />
</TrackPage>
```

### 追蹤動作

加入按鈕或互動式元件時，我們可以使用來自 `useTracking` 的 `track` 方法來記錄事件。這些事件通常不包含額外資訊。

範例：

```js
const { track } = useTracking();
const onClick = useCallback(() => {
    // 其他點擊邏輯
    track({
        name: EventName.RUN_QUERY_BUTTON_CLICKED,
    });
}, [track]);
```

為了給事件提供更多背景資訊，我們可以定義應用程式的重要區塊。這樣我們就可以區分頁面不同區塊中的相同事件。

範例：

```jsx
<TrackSection name={SectionName.PAGE_FOOTER}>...</TrackSection>
```

## 伺服器端追蹤

在後端套件中，我們有 `LightdashAnalytics` 類別來協助追蹤事件。類別與類型都位於 `packages/backend/src/analytics/LightdashAnalytics.ts`。

### 事件命名規範

格式：`<身分>.<動作>`
範例：`organization.created`

### 追蹤

追蹤應在服務層 (service layer) 進行。應避免記錄敏感資訊，如專案詳情或查詢結果。

**我們不應該追蹤的內容：**

-   敏感資訊，如密碼/祕密/憑證
-   dbt 模型/欄位名稱
-   資料倉庫結構名稱
-   查詢的 SQL

**我們可以追蹤的替代內容：**

-   他們使用的是哪種資料倉庫，例如：bigquery, postgres, snowflake
-   dbt 專案有多少個模型
-   他們在查詢中使用了多少個篩選器

範例：

```js
analytics.track({
    event: 'project.created',
    userId: user.userUuid,
    projectId: projectUuid,
    organizationId: user.organizationUuid,
    properties: {
        projectId: projectUuid,
        projectType: data.dbtConnection.type,
        warehouseConnectionType: data.warehouseConnection.type,
    },
});
```
