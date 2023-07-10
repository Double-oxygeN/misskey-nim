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

import std/[json, httpcore]
import ../clients
import ../models/utils/invitationcodes
import errors

proc invite*[T](client: MisskeyClient[T]): InvitationCode =
  ## Generates an invitation code.
  ## This API requires an access token.
  let response = client.request("invite", newJObject())

  if response.code == Http200:
    result = response.body["code"].getStr().toInvitationCode()

  else:
    raise newMisskeyResponseError(response.code, response.body)


when isMainModule:
  let client = newMisskeyClient("http://localhost:28080")

  client.putAccessToken("y8zDaaEUtDCZV2vvNvOYpTQl5zOkQ7Rd")
  echo client.invite()
