# Copyright 2023 Double-oxygeN
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## :Author: Double-oxygeN
##
## This module provides a `SoftwareVersion` object that can be used to represent a software version.

from std/strutils import parseInt, split

type
  SoftwareVersion* = object
    major, minor, patch: Natural
    prerelease: string


func `==`*(a, b: SoftwareVersion): bool =
  a.major == b.major and a.minor == b.minor and a.patch == b.patch and a.prerelease == b.prerelease


func version*(major, minor, patch: Natural; prerelease = ""): SoftwareVersion =
  ## Creates a `SoftwareVersion` object.
  result = SoftwareVersion(major: major, minor: minor, patch: patch, prerelease: prerelease)


func parseVersion*(versionStr: string): SoftwareVersion =
  ## Parses a version string into a `SoftwareVersion` object.
  ##
  ## The version string must be in the format `/^\d+\.\d+\.\d+(-.+)?$/`.
  runnableExamples:
    assert parseVersion("13.12.2") == version(13, 12, 2)
    assert parseVersion("13.13.0-beta.7") == version(13, 13, 0, "beta.7")

  let
    splitPreRelease = versionStr.split('-', 1)
    splitVersion = splitPreRelease[0].split('.')

  result.major = splitVersion[0].parseInt().Natural
  result.minor = splitVersion[1].parseInt().Natural
  result.patch = splitVersion[2].parseInt().Natural
  if splitPreRelease.len == 2:
    result.prerelease = splitPreRelease[1]
  else:
    result.prerelease = ""


func `$`*(version: SoftwareVersion): string =
  ## Converts a `SoftwareVersion` object into a string.
  ##
  ## The version string is in the format "major.minor.patch(-prerelease)".
  runnableExamples:
    assert $version(13, 12, 2) == "13.12.2"
    assert $version(13, 13, 0, "beta.7") == "13.13.0-beta.7"

  result = $version.major & "." & $version.minor & "." & $version.patch
  if version.prerelease.len > 0:
    result &= "-" & version.prerelease


# Getters
func major*(version: SoftwareVersion): Natural = version.major
func minor*(version: SoftwareVersion): Natural = version.minor
func patch*(version: SoftwareVersion): Natural = version.patch
func prerelease*(version: SoftwareVersion): string = version.prerelease


# Utils
func `<`*(a, b: SoftwareVersion): bool =
  ## Compares two `SoftwareVersion` objects.
  ##
  ## Returns true if `a` is prior to `b`, false otherwise.
  ## The prerelease part is compared using the lexicographic order.
  ## If a prerelease part is missing, it is considered to be greater than any other prerelease part as it is considered stable.
  runnableExamples:
    assert version(12, 119, 2) < version(13, 0, 0)
    assert version(13, 0, 0) < version(13, 12, 0)
    assert version(13, 12, 0) < version(13, 12, 2)
    assert version(13, 12, 2) < version(13, 13, 0, "beta.1")
    assert version(13, 13, 0, "beta.1") < version(13, 13, 0, "beta.7")
    assert version(13, 13, 0, "beta.7") < version(13, 13, 0)

    assert not (version(13, 0, 0) < version(12, 119, 2))
    assert not (version(13, 12, 0) < version(13, 0, 0))
    assert not (version(13, 12, 2) < version(13, 12, 0))
    assert not (version(13, 12, 2) < version(13, 12, 2))
    assert not (version(13, 13, 0, "beta.1") < version(13, 12, 2))
    assert not (version(13, 13, 0, "beta.7") < version(13, 13, 0, "beta.1"))
    assert not (version(13, 13, 0, "beta.7") < version(13, 13, 0, "beta.7"))
    assert not (version(13, 13, 0) < version(13, 13, 0, "beta.7"))

  result =
    if a.major != b.major:
      a.major < b.major
    elif a.minor != b.minor:
      a.minor < b.minor
    elif a.patch != b.patch:
      a.patch < b.patch
    elif a.prerelease.len == 0:
      false
    elif b.prerelease.len == 0:
      true
    else:
      a.prerelease < b.prerelease


template `<`*(a: string; b: SoftwareVersion): bool = parseVersion(a) < b
template `<`*(a: SoftwareVersion; b: string): bool = a < parseVersion(b)


func `<=`*(a, b: SoftwareVersion): bool =
  ## Compares two `SoftwareVersion` objects.
  ##
  ## Also see `<`.
  runnableExamples:
    assert version(13, 12, 2) <= version(13, 12, 2)
    assert version(13, 12, 2) <= version(13, 13, 0, "beta.1")

  result = a < b or a == b


template `<=`*(a: string; b: SoftwareVersion): bool = parseVersion(a) <= b
template `<=`*(a: SoftwareVersion; b: string): bool = a <= parseVersion(b)


func split*(version: SoftwareVersion): tuple[major, minor, patch: Natural; prerelease: string] =
  ## Splits a `SoftwareVersion` object into its components.
  runnableExamples:
    assert version(13, 12, 2).split() == (13.Natural, 12.Natural, 2.Natural, "")
    assert version(13, 13, 0, "beta.7").split() == (13.Natural, 13.Natural, 0.Natural, "beta.7")

  result = (version.major, version.minor, version.patch, version.prerelease)


func isPreRelease*(version: SoftwareVersion): bool =
  ## Checks if a `SoftwareVersion` object is a prerelease.
  runnableExamples:
    assert not version(13, 12, 2).isPreRelease()
    assert version(13, 13, 0, "beta.7").isPreRelease()

  result = version.prerelease.len > 0


template isStable*(version: SoftwareVersion): bool =
  ## Checks if a `SoftwareVersion` object is stable.
  ## Also see `isPreRelease <#isPreRelease,SoftwareVersion>`_.
  not version.isPreRelease()
