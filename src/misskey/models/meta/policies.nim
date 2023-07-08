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

import std/json
import ../macros/parser

type
  Policies* = tuple
    gtlAvailable, ltlAvailable: bool
    canPublicNote, canInvite, canManageCustomEmojis, canSearchNotes, canHideAds: bool
    driveCapacityMb: float
    alwaysMarkNsfw: bool
    pinLimit, antennaLimit, wordMuteLimit, webhookLimit, clipLimit, noteEachClipsLimit, userListLimit, userEachUserListsLimit: Natural
    rateLimitFactor: float


func toPolicies*(node: JsonNode): Policies {.genModel(Policies).} =
  ## Converts a JSON node to a `Policies` object.
