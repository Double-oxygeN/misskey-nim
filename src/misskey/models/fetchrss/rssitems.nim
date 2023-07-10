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

import std/[json, uri, times, options]
import ../macros/parser

let defaultDateTime = dateTime(1970, mJan, 1, zone = utc())

type
  RssItem* = tuple
    title: string
    link: Option[Uri]
    isoDate: Option[DateTime]
    author: Option[string]
    content, contentSnippet: Option[string]
    summary: Option[string]
    categories: seq[string]
    guid: Option[string]


proc toRssItem*(node: JsonNode): RssItem {.genModel(RssItem).} =
  ## Converts a JSON node to an `RssItem` object.
  ## If the published date cannot be parsed, 1970-01-01T00:00:00Z is used as a default.
  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
    DateTime:
      try:
        fieldNode.getStr().parse("uuuu-MM-dd'T'HH:mm:ss'.'fff'Z'", utc())
      except TimeParseError:
        defaultDateTime
