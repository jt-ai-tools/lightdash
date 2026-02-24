# 關於種子資料 (Seed) 順序的警告

**這之所以能運作，是因為 knex 會按字母順序排列種子資料目錄，而 `ee` 排在 `database` 之後。**

否則我們將會因為以下兩個原因而被阻礙：

- Knex 中存在一個錯誤，它按字母順序排列種子資料資料夾，而不是保持陣列中的順序。
- 我們本應能夠在 `knexfile.js` 中使用 `specific` 選項來指定來自不同資料夾的種子資料順序。但存在一個[阻止傳遞陣列的錯誤](https://github.com/knex/knex/issues?q=is%3Aissue+is%3Aopen+seed+specific)。
