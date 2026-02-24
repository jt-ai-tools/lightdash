# GeoJSON 資料來源

## us-states.geojson

用於面量圖 (area/choropleth maps) 的美國州界線。

**來源：** [PublicaMundi/MappingAPI](https://github.com/PublicaMundi/MappingAPI)

### 可用屬性

| 屬性 (Property) | 說明 | 範例 |
| --------- | ------------------------- | ---------- |
| `name`    | 州名 | California |
| `code`    | 兩字母州代碼 | CA |
| `density` | 人口密度 | 241.7 |

---

## countries.geojson

用於面量圖的世界各國邊界。

**來源：** [datasets/geo-countries](https://github.com/datasets/geo-countries)

**原始資料：** [Natural Earth](https://www.naturalearthdata.com/) - 公有領域 (public domain)

**授權：** [Open Data Commons Public Domain Dedication and License (PDDL)](https://opendatacommons.org/licenses/pddl/)

### 可用屬性

每個國家的特徵包含以下可用於匹配的屬性：

| 屬性 (Property) | 說明 | 範例 |
| ------------------- | ----------------------- | ------- |
| `name`              | 國家名稱 | Italy |
| `ISO3166-1-Alpha-2` | ISO 3166-1 alpha-2 代碼 | IT |
| `ISO3166-1-Alpha-3` | ISO 3166-1 alpha-3 代碼 | ITA |
