import logging
import os
import sqlite3
import subprocess
import sys
import sysconfig
from argparse import ArgumentParser
from contextlib import closing, contextmanager
from functools import cache
from pathlib import Path
from typing import Any, Literal, final, overload, override

import requests

import __main__

HOME = Path.home()
BINPATH = Path(
    sysconfig.get_path(
        "scripts", scheme="nt_user" if sys.platform == "win32" else "posix_user"
    )
)


# logger
@final
class ColoredFormatter(logging.Formatter):
    COLORS = {
        "DEBUG": "\033[96m",
        "INFO": "\033[92m",
        "WARNING": "\033[93m",
        "ERROR": "\033[91m",
        "CRITICAL": "\033[1;41m",
    }

    def __init__(self):
        super().__init__("%(levelname)s %(message)s")

    @override
    def format(self, record: logging.LogRecord):
        levelname = record.levelname
        record.levelname = f"{self.COLORS.get(levelname, '')}{levelname}\033[0m"
        result = super().format(record)
        record.levelname = levelname
        return result


handler = logging.StreamHandler()
handler.setFormatter(ColoredFormatter())
log = logging.Logger("myscript", "INFO")
log.addHandler(handler)


# http
class Client(requests.Session):
    @override
    def request(self, method: str, url: str, *args: Any, **kwargs: Any):
        log.debug(f"Fetch: {method} {url}")
        return super().request(method, url, *args, **kwargs)


# functions
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


@contextmanager
def sqlite(dbpath: str | Path):
    with closing(sqlite3.connect(dbpath)) as con:
        with con:
            yield con


# cli arguments
def arg(*name_or_flags: str, **config: Any) -> Any:
    config["name_or_flags"] = name_or_flags
    return config


@final
class cli:
    class args:
        verbose: bool = arg("-v", help="debug mode")
        edit: bool = arg("-e", help="edit self")

    def __init__(self, description: str, **config: Any):
        config["description"] = description
        self.parser = ArgumentParser(**config)

    def add_argument(self, name: str, typ: type, config: dict[str, Any]):
        name_or_flags: tuple[str, ...] = config.pop("name_or_flags", ())

        if typ is bool:
            config.setdefault("action", "store_true")
        else:
            config.setdefault("type", typ)

        if not (
            len(name_or_flags) > 0 and name_or_flags[0].startswith("-")
        ):  # postional
            config.setdefault("dest", name)

        _ = self.parser.add_argument(f"--{name}", *name_or_flags, **config)

    def add_arguments(self, cls: type):
        for name, typ in cls.__annotations__.items():
            self.add_argument(name, typ, getattr(cls, name, None) or {})

    def __call__[T](self, cls: type[T]) -> T:
        self.add_arguments(self.args)
        self.add_arguments(cls)

        opts = self.parser.parse_args()
        if opts.verbose:
            log.setLevel("DEBUG")
        if opts.edit:
            cmd(f"{editor()} {__main__.__file__}")

        log.debug(opts)
        return opts  # pyright: ignore[reportReturnType]
