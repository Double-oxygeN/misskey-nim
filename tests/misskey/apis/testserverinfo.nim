discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/clients
import ../../../src/misskey/apis/serverinfo
import std/[unittest, json, httpclient, uri]

const
  testMisskeyHost = "https://misskey.example.com"
  testMachineName = "Test Machine"
  testCpuModel = "Test CPU"
  testCpuCores = 2
  testMemoryTotalSizeBytes = 2 * 1_024 * 1_024 * 1_024
  testFileSystemTotalSizeBytes = 50 * 1_024 * 1_024 * 1_024
  testFileSystemUsedSizeBytes = 20 * 1_024 * 1_024 * 1_024

type MockedHttpClient = ref object

proc postJson(client: MockedHttpClient; uri: Uri; body: JsonNode; headers: openArray[HeaderField]): JsonResponse =
  check uri.path == "/api/server-info"
  result.code = Http200
  result.headers = @[("Content-Type", "application/json")]
  result.body = %* {
    "machine": testMachineName,
    "cpu": {
      "model": testCpuModel,
      "cores": testCpuCores
    },
    "mem": {
      "total": newJInt(testMemoryTotalSizeBytes)
    },
    "fs": {
      "total": newJInt(testFileSystemTotalSizeBytes),
      "used": newJInt(testFileSystemUsedSizeBytes)
    }
  }

proc postMultipart(client: MockedHttpClient; uri: Uri; multipart: MultipartData; headers: openArray[HeaderField]): JsonResponse =
  discard


let
  client = newMisskeyClient(testMisskeyHost, new MockedHttpClient)
  svInfo = client.serverInfo()

check svInfo.machine == testMachineName
check svInfo.cpu.model == testCpuModel
check svInfo.cpu.cores == testCpuCores
check svInfo.mem.total == testMemoryTotalSizeBytes
check svInfo.fs.total == testFileSystemTotalSizeBytes
check svInfo.fs.used == testFileSystemUsedSizeBytes
