discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/announcements
import std/[unittest, json, httpclient, uri, options, times]

const testMisskeyHost = "https://misskey.example.com"

type
  MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/announcements"
  check body["limit"].getInt() == 10
  check not body["withUnreads"].getBool()
  check not body.hasKey("sinceId")
  check not body.hasKey("untilId")
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* [
    {
      "id": "abcde12345",
      "createdAt": "2038-01-19T03:14:08.012Z",
      "updatedAt": nil,
      "text": "Test announcement",
      "title": "Test title",
      "imageUrl": "https://example.com/announcement.png"
    }
  ]


proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  announcemts = client.announcements()

check announcemts.len == 1
check announcemts[0].id == "abcde12345"
check announcemts[0].createdAt == dateTime(2038, mJan, 19, 3, 14, 8, 12_000_000, zone = utc())
check announcemts[0].updatedAt.isNone()
check announcemts[0].text == "Test announcement"
check announcemts[0].title == "Test title"
check announcemts[0].imageUrl == some(parseUri"https://example.com/announcement.png")
check announcemts[0].isRead.isNone()
