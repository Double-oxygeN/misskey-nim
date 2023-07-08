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

import std/[uri, colors, options, json]
import utils/versions
import meta/[ads, policies, features]
import macros/parser

type
  Meta* = ref object
    maintainerName*: Option[string]
    maintainerEmail*: Option[string]
    version*: SoftwareVersion
    name*: string
    uri*: Uri
    description*: Option[string]
    langs*: seq[string]
    tosUrl*: Option[Uri]
    repositoryUrl*, feedbackUrl*: Uri
    disableRegistration*: bool
    cacheRemoteFiles*: Option[bool]
    emailRequiredForSignup*: bool
    enableHcaptcha*, enableRecaptcha*, enableTurnstile*: bool
    hcaptchaSiteKey*, recaptchaSiteKey*, turnstileSiteKey*: Option[string]
    swPublickey*: Option[string]
    themeColor*: Option[Color]
    mascotImageUrl*: Uri
    bannerUrl*: Option[Uri]
    infoImageUrl*, serverErrorImageUrl*, notFoundImageUrl*: Option[Uri]
    iconUrl*, backgroundImageUrl*, logoImageUrl*: Option[Uri]
    maxNoteTextLength*: Natural
    defaultLightTheme*, defaultDarkTheme*: Option[string]
    ads*: seq[Advertisement]
    requireSetup*: Option[bool]
    enableEmail*: bool
    enableServiceWorker*: bool
    translatorAvailable*: bool
    proxyAccountName*: Option[string]
    serverRules*: seq[string]
    policies*: Policies
    mediaProxy*: Uri
    features*: Option[set[Feature]]


func toMeta*(node: JsonNode): Meta {.genModel(Meta).} =
  ## Converts a JSON node to a `Meta` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
    Color: fieldNode.getStr().parseColor()
    SoftwareVersion: fieldNode.getStr().parseVersion()
    Advertisement: fieldNode.toAdvertisement()
    Policies: fieldNode.toPolicies()
    set[Feature]: fieldNode.toFeatures()
