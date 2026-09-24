const URLPIPE = "https://urlpipe.dev";

function urlpipe_(path, body) {
  const key = PropertiesService.getScriptProperties().getProperty("URLPIPE_API_KEY");
  const res = UrlFetchApp.fetch(URLPIPE + path, {
    method: "post",
    contentType: "application/json",
    headers: { Authorization: "Bearer " + key },
    payload: JSON.stringify(Object.assign({ sync: true }, body)),
    muteHttpExceptions: true,
  });
  const text = res.getContentText();
  if (res.getResponseCode() !== 200) {
    throw new Error("URLpipe " + res.getResponseCode() + ": " + text);
  }
  return JSON.parse(text);
}

/**
 * Title, description and image of a page, across three cells.
 * @param {string} url The page's address.
 * @customfunction
 */
function URLPIPE_META(url) {
  if (!url) return "";
  const m = urlpipe_("/meta", { url: url });
  return [[m.title, m.description, m.main_image_url]];
}

/** Adds a menu that fills column E with mobile performance scores. */
function onOpen() {
  SpreadsheetApp.getUi().createMenu("URLpipe")
    .addItem("Lighthouse scores into column E", "fillLighthouse")
    .addToUi();
}

function fillLighthouse() {
  const sheet = SpreadsheetApp.getActiveSheet();
  const rows = sheet.getRange(2, 1, sheet.getLastRow() - 1, 1).getValues();
  rows.forEach(function (row, i) {
    if (!row[0]) return;
    const audit = urlpipe_("/lighthouse", { url: row[0], device: "mobile" });
    const score = audit.categories.performance.score;
    sheet.getRange(i + 2, 5).setValue(score === null ? "" : Math.round(score * 100));
  });
}
