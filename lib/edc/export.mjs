#!/usr/bin/env node
import { chromium } from "playwright";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs";
import { randomUUID } from "crypto";
import { join } from "path";
import { homedir } from "os";

const PORTAL_URL = "https://portal.edc-cr.cz";
const API_BASE = "https://api.portal.edc-cr.cz/api/v0";

function log(...args) {
  process.stderr.write(args.join(" ") + "\n");
}

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = { eans: [], sseIds: [] };

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--username" && args[i + 1]) opts.username = args[++i];
    else if (args[i] === "--password" && args[i + 1]) opts.password = args[++i];
    else if (args[i] === "--from" && args[i + 1]) opts.from = args[++i];
    else if (args[i] === "--to" && args[i + 1]) opts.to = args[++i];
    else if (args[i] === "--output" && args[i + 1]) opts.output = args[++i];
    else if (args[i] === "--ean" && args[i + 1]) opts.eans.push(args[++i]);
    else if (args[i] === "--sse" && args[i + 1]) opts.sseIds.push(parseInt(args[++i]));
    else if (args[i] === "--profile" && args[i + 1]) opts.profile = args[++i].toUpperCase();
    else if (args[i] === "--calc" && args[i + 1]) opts.calc = args[++i].toUpperCase();
    else if (args[i] === "--state-dir" && args[i + 1]) opts.stateDir = args[++i];
  }

  if (!opts.username || !opts.password) {
    throw new Error("--username and --password are required");
  }

  opts.stateDir = opts.stateDir || join(homedir(), ".edc-session");
  opts.profile = opts.profile || "STANDARD";
  opts.calc = opts.calc || "MONTHLY";

  if (opts.eans.length === 0 && opts.sseIds.length === 0) {
    opts.sseIds.push(37183);
  }

  if (!opts.from || !opts.to) {
    const now = new Date();
    const firstOfThisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastOfPrevMonth = new Date(firstOfThisMonth - 1);
    const firstOfPrevMonth = new Date(lastOfPrevMonth.getFullYear(), lastOfPrevMonth.getMonth(), 1);
    const fmt = (d) =>
      `${String(d.getDate()).padStart(2, "0")}.${String(d.getMonth() + 1).padStart(2, "0")}.${d.getFullYear()}`;
    opts.from = opts.from || fmt(firstOfPrevMonth);
    opts.to = opts.to || fmt(lastOfPrevMonth);
  }

  return opts;
}

async function getAccessToken(opts) {
  log("Launching headless browser...");
  const browser = await chromium.launch({ headless: true });

  mkdirSync(opts.stateDir, { recursive: true });
  const stateFile = join(opts.stateDir, "state.json");
  const hasState = existsSync(stateFile);
  const context = hasState
    ? await browser.newContext({ storageState: stateFile })
    : await browser.newContext();
  const page = await context.newPage();

  try {
    await page.goto(`${PORTAL_URL}/`, { waitUntil: "domcontentloaded", timeout: 30000 });
    await page.waitForTimeout(3000);

    const loginBtn = page.getByRole("button", { name: "Registrace / Přihlášení" }).first();
    const needsLogin = await loginBtn.isVisible({ timeout: 3000 }).catch(() => false);

    if (needsLogin) {
      log("Logging in...");
      await Promise.all([
        page.waitForURL(/sso\.portal\.edc-cr\.cz/, { timeout: 30000 }),
        loginBtn.click(),
      ]);

      await fillCredentials(page, opts);
      await page.waitForTimeout(8000);

      if (page.url().includes("sso.portal.edc-cr.cz")) {
        const backLink = page.getByText("Zpět na aplikaci");
        if (await backLink.isVisible({ timeout: 2000 }).catch(() => false)) {
          log("Session conflict — dismissing old session...");
          await backLink.click();
          await page.waitForTimeout(3000);
          await page.goto(`${PORTAL_URL}/`, { waitUntil: "domcontentloaded", timeout: 30000 });
          await page.waitForTimeout(2000);
          const loginBtn2 = page.getByRole("button", { name: "Registrace / Přihlášení" }).first();
          if (await loginBtn2.isVisible({ timeout: 5000 }).catch(() => false)) {
            await Promise.all([
              page.waitForURL(/sso\.portal\.edc-cr\.cz/, { timeout: 30000 }),
              loginBtn2.click(),
            ]);
            await fillCredentials(page, opts);
            await page.waitForTimeout(8000);
          }
        }
      }
    } else {
      log("Session still valid, skipping login.");
    }

    await page.waitForTimeout(5000);

    let token = null;
    for (let i = 0; i < 15; i++) {
      token = await page.evaluate(() => {
        const key = Object.keys(sessionStorage).find((k) => k.startsWith("oidc.user:"));
        if (!key) return null;
        const data = JSON.parse(sessionStorage.getItem(key));
        if (!data.access_token) return null;
        return { access_token: data.access_token, refresh_token: data.refresh_token, expires_at: data.expires_at };
      });
      if (token?.access_token) break;
      log(`  Waiting for token... (${i + 1}s)`);
      await page.waitForTimeout(1000);
    }

    if (!token?.access_token) {
      await page.screenshot({ path: join(opts.stateDir, "debug.png") });
      log("Debug screenshot saved to " + join(opts.stateDir, "debug.png"));
      log("Current URL:", page.url());
      throw new Error("Failed to obtain access token");
    }

    await context.storageState({ path: stateFile });
    log(`Token obtained (expires in ${Math.round((token.expires_at - Date.now() / 1000) / 60)}min)`);
    return token;
  } finally {
    await browser.close();
  }
}

async function fillCredentials(page, opts) {
  const emailField = page.locator('input[placeholder*="mail"]').first();
  await emailField.waitFor({ state: "visible", timeout: 30000 });
  await page.waitForTimeout(1000);
  await emailField.fill(opts.username);
  const passField = page.locator('input[placeholder*="heslo"]').first();
  await passField.click();
  await passField.pressSequentially(opts.password, { delay: 50 });
  await page.waitForTimeout(500);
  await page.getByRole("button", { name: "Přihlásit se" }).click();
}

async function apiCall(token, method, path, body = null) {
  const url = path.startsWith("http") ? path : `${API_BASE}${path}`;
  const headers = {
    Authorization: `Bearer ${token}`,
    "edc-contract-type": "STANDARD",
    "x-correlation-id": randomUUID(),
    Accept: "application/json",
  };
  const fetchOpts = { method, headers };
  if (body) {
    headers["Content-Type"] = "application/json";
    fetchOpts.body = JSON.stringify(body);
  }
  const res = await fetch(url, fetchOpts);
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API ${method} ${path} → ${res.status}: ${text.substring(0, 300)}`);
  }
  return res;
}

async function createExport(token, opts) {
  const toIsoDate = (d) => {
    const [day, month, year] = d.split(".");
    return `${year}-${month}-${day}T00:00:00.000Z`;
  };

  const now = new Date();
  const fileName = `Export-dat-${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}-${String(now.getHours()).padStart(2, "0")}-${String(now.getMinutes()).padStart(2, "0")}`;

  const useEan = opts.eans.length > 0;
  log(`Creating export "${fileName}" for ${opts.from} — ${opts.to}`);
  log(`  Input: ${useEan ? "EAN" : "SSE"} | Profile: ${opts.profile} | Calc: ${opts.calc}`);

  const payload = {
    calculationType: opts.calc,
    currentEnteredDateTime: null,
    inputData: true,
    outputData: true,
    dateFrom: toIsoDate(opts.from),
    dateTo: toIsoDate(opts.to),
    inputType: useEan ? "EAN" : "SSE",
    profileType: opts.profile,
    fileName,
    exportAllProfiles: true,
  };

  if (useEan) {
    payload.eans = opts.eans;
  } else {
    payload.sseId = opts.sseIds;
  }

  const res = await apiCall(token, "POST", "/profiles-data/export-profiles-data", payload);
  const data = await res.json();
  log("Export scheduled:", JSON.stringify(data));
  return { exportName: data.name || fileName, ...data };
}

async function waitForReport(token, exportResult, maxWaitMs = 120000) {
  const { id: reportId, exportName } = exportResult;
  log(`Waiting for report ${reportId || exportName}...`);
  const start = Date.now();

  while (Date.now() - start < maxWaitMs) {
    try {
      const res = await apiCall(token, "GET", "/report?page=0&perPage=5&sortBy=requested&sortOrder=desc");
      const data = await res.json();
      const report = data.content?.find((r) =>
        (reportId && r.id === reportId) || r.name === exportName
      );
      if (report?.reportState === "GENERATED") {
        log(`Report ready: ID ${report.id}`);
        return report;
      }
      if (report?.reportState === "ERROR") {
        throw new Error("Report generation failed (state: ERROR). The requested data may not be available.");
      }
      if (report) {
        log(`  State: ${report.reportState}...`);
      }
    } catch (err) {
      if (err.message.includes("Report generation failed")) throw err;
      log(`  Poll error: ${err.message} — retrying...`);
    }
    await new Promise((r) => setTimeout(r, 5000));
  }
  throw new Error("Timed out waiting for report");
}

async function downloadReport(token, reportId, outputPath) {
  log(`Downloading report ${reportId}...`);
  const res = await apiCall(token, "GET", `/report/${reportId}/download`);
  const contentType = res.headers.get("content-type") || "";

  if (contentType.includes("json")) {
    const data = await res.json();
    if (data.url) {
      const fileRes = await fetch(data.url);
      writeFileSync(outputPath, await fileRes.text());
    } else {
      writeFileSync(outputPath, JSON.stringify(data));
    }
  } else {
    writeFileSync(outputPath, Buffer.from(await res.arrayBuffer()));
  }

  log(`Saved to ${outputPath}`);
}

async function main() {
  const opts = parseArgs();
  log(`EDC Export: ${opts.from} — ${opts.to}`);

  const tokenData = await getAccessToken(opts);
  const exportResult = await createExport(tokenData.access_token, opts);
  const report = await waitForReport(tokenData.access_token, exportResult);

  const outputFile = opts.output || `edc-export-${opts.from.replace(/\./g, "")}-${opts.to.replace(/\./g, "")}.csv`;
  await downloadReport(tokenData.access_token, report.id, outputFile);

  process.stdout.write(JSON.stringify({ status: "ok", file: outputFile }) + "\n");
}

main().catch((err) => {
  process.stderr.write(JSON.stringify({ status: "error", message: err.message }) + "\n");
  process.exit(1);
});
