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

import std/[json, uri, options]
import fetchrss/rssitems
import macros/parser

type
  FetchRssResult* = ref object
    ## The result of a fetchRss call.
    ## The API accepts Atom, RSS 1.0, and RSS 2.0 feeds.
    title*: string
    link*: Uri
    description*: Option[string]
    language*: Option[string]
    copyright*: Option[string]
    lastBuildDate*: Option[string]
    items*: seq[RssItem]


proc toFetchRssResult*(node: JsonNode): FetchRssResult {.genModel(FetchRssResult).} =
  ## Converts a JSON node to a `FetchRssResult` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
    RssItem: fieldNode.toRssItem()
