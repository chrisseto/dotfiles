/**
 * herdr-permission-status
 *
 * Makes @gotgenes/pi-permission-system prompts show up as "needs you" in Herdr.
 *
 * Pi reports OSC 7501 `blocked` for its own select/input/editor dialogs, but the
 * permission prompt is a `ctx.ui.custom` component, which pi does not mark as
 * blocked. This listens to the permission system's broadcast events and writes
 * the OSC 7501 status itself:
 *   permissions:ui_prompt  -> state=blocked kind=permission
 *   permissions:decision   -> back to state=working once no prompt is pending
 *
 * Restoring to `working` matches what pi last reported (a prompt only happens
 * mid-run), so pi's own deduplicated reporter stays consistent and takes over
 * again on its next state change (done / idle / error).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const APP = "pi";

function osc7501(pairs: Record<string, string | undefined>): string {
	const body = Object.entries(pairs)
		.filter(([, v]) => v !== undefined && v !== "")
		.map(([k, v]) => `${k}=${v}`)
		.join(":");
	return `\x1b]7501;${body}\x1b\\`;
}

function b64(text: string): string {
	const clean = text.replace(/[\u0000-\u001f\u007f-\u009f]+/g, " ").trim().slice(0, 1024);
	return clean ? Buffer.from(clean, "utf8").toString("base64") : "";
}

function enabled(): boolean {
	const override = process.env.PI_PROGRAM_STATUS;
	if (override === "0") return false;
	if (override === "1") return true;
	// Only inside a herdr-core terminal, where OSC 7501 is known to be understood.
	return Boolean(process.env.HC_TERMINAL_ID) && Boolean(process.stdout.isTTY);
}

export default function (pi: ExtensionAPI) {
	let active = false; // TUI session with a terminal to report to
	let getSessionName: () => string | undefined = () => undefined;
	const pending = new Map<string, string>(); // requestId -> message

	const write = (seq: string) => {
		if (!active) return;
		try {
			process.stdout.write(seq);
		} catch {
			// best effort
		}
	};

	const reportBlocked = (message: string) =>
		write(osc7501({ state: "blocked", app: APP, kind: "permission", msg: b64(message) }));

	const reportWorking = () =>
		write(osc7501({ state: "working", app: APP, msg: b64(getSessionName() ?? "") }));

	pi.on("session_start", (_event, ctx) => {
		active = ctx.mode === "tui" && enabled();
		getSessionName = () => {
			try {
				return ctx.sessionManager.getSessionName();
			} catch {
				return undefined;
			}
		};
		pending.clear();
	});

	pi.on("session_shutdown", () => {
		if (pending.size) {
			pending.clear();
			reportWorking();
		}
		active = false;
	});

	pi.events.on("permissions:ui_prompt", (data) => {
		const e = data as {
			requestId?: string;
			surface?: string | null;
			value?: string | null;
			forwarding?: { requesterAgentName?: string | null } | null;
		};
		if (!e?.requestId) return;
		const who = e.forwarding?.requesterAgentName ? `${e.forwarding.requesterAgentName}: ` : "";
		const what = [e.surface, e.value].filter(Boolean).join(" ");
		const message = `Permission: ${who}${what || "approval needed"}`;
		pending.set(e.requestId, message);
		reportBlocked(message);
	});

	pi.events.on("permissions:decision", (data) => {
		const e = data as { requestId?: string };
		if (!e?.requestId || !pending.delete(e.requestId)) return;
		const next = [...pending.values()].at(-1);
		if (next) reportBlocked(next);
		else reportWorking();
	});
}
