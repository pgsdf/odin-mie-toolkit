
#!/usr/bin/env python3
import os, re, sys, io
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SRC_DIRS = [REPO / "mie", REPO / "examples", REPO / "tests"]
OUT = REPO / "docs" / "api.md"

def extract_blocks(text):
    lines = text.splitlines()
    i = 0
    blocks = []
    while i < len(lines):
        if lines[i].lstrip().startswith("///"):
            # accumulate contiguous /// lines
            doc = []
            while i < len(lines) and lines[i].lstrip().startswith("///"):
                doc.append(lines[i].lstrip()[3:].lstrip())
                i += 1
            # find next non-empty, non-comment signature line (up to 3 lines lookahead)
            sig = ""
            j = i
            while j < len(lines) and (lines[j].strip() == "" or lines[j].lstrip().startswith("//")):
                j += 1
            if j < len(lines):
                sig = lines[j].strip()
            blocks.append(("".join([d + "\n" for d in doc]).strip(), sig))
        else:
            i += 1
    return blocks

def main():
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("# API Reference\n\n")
        for src_dir in SRC_DIRS:
            if not src_dir.exists(): 
                continue
            f.write(f"## {src_dir.name}\n\n")
            for path in sorted(src_dir.glob("*.odin")):
                text = path.read_text(encoding="utf-8", errors="ignore")
                blocks = extract_blocks(text)
                if not blocks:
                    continue
                f.write(f"### `{path.relative_to(REPO)}`\n\n")
                for doc, sig in blocks:
                    if sig:
                        f.write("```odin\n" + sig + "\n```\n\n")
                    f.write(doc + "\n\n")
        print(f"Wrote {OUT}")
if __name__ == '__main__':
    main()
