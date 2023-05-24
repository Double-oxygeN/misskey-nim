# Package

version       = "0.1.0"
author        = "Double-oxygeN"
description   = "Misskey SDK"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.12"


# Helpers

from os import splitFile

iterator filesRecursive(rootDir: string): string =
  var dirs = if dirExists(rootDir): @[rootDir] else: @[]
  while dirs.len > 0:
    let dir = dirs.pop()

    for file in listFiles(dir):
      yield file

    dirs.add listDirs(dir)

# Tasks

task test, "Executes tests w/testament.":
  exec "testament category /"

task cleanup, "Clean up intermediate files.":
  rmDir "nimcache"
  rmDir "testresults"
  # exec "find tests/misskey -type f -not -name '*.nim' -delete"
  for filename in filesRecursive("tests/misskey"):
    if splitFile(filename).ext != ".nim":
      rmFile filename
