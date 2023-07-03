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

from std/httpcore import HttpCode
import std/json

type
  MisskeyResponseError* = object of CatchableError
    code*: HttpCode
    id*: string


proc newMisskeyResponseError*(code: HttpCode; body: JsonNode): ref MisskeyResponseError =
  new result
  result.code = code
  result.id = body["id"].getStr()
  result.msg = body["message"].getStr()
