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

import std/[macros, macrocache]

type
  ParseTable* = ref object
    cacheTbl: CacheTable
    fieldNodeIdent: NimNode


const parseTablePrefix = "pt$"


proc newEmptyParseTable*(modelName: string): ParseTable =
  result = ParseTable(cacheTbl: CacheTable(parseTablePrefix & modelName))


proc newParseTableFromCall*(call: NimNode; modelName: string): ParseTable =
  call.expectKind({nnkCall, nnkCommand})
  call.expectLen(3)

  result = ParseTable(cacheTbl: CacheTable(parseTablePrefix & modelName), fieldNodeIdent: call[1])

  for caseBlock in call[2]:
    caseBlock.expectKind(nnkCall)
    caseBlock.expectLen(2)
    caseBlock[0].expectKind({nnkIdent, nnkBracketExpr})
    caseBlock[1].expectKind(nnkStmtList)

    if caseBlock[0].kind == nnkIdent:
      result.cacheTbl[caseBlock[0].strVal] = caseBlock[1]

    else:
      caseBlock[0].expectLen(2)
      caseBlock[0][0].expectKind(nnkIdent)
      caseBlock[0][1].expectKind(nnkIdent)

      result.cacheTbl[caseBlock[0][0].strVal & '[' & caseBlock[0][1].strVal & ']'] = caseBlock[1]


func hasKey*(table: ParseTable; key: string): bool {.compileTime.} =
  result = false
  for keyTbl, _ in table.cacheTbl:
    if keyTbl == key:
      result = true
      break


func `[]`*(table: ParseTable; key: string): NimNode {.compileTime.} =
  result = table.cacheTbl[key]


func fieldNodeIdent*(table: ParseTable): NimNode {.compileTime.} =
  result = table.fieldNodeIdent
