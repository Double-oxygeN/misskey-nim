discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../../src/misskey/models/meta/policies
import std/[unittest, json]

let testJson = parseJson"""{"gtlAvailable":true,"ltlAvailable":true,"canPublicNote":true,"canInvite":false,"canManageCustomEmojis":false,"canSearchNotes":true,"canHideAds":false,"driveCapacityMb":100,"alwaysMarkNsfw":false,"pinLimit":5,"antennaLimit":5,"wordMuteLimit":200,"webhookLimit":3,"clipLimit":10,"noteEachClipsLimit":200,"userListLimit":10,"userEachUserListsLimit":50,"rateLimitFactor":1}"""

let plcs = testJson.toPolicies()

check plcs.gtlAvailable
check plcs.ltlAvailable
check plcs.canPublicNote
check not plcs.canInvite
check not plcs.canManageCustomEmojis
check plcs.canSearchNotes
check not plcs.canHideAds
check plcs.driveCapacityMb == 100.0
check not plcs.alwaysMarkNsfw
check plcs.pinLimit == 5
check plcs.antennaLimit == 5
check plcs.wordMuteLimit == 200
check plcs.webhookLimit == 3
check plcs.clipLimit == 10
check plcs.noteEachClipsLimit == 200
check plcs.userListLimit == 10
check plcs.userEachUserListsLimit == 50
check plcs.rateLimitFactor == 1.0
