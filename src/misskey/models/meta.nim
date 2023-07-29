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
from std/strutils import parseEnum
import utils/versions
import meta/[ads, policies, features]
import macros/parser

type
  MetaCommon* = ref object of RootObj
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
    defaultLightTheme*, defaultDarkTheme*: Option[string]
    enableEmail*: bool
    enableServiceWorker*: bool
    translatorAvailable*: bool
    policies*: Policies

  Meta* = ref object of MetaCommon
    maxNoteTextLength*: Natural
    ads*: seq[Advertisement]
    requireSetup*: Option[bool]
    proxyAccountName*: Option[string]
    serverRules*: seq[string]
    mediaProxy*: Uri
    features*: Option[set[Feature]]

  SensitiveMediaDetectionMode* {.pure.} = enum
    none, all, local, remote

  SensitiveMediaDetectionSensitivity* {.pure.} = enum
    veryLow  = -2
    low      = -1
    medium   = 0
    high     = 1
    veryHigh = 2

  MetaAdmin* = ref object of MetaCommon
    pinnedUsers*: Option[seq[string]]
    hiddenTags*: Option[seq[string]]
    blockedHosts*: Option[seq[string]]
    sensitiveWords*: Option[seq[string]]
    preservedUsernames*: seq[string]
    hcaptchaSecretKey*, recaptchaSecretKey*, turnstileSecretKey*: Option[string]
    sensitiveMediaDetection*: Option[SensitiveMediaDetectionMode]
    sensitiveMediaDetectionSensitivity*: Option[SensitiveMediaDetectionSensitivity]
    setSensitiveFlagAutomatically*: Option[bool]
    enableSensitiveMediaDetectionForVideos*: Option[bool]
    proxyAccountId*: Option[string]
    summalyProxy*: Option[Uri]
    email*: Option[string]
    smtpSecure*: Option[bool]
    smtpHost*: Option[string]
    smtpPort*: Option[int]
    smtpUser*: Option[string]
    smtpPass*: Option[string]
    swPrivatekey*: Option[string]
    useObjectStorage*: Option[bool]
    objectStorageBaseUrl*: Option[Uri]
    objectStorageBucket*: Option[string]
    objectStoragePrefix*: Option[string]
    objectStorageEndpoint*: Option[string]
    objectStorageRegion*: Option[string]
    objectStoragePort*: Option[int]
    objectStorageAccessKey*: Option[string]
    objectStorageSecretKey*: Option[string]
    objectStorageUseSSL*: Option[bool]
    objectStorageUseProxy*: Option[bool]
    objectStorageSetPublicRead*: Option[bool]
    objectStorageS3ForcePathStyle*: Option[bool]
    deeplAuthKey*: Option[string]
    deeplIsPro*: Option[bool]
    enableIpLogging*: Option[bool]
    enableActiveEmailValidation*: Option[bool]
    enableChartsForRemoteUser*: bool
    enableChartsForFederatedInstances*: bool


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


func toMetaAdmin*(node: JsonNode): MetaAdmin {.genModel(MetaAdmin).} =
  ## Converts a JSON node to a `MetaAdmin` object.
  new result

  parseTable(fieldNode):
    Uri: fieldNode.getStr().parseUri()
    Color: fieldNode.getStr().parseColor()
    SoftwareVersion: fieldNode.getStr().parseVersion()
    Policies: fieldNode.toPolicies()
    set[Feature]: fieldNode.toFeatures()
    SensitiveMediaDetectionMode: parseEnum[SensitiveMediaDetectionMode](fieldNode.getStr())
    SensitiveMediaDetectionSensitivity: parseEnum[SensitiveMediaDetectionSensitivity](fieldNode.getStr())
