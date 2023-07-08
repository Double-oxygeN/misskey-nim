import ../../../src/misskey/clients
import std/[unittest, json, httpclient, uri]

type MockedHttpClient* = ref object

proc postJson*(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/endpoint"
  if body["endpoint"].getStr == "endpoint":
    result.code = Http200
    result.headers = @[("Content-Type", "application/json")]
    result.body = %* { "params": [ { "name": "endpoint", "type": "String" } ] }

  else:
    result.code = Http204

proc postMultipart*(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard
