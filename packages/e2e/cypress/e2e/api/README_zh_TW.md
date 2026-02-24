## 端點列表 (List of endpoints)

### 來自 apiV1Router

- GET /livez
- GET /health
- GET /flash
- POST /register (註冊)
- POST /login (登入)

Google 驗證端點

- GET /logout (登出)

### 來自 savedChartRouter:

GET /saved/:savedQueryUuid AUTH (驗證)
GET /saved/:savedQueryUuid/availableFilters AUTH
DELETE /saved/:savedQueryUuid AUTH
PATCH /saved/:savedQueryUuid AUTH
POST /saved/:savedQueryUuid/version AUTH
GET /saved/:savedQueryUuid AUTH

### 來自 inviteLinksRouter:

GET /invite-links/:inviteLinkCode
POST /invite-links AUTH
DELETE /invite-links AUTH

### 來自 organizationRouter:

GET /org AUTH
PATCH /org AUTH
GET /org/projects AUTH
POST /org/projects AUTH
DELETE /org/projects/:projectUuid AUTH
GET /org/users AUTH
PATCH /org/users/:userUuid AUTH
DELETE /org/users/:userUuid AUTH
GET /org/onboardingStatus AUTH
POST /org/onboardingStatus/shownSuccess AUTH

### 來自 userRouter:

GET /user AUTH
POST /user
PATCH /user/me AUTH
POST /user/password AUTH
POST /user/password/reset
GET /user/identities AUTH
DELETE /user/identities AUTH
PATCH /user/me/complete AUTH

### 來自 projectRouter:

GET /projects/:projectUuid AUTH
PATCH /projects/:projectUuid AUTH
GET /projects/:projectUuid/explores AUTH
GET /projects/:projectUuid/explores/:exploreId AUTH
POST /projects/:projectUuid/explores/:exploreId/compileQuery AUTH
POST /projects/:projectUuid/explores/:exploreId/runQuery AUTH
POST /projects/:projectUuid/refresh AUTH
POST /projects/:projectUuid/saved AUTH
GET /projects/:projectUuid/spaces AUTH
GET /projects/:projectUuid/dashboards AUTH
POST /projects/:projectUuid/dashboards AUTH
POST /projects/:projectUuid/sqlQuery AUTH
GET /projects/:projectUuid/catalog AUTH
GET /projects/:projectUuid/tablesConfiguration AUTH
PATCH /projects/:projectUuid/tablesConfiguration AUTH
GET /projects/:projectUuid/hasSavedCharts AUTH

### 來自 dashboardRouter:

GET /dashboards/:dashboardUuid AUTH
PATCH /dashboards/:dashboardUuid AUTH
DELETE /dashboards/:dashboardUuid AUTH

### 來自 passwordResetLinksRouter:

GET /password-reset/:code
POST /password-reset/

### 來自 jobsRouter

GET /jobs/:jobUuid
