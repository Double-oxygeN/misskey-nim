discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/getonlineusers
import std/[unittest, json, httpclient, uri]

const
  testMisskeyHost = "https://misskey.example.com"
  testOnlineUsers = 1

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/get-online-users-count"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* { "count": testOnlineUsers }


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  onlineUsers = client.getOnlineUsersCount()

check onlineUsers == testOnlineUsers
