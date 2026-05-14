#!/usr/bin/env python3

import hashlib
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass


OUTPUT_RE = re.compile(r'output\s*=\s*"([^"]+)"')
MODE_RE = re.compile(r'mode\s*=\s*"([^"]+)"')
POSITION_RE = re.compile(r'position\s*=\s*"([^"]+)"')
SCALE_RE = re.compile(r'scale\s*=\s*([^,\n]+)')
DISABLED_RE = re.compile(r'disabled\s*=\s*(true|false)')
MODE_LABELS = {
    "laptop": "Laptop only",
    "external": "External only",
    "both": "Both displays",
    "custom": "Custom mode",
}


@dataclass
class Block:
    start: int
    end: int
    lines: list[str]
    commented: bool
    output: str
    mode: str
    position: str
    scale: str
    disabled: bool
    fingerprint: str

    @property
    def is_laptop(self) -> bool:
        output = self.output.lower()
        return output.startswith("edp") or output.startswith("lvds")


def expand_path(path: str) -> str:
    return os.path.abspath(os.path.expanduser(path))


def parse_value(pattern: re.Pattern[str], text: str) -> str:
    match = pattern.search(text)
    return match.group(1).strip() if match else ""


def uncomment_line(line: str) -> str:
    return re.sub(r"^(\s*)--\s?", r"\1", line)


def comment_line(line: str) -> str:
    if not line.strip():
        return line
    cleaned = uncomment_line(line)
    indent = re.match(r"^(\s*)", cleaned).group(1)
    return f"{indent}-- {cleaned[len(indent):]}"


def block_fingerprint(output: str, mode: str, position: str, scale: str) -> str:
    raw = json.dumps(
        {"output": output, "mode": mode, "position": position, "scale": scale},
        sort_keys=True,
        ensure_ascii=True,
    )
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()


def format_mode(mode: str) -> str:
    return MODE_LABELS.get(mode, mode or "Unknown")


def parse_blocks(lines: list[str]) -> list[Block]:
    blocks: list[Block] = []
    i = 0
    while i < len(lines):
        uncommented = uncomment_line(lines[i])
        if re.match(r"^\s*hl\.monitor\(\{\s*$", uncommented):
            start = i
            j = i
            while j < len(lines):
                if re.match(r"^\s*\}\)\s*$", uncomment_line(lines[j])):
                    break
                j += 1
            if j >= len(lines):
                raise RuntimeError("Failed to parse hl.monitor({...}) block in monitors.lua")

            block_lines = lines[start : j + 1]
            combined = "\n".join(uncomment_line(line) for line in block_lines)
            output = parse_value(OUTPUT_RE, combined)
            mode = parse_value(MODE_RE, combined)
            position = parse_value(POSITION_RE, combined)
            scale = parse_value(SCALE_RE, combined)
            disabled = bool(re.search(r'disabled\s*=\s*true', combined))
            commented = all(
                (not line.strip()) or re.match(r"^\s*--", line)
                for line in block_lines
            )

            blocks.append(
                Block(
                    start=start,
                    end=j,
                    lines=block_lines,
                    commented=commented,
                    output=output,
                    mode=mode,
                    position=position,
                    scale=scale,
                    disabled=disabled,
                    fingerprint=block_fingerprint(output, mode, position, scale),
                )
            )
            i = j + 1
            continue
        i += 1
    return blocks


def load_state(state_path: str) -> dict:
    try:
        with open(state_path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except FileNotFoundError:
        return {}
    except json.JSONDecodeError:
        return {}


def save_state(state_path: str, state: dict) -> None:
    os.makedirs(os.path.dirname(state_path), exist_ok=True)
    with open(state_path, "w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2, ensure_ascii=False)
        handle.write("\n")


def choose_preferred_blocks(blocks: list[Block], state: dict) -> tuple[list[Block], list[Block]]:
    laptops = [block for block in blocks if block.is_laptop]
    externals = [block for block in blocks if not block.is_laptop]

    state_laptops = set(state.get("laptop_fingerprints", []))
    state_externals = set(state.get("external_fingerprints", []))

    preferred_laptops = [block for block in laptops if block.fingerprint in state_laptops]
    preferred_externals = [block for block in externals if block.fingerprint in state_externals]

    if not preferred_laptops:
        preferred_laptops = [block for block in laptops if not block.commented and not block.disabled]
    if not preferred_externals:
        preferred_externals = [block for block in externals if not block.commented and not block.disabled]

    if not preferred_laptops and laptops:
        preferred_laptops = [laptops[0]]
    if not preferred_externals and externals:
        preferred_externals = [externals[0]]

    return preferred_laptops, preferred_externals


def detect_mode(blocks: list[Block]) -> str:
    active_laptops = [block for block in blocks if block.is_laptop and not block.commented and not block.disabled]
    active_externals = [block for block in blocks if (not block.is_laptop) and not block.commented and not block.disabled]
    if active_laptops and active_externals:
        return "both"
    if active_laptops:
        return "laptop"
    if active_externals:
        return "external"
    return "custom"


def render_block(block: Block, commented: bool, disabled: bool) -> list[str]:
    indent = re.match(r"^(\s*)", uncomment_line(block.lines[0])).group(1)
    item_indent = indent + "    "
    lines = [
        f"{indent}hl.monitor({{",
        f'{item_indent}output = "{block.output}",',
    ]

    if disabled:
        lines.append(f"{item_indent}disabled = true,")
    if block.mode:
        lines.append(f'{item_indent}mode = "{block.mode}",')
    if block.position:
        lines.append(f'{item_indent}position = "{block.position}",')
    if block.scale:
        lines.append(f"{item_indent}scale = {block.scale}")

    lines.append(f"{indent}}})")

    if commented:
        return [comment_line(line) for line in lines]
    return lines


def set_block_commented(block: Block, should_comment: bool) -> list[str]:
    return render_block(block, commented=should_comment, disabled=False)


def set_block_disabled(block: Block, disabled: bool) -> list[str]:
    return render_block(block, commented=False, disabled=disabled)


def apply_mode(lines: list[str], blocks: list[Block], mode: str, state_path: str) -> dict:
    if mode not in {"laptop", "external", "both"}:
        raise RuntimeError(f"Unknown mode: {mode}")

    state = load_state(state_path)
    preferred_laptops, preferred_externals = choose_preferred_blocks(blocks, state)

    desired = set()
    if mode in {"laptop", "both"}:
        desired.update(block.fingerprint for block in preferred_laptops)
    if mode in {"external", "both"}:
        desired.update(block.fingerprint for block in preferred_externals)

    disabled = set()
    if mode == "laptop":
        disabled.update(block.fingerprint for block in preferred_externals)
    elif mode == "external":
        disabled.update(block.fingerprint for block in preferred_laptops)

    new_lines = list(lines)
    for block in reversed(blocks):
        if block.fingerprint in desired:
            rewritten = set_block_disabled(block, False)
        elif block.fingerprint in disabled:
            rewritten = set_block_disabled(block, True)
        else:
            rewritten = set_block_commented(block, True)
        new_lines[block.start : block.end + 1] = rewritten

    return {
        "lines": new_lines,
        "state": {
            "laptop_fingerprints": [block.fingerprint for block in preferred_laptops],
            "external_fingerprints": [block.fingerprint for block in preferred_externals],
            "selected_mode": mode,
        },
    }


def emit_status(blocks: list[Block], message: str | None = None) -> None:
    current_mode = detect_mode(blocks)
    active_outputs = [block.output for block in blocks if not block.commented and not block.disabled and block.output]
    payload = {
        "current_mode": current_mode,
        "current_mode_label": format_mode(current_mode),
        "active_outputs": active_outputs,
        "message": message or "Configuration status updated",
    }
    print(json.dumps(payload, ensure_ascii=False))


def block_to_keyword(block: Block) -> str:
    return f"{block.output},{block.mode},{block.position},{block.scale}"


def apply_live_mode(blocks: list[Block], mode: str, state_path: str) -> None:
    if os.environ.get("SKIP_HYPR_RELOAD") == "1":
        return

    state = load_state(state_path)
    preferred_laptops, preferred_externals = choose_preferred_blocks(blocks, state)

    enable_blocks: list[Block] = []
    disable_blocks: list[Block] = []

    if mode == "laptop":
        enable_blocks.extend(preferred_laptops)
        disable_blocks.extend(preferred_externals)
    elif mode == "external":
        enable_blocks.extend(preferred_externals)
        disable_blocks.extend(preferred_laptops)
    elif mode == "both":
        enable_blocks.extend(preferred_laptops)
        enable_blocks.extend(preferred_externals)
    else:
        raise RuntimeError(f"Unknown mode: {mode}")

    commands: list[str] = []

    # Enable targets first so Hyprland always has a valid output to keep alive.
    for block in enable_blocks:
        commands.append(f"keyword monitor {block_to_keyword(block)}")

    for block in disable_blocks:
        commands.append(f"keyword monitor {block.output},disable")

    if not commands:
        return

    subprocess.run(
        ["hyprctl", "--batch", " ; ".join(commands)],
        check=True,
        capture_output=True,
        text=True,
    )


def main() -> int:
    if len(sys.argv) < 4:
        print(
            "Usage: apply_monitor_mode.py status <config> <state> | apply <mode> <config> <state>",
            file=sys.stderr,
        )
        return 1

    action = sys.argv[1]
    if action == "status":
        config_path = expand_path(sys.argv[2])
        state_path = expand_path(sys.argv[3])
        mode = None
    elif action == "apply" and len(sys.argv) >= 5:
        mode = sys.argv[2]
        config_path = expand_path(sys.argv[3])
        state_path = expand_path(sys.argv[4])
    else:
        print("Invalid arguments", file=sys.stderr)
        return 1

    try:
        with open(config_path, "r", encoding="utf-8") as handle:
            original_lines = handle.read().splitlines()

        blocks = parse_blocks(original_lines)
        if not blocks:
            raise RuntimeError("No hl.monitor({...}) blocks found in monitors.lua")

        if action == "status":
            state = load_state(state_path)
            preferred_laptops, preferred_externals = choose_preferred_blocks(blocks, state)
            save_state(
                state_path,
                {
                    "laptop_fingerprints": [block.fingerprint for block in preferred_laptops],
                    "external_fingerprints": [block.fingerprint for block in preferred_externals],
                    "selected_mode": detect_mode(blocks),
                },
            )
            current_mode = detect_mode(blocks)
            emit_status(blocks, f"Current mode: {format_mode(current_mode)}")
            return 0

        result = apply_mode(original_lines, blocks, mode, state_path)
        new_text = "\n".join(result["lines"]) + "\n"

        with open(config_path, "w", encoding="utf-8") as handle:
            handle.write(new_text)

        save_state(state_path, result["state"])
        apply_live_mode(blocks, mode, state_path)

        updated_blocks = parse_blocks(result["lines"])
        emit_status(updated_blocks, f"Applied mode: {format_mode(mode)}")
        return 0
    except subprocess.CalledProcessError as error:
        stderr = (error.stderr or "").strip()
        print(stderr or "hyprctl reload failed", file=sys.stderr)
        return error.returncode or 1
    except Exception as error:
        print(str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
