#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Tasks for pyinvoke
"""

import sys
from glob import glob
from shutil import which
from invoke import task

class FileNameAmbiguous(Exception):
    """
    Represents an error that a file could not be
    resolved bacause of ambiguity.
    """

    def __init__(self, name, candidates):
        super().__init__()
        self.name = name
        self.candidates = candidates


class FileNotFound(Exception):
    """
    Represents an error that a file could not be
    resolved because it does not exist.
    """

    def __init__(self, name):
        super().__init__()
        self.name = name


def color_red(text):
    """
    Applies terminal control sequence for red color
    """
    result = "\033[31m{}\033[0m".format(text)
    return result


def ensure_prerequisites():
    """
    Ensures all prerequisites are met
    """
    if not which("ansible-playbook"):
        message = (
            "Unknown·command·'ansible-playbook'"
            " - ensure·virtual·environment·is·active"
        )
        print(color_red(message), file=sys.stderr)
        exit(1)


def find_file(directory, name, extension=""):
    """
    Finds a file based on a prefix 'name'
    """
    if directory:
        directory += "/"
    else:
        directory = ""
    if not extension or name.endswith(extension):
        extension = ""
    pattern = "{}{}*{}".format(directory, name, extension)
    candidates = glob(pattern)
    if not candidates:
        raise FileNotFound(name)
    if len(candidates) > 1:
        raise FileNameAmbiguous(name, candidates)
    return candidates[0]


def find_playbook_file(hint):
    """
    Finds a playbook file based on a prefix 'hint'
    """
    return find_file(None, hint, ".yml")


def find_inventory_path(hint):
    """
    Finds a inventory file based on a prefix 'hint'
    """
    return find_file("inventories", hint)


def compose_command(playbook_file, inventory_path, tags, opts):
    """
    Composes a 'ansible-playbook' command for cli execution
    """
    cmd = "ansible-playbook {} -i {}".format(playbook_file, inventory_path)
    if tags:
        cmd += " -t " + tags
    if opts["check"]:
        cmd += " --check"
    if opts["diff"]:
        cmd += " --diff"
    if opts["verbose"]:
        cmd += " -" + opts["verbose"] * "v"
    return cmd


@task(
    help={
        "inventory": "name of the inventory",
        "playbook": "name of the playbook",
        "tags": "(optional) A comma separated list of tags",
        "check": "Perform the play in check-mode",
        "diff": "Show differences",
        "verbose": "Increases the verbosity of the play",
    },
    incrementable=["verbose"],
)
def play(ctx, inventory, playbook, tags=None, check=False, diff=False, verbose=0):
    # pylint: disable=too-many-arguments
    """
    Execute playbook.
    """
    ensure_prerequisites()
    playbook_file = find_playbook_file(playbook)
    inventory_path = find_inventory_path(inventory)
    opts = {"check": check, "diff": diff, "verbose": verbose}
    try:
        cmd = compose_command(playbook_file, inventory_path, tags, opts)
        ctx.run(cmd, pty=True)
    except FileNotFound as err:
        message = "No match for " + err.name
        print(color_red(message), file=sys.stderr)
        exit(2)
    except FileNameAmbiguous as err:
        message = "\n".join(["Ambiguous matches for " + err.name] + err.candidates)
        print(color_red(message), file=sys.stderr)
        exit(3)
