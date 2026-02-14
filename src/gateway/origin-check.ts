import { isLoopbackHost } from "./net.js";

type OriginCheckResult = { ok: true } | { ok: false; reason: string };

function normalizeHostHeader(hostHeader?: string): string {
  return (hostHeader ?? "").trim().toLowerCase();
}

function resolveHostName(hostHeader?: string): string {
  const host = normalizeHostHeader(hostHeader);
  if (!host) {
    return "";
  }
  if (host.startsWith("[")) {
    const end = host.indexOf("]");
    if (end !== -1) {
      return host.slice(1, end);
    }
  }
  const [name] = host.split(":");
  return name ?? "";
}

function parseOrigin(
  originRaw?: string,
): { origin: string; host: string; hostname: string; port: string } | null {
  const trimmed = (originRaw ?? "").trim();
  if (!trimmed || trimmed === "null") {
    return null;
  }
  try {
    const url = new URL(trimmed);
    return {
      origin: url.origin.toLowerCase(),
      host: url.host.toLowerCase(),
      hostname: url.hostname.toLowerCase(),
      port: url.port,
    };
  } catch {
    return null;
  }
}

export function checkBrowserOrigin(params: {
  requestHost?: string;
  origin?: string;
  allowedOrigins?: string[];
  /** The port the gateway is listening on. When provided, loopback origin
   *  checks also verify that the origin port matches the gateway port (or
   *  both are standard HTTP/HTTPS ports). */
  gatewayPort?: number;
}): OriginCheckResult {
  const parsedOrigin = parseOrigin(params.origin);
  if (!parsedOrigin) {
    return { ok: false, reason: "origin missing or invalid" };
  }

  const allowlist = (params.allowedOrigins ?? [])
    .map((value) => value.trim().toLowerCase())
    .filter(Boolean);
  if (allowlist.includes(parsedOrigin.origin)) {
    return { ok: true };
  }

  const requestHost = normalizeHostHeader(params.requestHost);
  if (requestHost && parsedOrigin.host === requestHost) {
    return { ok: true };
  }

  const requestHostname = resolveHostName(requestHost);
  if (isLoopbackHost(parsedOrigin.hostname) && isLoopbackHost(requestHostname)) {
    // When the gateway is bound to a specific port, require the origin port
    // to match the gateway port so that other localhost services cannot
    // make cross-port requests masquerading as same-origin.
    if (params.gatewayPort != null) {
      const originPort = parsedOrigin.port || inferDefaultPort(parsedOrigin.origin);
      const gwPort = String(params.gatewayPort);
      if (originPort && gwPort && originPort !== gwPort) {
        return { ok: false, reason: "loopback origin port mismatch" };
      }
    }
    return { ok: true };
  }

  return { ok: false, reason: "origin not allowed" };
}

/** Infer the default port from the origin's protocol when no explicit port is present. */
function inferDefaultPort(origin: string): string {
  if (origin.startsWith("https:")) {
    return "443";
  }
  if (origin.startsWith("http:")) {
    return "80";
  }
  return "";
}
