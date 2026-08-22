import { createServer } from "node:http";
import { access, readFile } from "node:fs/promises";
import { homedir, platform } from "node:os";
import { join } from "node:path";
import { spawn } from "node:child_process";

const PORT = 47321;
const DESTINATION = "https://admin.microsoft.com/";
const chromeRoots = platform() === "win32"
  ? [join(process.env.LOCALAPPDATA || "", "Google/Chrome/User Data"), join(process.env.LOCALAPPDATA || "", "Google/Chrome Beta/User Data"), join(process.env.LOCALAPPDATA || "", "Google/Chrome SxS/User Data")]
  : platform() === "darwin"
    ? [join(homedir(), "Library/Application Support/Google/Chrome")]
    : [join(homedir(), ".config/google-chrome")];

async function firstExisting(paths) {
  for (const path of paths) { try { await access(path); return path; } catch {} }
  throw new Error(`Chrome was not found. Checked: ${paths.join(", ")}`);
}

async function profiles() {
  const statePath = await firstExisting(chromeRoots.map(root => join(root, "Local State")));
  const raw = await readFile(statePath, "utf8");
  const cache = JSON.parse(raw).profile?.info_cache || {};
  return Object.entries(cache).map(([profile, info]) => ({ name: info.name || profile, profile }));
}

async function openProfile(profile) {
  const args = [`--profile-directory=${profile}`, DESTINATION];
  if (platform() === "darwin") return spawn("open", ["-na", "Google Chrome", "--args", ...args], { detached: true, stdio: "ignore" }).unref();
  if (platform() === "win32") {
    const executable = await firstExisting([join(process.env.LOCALAPPDATA || "", "Google/Chrome/Application/chrome.exe"), join(process.env.PROGRAMFILES || "", "Google/Chrome/Application/chrome.exe"), join(process.env["PROGRAMFILES(X86)"] || "", "Google/Chrome/Application/chrome.exe")]);
    return spawn(executable, args, { detached: true, stdio: "ignore" }).unref();
  }
  spawn("google-chrome", args, { detached: true, stdio: "ignore" }).unref();
}

createServer(async (request, response) => {
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");
  response.setHeader("Access-Control-Allow-Private-Network", "true");
  if (request.method === "OPTIONS") return response.writeHead(204).end();
  try {
    const known = await profiles();
    if (request.method === "GET" && request.url === "/profiles") return response.writeHead(200, { "Content-Type": "application/json" }).end(JSON.stringify(known));
    if (request.method === "POST" && request.url === "/open") {
      let body = ""; for await (const chunk of request) body += chunk;
      const selected = JSON.parse(body).profile;
      if (!known.some(item => item.profile === selected)) return response.writeHead(404).end();
      await openProfile(selected); return response.writeHead(204).end();
    }
    response.writeHead(404).end();
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown helper error";
    response.writeHead(500, { "Content-Type": "application/json" }).end(JSON.stringify({ error: message }));
  }
}).listen(PORT, "127.0.0.1", () => console.log(`Chrome Helper ready on http://127.0.0.1:${PORT}`));
