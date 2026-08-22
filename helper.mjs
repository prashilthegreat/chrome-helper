import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { homedir, platform } from "node:os";
import { join } from "node:path";
import { spawn } from "node:child_process";

const PORT = 47321;
const chromeRoots = {
  darwin: join(homedir(), "Library/Application Support/Google/Chrome"),
  win32: join(process.env.LOCALAPPDATA || "", "Google/Chrome/User Data"),
  linux: join(homedir(), ".config/google-chrome"),
};

async function profiles() {
  const raw = await readFile(join(chromeRoots[platform()], "Local State"), "utf8");
  const cache = JSON.parse(raw).profile?.info_cache || {};
  return Object.entries(cache).map(([profile, info]) => ({ name: info.name || profile, profile }));
}

function openProfile(profile) {
  const args = [`--profile-directory=${profile}`];
  if (platform() === "darwin") return spawn("open", ["-na", "Google Chrome", "--args", ...args], { detached: true, stdio: "ignore" }).unref();
  if (platform() === "win32") return spawn(join(process.env.PROGRAMFILES || "", "Google/Chrome/Application/chrome.exe"), args, { detached: true, stdio: "ignore" }).unref();
  spawn("google-chrome", args, { detached: true, stdio: "ignore" }).unref();
}

createServer(async (request, response) => {
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (request.method === "OPTIONS") return response.writeHead(204).end();
  try {
    const known = await profiles();
    if (request.method === "GET" && request.url === "/profiles") return response.writeHead(200, { "Content-Type": "application/json" }).end(JSON.stringify(known));
    if (request.method === "POST" && request.url === "/open") {
      let body = ""; for await (const chunk of request) body += chunk;
      const selected = JSON.parse(body).profile;
      if (!known.some(item => item.profile === selected)) return response.writeHead(404).end();
      openProfile(selected); return response.writeHead(204).end();
    }
    response.writeHead(404).end();
  } catch { response.writeHead(500).end(); }
}).listen(PORT, "127.0.0.1", () => console.log(`Switchboard helper ready on http://127.0.0.1:${PORT}`));
