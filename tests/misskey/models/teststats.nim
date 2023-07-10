discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/models/stats
import std/[unittest, json]

let testJson = %* {
  "notesCount": 4462324,
  "originalNotesCount": 30,
  "usersCount": 76674,
  "originalUsersCount": 2,
  "reactionsCount": 3048,
  "instances": 3977,
  "driveUsageLocal": 0,
  "driveUsageRemote": 0,
}

let statistics = testJson.toStats()

check statistics.notesCount == 4462324
check statistics.originalNotesCount == 30
check statistics.usersCount == 76674
check statistics.originalUsersCount == 2
check statistics.reactionsCount == 3048
check statistics.instances == 3977
check statistics.driveUsageLocal == 0
check statistics.driveUsageRemote == 0
