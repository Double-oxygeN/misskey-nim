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
import macros/parser

type
  EmojiSimple* = ref object of RootObj
    aliases*: seq[string]
    name*: string
    category*: string
    url*: Uri

  EmojiDetailed* = ref object of EmojiSimple
    id*: string
    host*: Option[string]
    license*: Option[string]
    isSensitive*: bool
    localOnly*: bool
    roleIdsThatCanBeUsedThisEmojiAsReaction*: seq[string]


func toEmojiSimple*(node: JsonNode): EmojiSimple {.genModel(EmojiSimple).} =
  ## Converts a JSON node to an `EmojiSimple` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()


func toEmojiDetailed*(node: JsonNode): EmojiDetailed {.genModel(EmojiDetailed).} =
  ## Converts a JSON node to an `EmojiDetailed` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
