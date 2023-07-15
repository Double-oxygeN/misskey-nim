discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/emoji
import std/[unittest, json, httpclient, uri, options]

const
  testMisskeyHost = "https://misskey.example.com"

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/emoji"
  check body["name"].getStr() == "testemoji1"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* {
    "id": "abcde12345",
    "name": "testemoji1",
    "aliases": ["testalias1", "testalias2"],
    "category": "testcategory1",
    "url": "https://example.com/testemoji1.png",
    "host": nil,
    "license": nil,
    "isSensitive": false,
    "localOnly": true,
    "roleIdsThatCanBeUsedThisEmojiAsReaction": []
  }

proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  emj = client.getEmoji("testemoji1")

check emj.id == "abcde12345"
check emj.name == "testemoji1"
check emj.aliases == @["testalias1", "testalias2"]
check emj.category == "testcategory1"
check emj.url == parseUri"https://example.com/testemoji1.png"
check emj.host.isNone()
check emj.license.isNone()
check not emj.isSensitive
check emj.localOnly
check emj.roleIdsThatCanBeUsedThisEmojiAsReaction == newSeq[string]()
