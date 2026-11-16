"""Build the manual-install Nexus archive from an explicit file list."""
import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION = "0.3.0"
MOD = ROOT / "NeutralHumansDemo"
SCRIPTS = MOD / "Scripts"


def main():
    targets = re.findall(
        r'\["blueprintgeneratedclass /game/([^"\n]+)"\]\s*=\s*true',
        (SCRIPTS / "targets.lua").read_text(encoding="utf-8"),
    )
    assert len(targets) == len(set(targets)) == 53
    assert "enabled = true" in (SCRIPTS / "config.lua").read_text(encoding="utf-8")
    for source in (SCRIPTS / "main.lua", SCRIPTS / "runtime.lua"):
        code = source.read_text(encoding="utf-8")
        assert "RegisterKeyBind" not in code and "ModifierKey" not in code
        assert "UpdateGlobalTeamInfo(" not in code

    report = ROOT / "docs/TECHNICAL_REPORT_zh-CN.md"
    marker = "<!-- GENERATED_TARGETS -->"
    text = report.read_text(encoding="utf-8").split(marker)[0].rstrip()
    table = "\n\n" + marker + "\n\n| 序号 | 类路径 |\n| --- | --- |\n"
    table += "".join(f"| {i} | `{name}` |\n" for i, name in enumerate(targets, 1))
    report.write_text(text + table, encoding="utf-8")

    contents = {
        MOD / "enabled.txt": "ue4ss/Mods/NeutralHumansDemo/enabled.txt",
        ROOT / "docs/INSTALL_zh-CN.md": "README_NeutralHumans_CN.md",
        ROOT / "docs/INSTALL_EN.md": "README_NeutralHumans_EN.md",
        ROOT / "CHANGELOG.md": "CHANGELOG_NeutralHumans.md",
        report: "docs/NeutralHumans_TECHNICAL_REPORT_CN.md",
        ROOT / "docs/UE4SS_DEPENDENCY.md": "docs/UE4SS_DEPENDENCY.md",
        ROOT / "LICENSE": "LICENSE_NeutralMingSoldiers.txt",
    }
    for name in ("main.lua", "config.lua", "runtime.lua", "targets.lua"):
        contents[SCRIPTS / name] = "ue4ss/Mods/NeutralHumansDemo/Scripts/" + name

    output = ROOT / "dist" / f"Neutral-Ming-Soldiers-{VERSION}.zip"
    output.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for source, name in sorted(contents.items(), key=lambda item: item[1]):
            archive.write(source, name)
    with zipfile.ZipFile(output) as archive:
        assert set(archive.namelist()) == set(contents.values())
        for source, name in contents.items():
            assert archive.read(name) == source.read_bytes(), name
    print(f"Built {output.name}: {len(contents)} files, {output.stat().st_size} bytes")
    print("PASS: 53 unique targets, config defaults on, no keybinds/native team writes, archive contents match")


if __name__ == "__main__":
    main()
