discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/emojis
import std/[unittest, json, httpclient, uri]

const
  testMisskeyHost = "https://misskey.example.com"

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/emojis"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* {
    "emojis": [
      {
        "name": "testemoji1",
        "aliases": ["testalias1", "testalias2"],
        "category": "testcategory1",
        "url": "https://example.com/testemoji1.png"
      },
      {
        "name": "testemoji2",
        "aliases": [],
        "category": "",
        "url": "https://example.com/testemoji2.png"
      }
    ]
  }

proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  emjs = client.emojis()

check emjs.len == 2
check emjs[0].name == "testemoji1"
check emjs[0].aliases == @["testalias1", "testalias2"]
check emjs[0].category == "testcategory1"
check emjs[0].url == parseUri"https://example.com/testemoji1.png"
check emjs[1].name == "testemoji2"
check emjs[1].aliases == newSeq[string]()
check emjs[1].category == ""
check emjs[1].url == parseUri"https://example.com/testemoji2.png"
