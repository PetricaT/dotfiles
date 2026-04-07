from pathlib import Path
import regex

# comment: str = "# ─"
comment = regex.compile(r"#\s\─{1,40}\s[a-zA-z\s]{1,}\─{0,40}\n")

with open(Path.home() / ".zshrc.bak", "r+") as f:
    for line in f:
        if comment.match(line):
            print(line)

# for comment in comments:
#     max_length = 80
#     max_length -= len(comment) + 4 # Account for "# " and 2 spacers

#     comment = f" {comment} "
#     print(f"# {comment:─^78}")