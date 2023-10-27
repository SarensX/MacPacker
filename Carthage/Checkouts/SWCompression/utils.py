#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

def _sprun(cmd: list, *args, **kwargs):
    print("+ " + " ".join(cmd))
    subprocess.run(cmd, check=True, *args, **kwargs)

def _sprun_shell(cmd: str, *args, **kwargs):
    print("+ " + cmd)
    subprocess.run(cmd, check=True, shell=True, *args, **kwargs)

def _ci_before_deploy():
    docs_json_file = open("docs.json", "w")
    _sprun(["sourcekitten", "doc", "--spm", "--module-name", "SWCompression"], stdout=docs_json_file)
    docs_json_file.close()
    _sprun(["jazzy"])

def _ci_install_git_lfs_macos():
    script = """if brew ls --versions "git-lfs" >/dev/null; then
                    HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "git-lfs"
                else
                    HOMEBREW_NO_AUTO_UPDATE=1 brew install "git-lfs"
                fi"""
    _sprun_shell(script)
    _sprun(["git", "lfs", "install"])

def _ci_script_macos():
    _sprun_shell("xcodebuild -version")
    _sprun(["swift", "--version"])
    xcodebuild_command_parts = ["xcodebuild", "-quiet", "-project", "SWCompression.xcodeproj", "-scheme", "SWCompression"]
    destinations_actions = [(["-destination 'platform=OS X'"], ["clean", "test"]),
                    (["-destination 'platform=iOS Simulator,name=iPhone 8'"], ["clean", "test"]),
                    (["-destination 'platform=watchOS Simulator,name=" + os.environ["WATCHOS_SIMULATOR"] + "'"], [os.environ["WATCHOS_ACTIONS"]]),
                    (["-destination 'platform=tvOS Simulator,name=Apple TV'"], ["clean", "test"])]

    for destination, actions in destinations_actions:
        xcodebuild_command = xcodebuild_command_parts + destination + actions
        # If xcodebuild is not run inside shell, then destination parameters are ignored for some reason.
        _sprun_shell(" ".join(xcodebuild_command))

def action_ci(args):
    if args.cmd == "before-deploy":
        _ci_before_deploy()
    elif args.cmd == "install-git-lfs-macos":
        _ci_install_git_lfs_macos()
    elif args.cmd == "script-macos":
        _ci_script_macos()
    else:
        raise Exception("Unknown CI command")

def action_cw(args):
    _sprun(["rm", "-rf", "build/"])
    _sprun(["rm", "-rf", "Carthage/"])
    _sprun(["rm", "-rf", "docs/"])
    _sprun(["rm", "-rf", "Pods/"])
    _sprun(["rm", "-rf", ".build/"])
    _sprun(["rm", "-f", "Cartfile.resolved"])
    _sprun(["rm", "-f", "docs.json"])
    _sprun(["rm", "-f", "Package.resolved"])
    _sprun(["rm", "-f", "SWCompression.framework.zip"])

def action_dbm(args):
    print("=> Downloading BitByteData dependency using Carthage")
    script = ["carthage", "bootstrap", "--no-use-binaries"]
    if args.debug:
        script += ["--configuration", "Debug"]
    if args.xcf:
        script += ["--use-xcframeworks"]
    _sprun(script)

def action_pr(args):
    _sprun(["agvtool", "next-version", "-all"])
    _sprun(["agvtool", "new-marketing-version", args.version])

    f = open("SWCompression.podspec", "r", encoding="utf-8")
    lines = f.readlines()
    f.close()
    f = open("SWCompression.podspec", "w", encoding="utf-8")
    for line in lines:
        if line.startswith("  s.version      = "):
            line = "  s.version      = \"" + args.version + "\"\n"
        f.write(line)
    f.close()

    f = open(".jazzy.yaml", "r", encoding="utf-8")
    lines = f.readlines()
    f.close()
    f = open(".jazzy.yaml", "w", encoding="utf-8")
    for line in lines:
        if line.startswith("module_version: "):
            line = "module_version: " + args.version + "\n"
        elif line.startswith("github_file_prefix: "):
            line = "github_file_prefix: https://github.com/tsolomko/SWCompression/tree/" + args.version + "\n"
        f.write(line)
    f.close()

    f = open("Sources/swcomp/main.swift", "r", encoding="utf-8")
    lines = f.readlines()
    f.close()
    f = open("Sources/swcomp/main.swift", "w", encoding="utf-8")
    for line in lines:
        if line.startswith("let _SWC_VERSION = "):
            line = "let _SWC_VERSION = \"" + args.version + "\"\n"
        f.write(line)
    f.close()

parser = argparse.ArgumentParser(description="A tool with useful commands for developing SWCompression")
subparsers = parser.add_subparsers(title="commands", help="a command to perform", metavar="CMD")

# Parser for 'ci' command.
parser_ci = subparsers.add_parser("ci", help="a subset of commands used by CI",
                                    description="a subset of commands used by CI")
parser_ci.add_argument("cmd", choices=["before-deploy", "install-git-lfs-macos", "script-macos"],
                        help="a command to perform on CI", metavar="CI_CMD")
parser_ci.set_defaults(func=action_ci)

# Parser for 'cleanup-workspace' command.
parser_cw = subparsers.add_parser("cleanup-workspace", help="cleanup workspace",
                            description="cleans workspace from files produced by various build systems")
parser_cw.set_defaults(func=action_cw)

# Parser for 'download-bbd-macos' command.
parser_dbm = subparsers.add_parser("download-bbd-macos", help="download BitByteData",
                            description="downloads BitByteData dependency using Carthage (macOS only)")
parser_dbm.add_argument("--debug", "-d", action="store_true", dest="debug",
                        help="build BitByteData in Debug configuration")
parser_dbm.add_argument("--xcf", action="store_true", dest="xcf",
                        help="build BitByteData as a XCFramework")
parser_dbm.set_defaults(func=action_dbm)

# Parser for 'prepare-release' command.
parser_pr = subparsers.add_parser("prepare-release", help="prepare next release",
                                description="prepare next release of SWCompression")
parser_pr.add_argument("version", metavar="VERSION", help="next version number")
parser_pr.set_defaults(func=action_pr)

args = parser.parse_args()
args.func(args)
