#!/usr/bin/env python

import subprocess
import json
import sys
from pathlib import Path
from typing import Any
from time import sleep

def get_programs() -> list[list[str]]:
    workspaces: subprocess.CompletedProcess = subprocess.run(
        ["hyprctl", "clients", "-j"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="iso-8859-1"
    )

    result: str = workspaces.stdout
    err: str = workspaces.stderr

    if err != "":
        print(
            "Error: Could not retrieve workspace information using hyprctl",
            file=sys.stderr,
        )
        quit(1)

    hyprctl_clients: list[dict[str, Any]] = json.loads(result)

    workspace_progs: list[list[str]] = [[] for _ in range(10)]

    for client in hyprctl_clients:
        if any(program in client["class"] for program in ["ghostty", "kitty"]) and "nvim" in client["title"]:
            program = "nvim"
        elif any(program in client["class"] for program in ["ghostty", "kitty"]) and any(string in client["title"] for string in ["lg", "lazygit"]):
            program = "lazygit"
        elif any(program in client["class"] for program in ["ghostty", "kitty"]) and "yazi" in client["title"].lower():
            program = "yazi"
        elif any(program in client["class"] for program in ["ghostty", "kitty"]) and "tmux" in client["title"].lower():
            program = "tmux"
        elif "ghostty" in client["class"]:
            program = "ghostty"
        elif "libreoffice" in client["class"]:
            program = "libreoffice"
        elif "ONLYOFFICE" in client["class"]:
            program = "onlyoffice"
        elif "xournalpp" in client["class"]:
            program = "xournal++"
        elif "onenote" in client["class"]:
            program = "onenote"
        elif "dolphin" in client["class"]:
            program = "dolphin"
        else:
            program = client["class"]

        workspace_progs[int(client["workspace"]["id"]) - 1].append(program)

    return workspace_progs


def get_names(workspace_programs: list[list[str]]) -> list[str]:
    icon_file: Path = Path(__file__).resolve().parent.parent / "icons.json"
    with icon_file.open("r") as fp:
        icons: dict[str, Any] = json.load(fp)

    empty: str = icons["default"]["empty"]
    undefined_programs: str = icons["default"]["undefined-apps"]

    names: list[str] = ["" for _ in range(10)]

    for i, workspace in enumerate(workspace_programs):
        if workspace == []:
            names[i] = f"{i + 1}:{empty}"
        else:
            defined_program_found: bool = False
            for defined_program in icons["programs"]:
                if defined_program["name"] in map(str.lower, workspace):
                    names[i] = f"{i + 1}:{defined_program['icon']}"
                    defined_program_found = True
                    break
            if not defined_program_found:
                names[i] = f"{i + 1}:{undefined_programs}"

    return names


def get_tooltips(workspace_programs: list[list[str]]) -> list[str]:
    workspace_tooltips: list[str] = ["" for _ in range(10)]
    for i, workspace in enumerate(workspace_programs):
        workspace_tooltips[i] = "\\r".join(workspace)
    return workspace_tooltips


def is_active_workspace(workspace_id: int) -> bool:
    active_workspace: subprocess.CompletedProcess = subprocess.run(
        ["hyprctl", "activeworkspace", "-j"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        errors="replace"
    )

    result: str = active_workspace.stdout
    err: str = active_workspace.stderr

    if err != "":
        print(
            "Error: Could not retrieve workspace information using hyprctl",
            file=sys.stderr,
        )
        quit(1)

    return int(json.loads(result)["id"]) == workspace_id


def main():
    while True:
        programs: list[list[str]] = get_programs()
        return_str: str = ""
    
        for workspace_nr in range(1, 11):
            text: str = get_names(programs)[workspace_nr - 1]
            tooltip: str = get_tooltips(programs)[workspace_nr - 1]
            css_class: list[str] = ["nr" + str(workspace_nr)]
            if is_active_workspace(workspace_nr):
                css_class.append("active")
    
            # return_dict: dict[str, Any] = {"name": name, "tooltip": tooltip, "class": css_class}
            return_str += str(
                '{"text":"'
                + text
                + '","tooltip":"'
                + tooltip
                + '","class":'
                + str(css_class).replace("'", '"')
                + "}\n"
            )
    
        with open("/tmp/hyprland_workspaces.txt", "w") as outfile:
            outfile.write(return_str)

        sleep(1)

if __name__ == "__main__":
    main()
