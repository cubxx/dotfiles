import argparse
import inspect
import json
import logging
import os
import subprocess
import sys
import tempfile
import urllib
import urllib.request
from contextlib import contextmanager
from functools import cache
from pathlib import Path
from typing import Any, Callable, Literal, overload

import __main__

BINPATH = Path.home() / ".local/bin"
TMPPATH = Path(tempfile.gettempdir())
LEVEL_COLORS = {
    "DEBUG": "\033[96m",
    "INFO": "\033[92m",
    "WARNING": "\033[93m",
    "ERROR": "\033[91m",
    "CRITICAL": "\033[1;41m",
}


class ColoredFormatter(logging.Formatter):
    def __init__(self):
        super().__init__("%(levelname)s %(message)s")

    def format(self, record: logging.LogRecord):
        levelname = record.levelname
        record.levelname = f"{LEVEL_COLORS.get(levelname, '')}{levelname}\033[0m"
        result = super().format(record)
        record.levelname = levelname
        return result


handler = logging.StreamHandler()
handler.setFormatter(ColoredFormatter())
log = logging.Logger("myscript", "INFO")
log.addHandler(handler)


@cache
def editor():
    editor = os.getenv("EDITOR") or os.getenv("VISUAL")
    if not editor:
        raise ValueError("EDITOR or VISUAL environment variable is not set")
    return editor


@overload
def cmd(command: str, stdout: Literal["capture"]) -> str: ...
@overload
def cmd(command: str, stdout: Literal["sys"] = "sys") -> None: ...
def cmd(command: str, stdout: str = "sys"):
    log.debug(f"command: {command}")
    capture_output = stdout == "capture"
    p = subprocess.run(
        command,
        capture_output=capture_output,
        shell=True,
        text=True,
        check=True,
        stdout=None if capture_output else sys.stdout,
        stderr=None if capture_output else sys.stderr,
    )
    return p.stdout if capture_output else None


def confirm(prompt: str, default: bool = True):
    choice = "[Y/n]" if default else "[y/N]"
    response = input(f"{prompt} {choice}: ").strip()
    return response == "y" if response else default


def fetch(url: str, payload: Any | None = None):
    log.debug(f"fetch {url}")
    with urllib.request.urlopen(url, payload) as res:
        data = json.loads(res.read().decode())
    return data


type Handler[T = Any] = Callable[[T], None]


@contextmanager
def cli(description: str, **conf: Any):
    parser = argparse.ArgumentParser(description=description, **conf)
    handlers: dict[str, Handler] = {}

    def arg(*flags: str, **conf: Any):
        def warpper[T](fn: Handler[T]) -> Handler[T]:
            arg_key = fn.__name__.strip("_")
            arg_name = arg_key.replace("_", "-")
            if len(flags):
                if (
                    not conf.get("action", "").startswith("store_")
                    and "choices" not in conf
                ):
                    conf["metavar"] = next(iter(inspect.signature(fn).parameters))
                parser.add_argument(f"--{arg_name}", *flags, **conf)  # option
            else:
                parser.add_argument(arg_name, **conf)  # positional
            handlers[arg_key] = fn
            return fn

        return warpper

    # add argument
    @arg("-v", action="store_true", help="debug mode")
    def verbose(val: object):  # type: ignore
        if val is True:
            log.setLevel("DEBUG")

    @arg("-e", action="store_true", help="open editor to edit itself")
    def edit(val: object):  # type: ignore
        if val is True:
            cmd(f"{editor()} {__main__.__file__}")

    yield arg

    # run
    args = parser.parse_args()
    for name, handler in handlers.items():
        val = getattr(args, name)
        if val is not None:
            handler(val)
    log.debug(args)
