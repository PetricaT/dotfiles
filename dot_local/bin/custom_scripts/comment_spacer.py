#!/usr/bin/env python
#
# -- Simple util to normalize comments in .zshrc
#   because I like it more that way :)
#
from pathlib import Path
import os
import regex

# comment: str = "# ─"
comment = regex.compile(r"#\s[\─\-]{1,40}\s{1,}[a-zA-z\s]{1,}[\─\-]{0,40}\n")

# rename the original file to .zshrc.bak
if os.path.exists(Path.home() / ".zshrc.bak"):
    os.remove(Path.home() / ".zshrc.bak")
    os.rename(Path.home() / ".zshrc", Path.home() / ".zshrc.bak")
else:
    os.rename(Path.home() / ".zshrc", Path.home() / ".zshrc.bak")

with open(Path.home() / ".zshrc.bak", "r") as source:
    with open(Path.home() / ".zshrc", "w") as dest:
        for line in source:
            if comment.match(line):
                line: str = line.replace("#", "").replace("-", "").replace("─", "").strip()
                line: str = f" {line} "
                dest.write(f"# {line:─^78}")
            else:
                dest.write(line)

# Cleanup
os.remove(Path.home() / ".zshrc.bak")