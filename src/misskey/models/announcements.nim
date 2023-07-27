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

import std/[json, options, times, uri]
import macros/parser

type
  Announcement* = ref object
    id: string
    createdAt: DateTime
    updatedAt: Option[DateTime]
    text, title: string
    imageUrl: Option[Uri]
    isRead: Option[bool]


proc toAnnouncement*(node: JsonNode): Announcement {.genModel(Announcement).} =
  ## Converts a JSON node to an `Announcement` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
    DateTime: fieldNode.getStr().parse("uuuu-MM-dd'T'HH:mm:ss'.'fff'Z'")
