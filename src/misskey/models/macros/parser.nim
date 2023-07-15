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

import std/[macros, json, options]
import parsetables
from sequtils import map

export sequtils.map

func getObjImpl(ty: NimNode): NimNode =
  result = ty.getImpl()[2]
  if typeKind(result) == ntyRef:
    result = result[0]


func replaceIdent(node, src, dest: NimNode): NimNode =
  if node.kind == nnkIdent and node.eqIdent(src):
    result = dest.copyNimTree()

  else:
    result = node.copyNimNode()
    for idx, child in node:
      result.add child.replaceIdent(src, dest)


proc exprParseFromJson(typeNode, jsonNodeExpr: NimNode; parseTable: ParseTable): NimNode =
  typeNode.expectKind({ nnkBracketExpr, nnkSym })

  if typeNode.kind == nnkBracketExpr:
    # seq[T], set[T], Option[T]
    let innerType = typeNode[1]

    case typeNode[0].strVal
    of "Option":
      let innerExpr = exprParseFromJson(typeNode[1], jsonNodeExpr, parseTable)

      result = quote do:
        if `jsonNodeExpr`.kind == JNull:
          none(`innerType`)
        else:
          some(`innerExpr`)

    of "seq":
      let
        it = genSym(nskParam)
        mappedExpr = exprParseFromJson(typeNode[1], it, parseTable)

      result = quote do:
        `jsonNodeExpr`.getElems().map do (`it`: Jsonnode) -> `innerType`:
          `mappedExpr`

    elif parseTable.hasKey(typeNode[0].strVal & '[' & typeNode[1].strVal & ']'):
      result = parseTable[typeNode[0].strVal & '[' & typeNode[1].strVal & ']'].replaceIdent(parseTable.fieldNodeIdent, jsonNodeExpr)

    else:
      warning("Unsupported type.", typeNode)

  else:
    case typeNode.strVal
    of "int", "Natural", "Positive":
      result = quote do: `jsonNodeExpr`.getInt()

    of "float":
      result = quote do: `jsonNodeExpr`.getFloat()

    of "string":
      result = quote do: `jsonNodeExpr`.getStr()

    of "bool":
      result = quote do: `jsonNodeExpr`.getBool()

    elif parseTable.hasKey(typeNode.strVal):
      result = parseTable[typeNode.strVal].replaceIdent(parseTable.fieldNodeIdent, jsonNodeExpr)

    else:
      warning("Unsupported type.", typeNode)


iterator impls(modelImpl: NimNode): NimNode =
  var cursor = modelImpl
  if modelImpl.kind == nnkObjectTy:
    yield cursor

    while cursor[1].kind != nnkEmpty:
      cursor = cursor[1][0].getObjImpl()
      yield cursor

  else:
    yield cursor


iterator fields(modelImpl: NimNode): tuple[fieldNameIdent, typeNode: NimNode] =
  for impl in impls(modelImpl):
    let fieldDefs = if impl.kind == nnkObjectTy: impl[2] else: impl

    for fieldDef in fieldDefs:
      for field in fieldDef[0..^3]:
        let fieldNameIdent = if field.kind == nnkPostfix: ident($field[1]) else: ident($field)
        yield (fieldNameIdent: fieldNameIdent, typeNode: fieldDef[^2])


macro genModel*(modelType: typedesc; procDecl: untyped): untyped =
  # Validate the procedure.
  procDecl.expectKind({nnkProcDef, nnkFuncDef})
  if procDecl[3].len != 2 or not procDecl[3][1][1].eqIdent("JsonNode"):
    warning("The proc must have exactly one argument of type JsonNode.", procDecl[3])

  let
    jsonNodeArgIdent = procDecl[3][1][0]
    modelImpl = modelType.getObjImpl()

  if modelImpl.kind notin [nnkTupleTy, nnkObjectTy]:
    warning("The result must be either an object or a tuple.", procDecl[3][0])

  if not modelType.strVal.eqIdent(procDecl[3][0]):
    warning("The result type must be exactly the same as the model type.", procDecl[3][0])

  # Initialize result.
  result = procDecl

  # Extract parseTable if present.
  var parseTableIdx = -1
  for idx, stmtItem in result[6]:
    if stmtItem.kind in [nnkCall, nnkCommand] and stmtItem[0].eqIdent("parseTable"):
      parseTableIdx = idx
      break

  let parseTable =
    if parseTableIdx >= 0:
      let parseTableCall = result[6][parseTableIdx]
      result[6].del parseTableIdx
      parseTableCall.newParseTableFromCall(modelType.strVal)

    else:
      newEmptyParseTable(modelType.strVal)

  # Append JSON parsing code.
  for fieldNameIdent, typeNode in fields(modelImpl):
    let
      fieldNameStr = ($fieldNameIdent).newStrLitNode()
      jsonNodeExpr = quote do: `jsonNodeArgIdent`[`fieldNameStr`]
      parseFromJsonExpr = exprParseFromJson(typeNode, jsonNodeExpr, parseTable)

    result[6].add quote do:
      if `jsonNodeArgIdent`.hasKey(`fieldNameStr`):
        result.`fieldNameIdent` = `parseFromJsonExpr`
