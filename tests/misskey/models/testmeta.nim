discard """
  targets: "c"
  matrix: "--mm:orc;--mm:orc -d:nimStressOrc;--mm:refc"
  output: ""
"""

import ../../../src/misskey/models/meta
import ../../../src/misskey/models/meta/features
import ../../../src/misskey/models/utils/versions
import std/[unittest, json, options, uri, colors]

let testJson = %* {
  "maintainerName": "maintainer",
  "maintainerEmail": "maintainer@example.com",
  "version": "13.13.2",
  "name": "test",
  "uri": "https://example.com",
  "description": nil,
  "langs": [],
  "tosUrl": nil,
  "repositoryUrl": "https://github.com/misskey-dev/misskey",
  "feedbackUrl": "https://github.com/misskey-dev/misskey/issues/new",
  "disableRegistration": true,
  "emailRequiredForSignup": true,
  "enableHcaptcha": true,
  "hcaptchaSiteKey": "testSiteKeyHcaptcha",
  "enableRecaptcha": false,
  "recaptchaSiteKey": nil,
  "enableTurnstile": true,
  "turnstileSiteKey": "testSiteKeyTurnstile",
  "swPublickey": nil,
  "themeColor": "#66ccff",
  "mascotImageUrl": "/assets/ai.png",
  "bannerUrl": nil,
  "infoImageUrl": nil,
  "serverErrorImageUrl": "https://example.com/error.png",
  "notFoundImageUrl": "https://example.com/404.png",
  "iconUrl": "https://example.com/icon.png",
  "backgroundImageUrl": nil,
  "logoImageUrl": "https://example.com/logo.png",
  "maxNoteTextLength": 3000,
  "defaultLightTheme": """{"id":"01234567-89ab-4cde-f012-3456789abcde","base":"light","desc":"description","name":"Test light theme","props":{},"author":"@maintainer@example.com"}""",
  "defaultDarkTheme": nil,
  "ads": [
    {
      "id": "01234abcde",
      "url": "https://example.com",
      "place": "square",
      "ratio": 1,
      "imageUrl": "https://picsum.photos/72"
    }
  ],
  "enableEmail": true,
  "enableServiceWorker": true,
  "translatorAvailable": false,
  "serverRules": [
    "Rule 1",
    "Rule 2"
  ],
  "policies": {
    "gtlAvailable": true,
    "ltlAvailable": true,
    "canPublicNote": true,
    "canInvite": false,
    "canManageCustomEmojis": false,
    "canSearchNotes": false,
    "canHideAds": false,
    "driveCapacityMb": 100,
    "alwaysMarkNsfw": false,
    "pinLimit": 5,
    "antennaLimit": 5,
    "wordMuteLimit": 200,
    "webhookLimit": 3,
    "clipLimit": 10,
    "noteEachClipsLimit": 200,
    "userListLimit": 10,
    "userEachUserListsLimit": 50,
    "rateLimitFactor": 0.9
  },
  "mediaProxy": "https://example.com/proxy",
  "cacheRemoteFiles": false,
  "requireSetup": false,
  "proxyAccountName": nil,
  "features": {
    "registration": false,
    "emailRequiredForSignup": true,
    "hcaptcha": true,
    "recaptcha": false,
    "turnstile": true,
    "objectStorage": true,
    "serviceWorker": true,
    "miauth": true
  }
}

let metaInfo = testJson.toMeta()

check metaInfo.maintainerName == some("maintainer")
check metaInfo.maintainerEmail == some("maintainer@example.com")
check metaInfo.version == version(13, 13, 2)
check metaInfo.name == "test"
check metaInfo.uri == parseUri("https://example.com")
check metaInfo.description == none(string)
check metaInfo.langs == newSeq[string]()
check metaInfo.tosUrl == none(Uri)
check metaInfo.repositoryUrl == parseUri("https://github.com/misskey-dev/misskey")
check metaInfo.feedbackUrl == parseUri("https://github.com/misskey-dev/misskey/issues/new")
check metaInfo.disableRegistration
check metaInfo.emailRequiredForSignup
check metaInfo.enableHcaptcha
check metaInfo.hcaptchaSiteKey == some("testSiteKeyHcaptcha")
check not metaInfo.enableRecaptcha
check metaInfo.recaptchaSiteKey == none(string)
check metaInfo.enableTurnstile
check metaInfo.turnstileSiteKey == some("testSiteKeyTurnstile")
check metaInfo.swPublickey == none(string)
check metaInfo.themeColor == some(parseColor("#66ccff"))
check metaInfo.mascotImageUrl == parseUri("/assets/ai.png")
check metaInfo.bannerUrl == none(Uri)
check metaInfo.infoImageUrl == none(Uri)
check metaInfo.serverErrorImageUrl == some(parseUri("https://example.com/error.png"))
check metaInfo.notFoundImageUrl == some(parseUri("https://example.com/404.png"))
check metaInfo.iconUrl == some(parseUri("https://example.com/icon.png"))
check metaInfo.backgroundImageUrl == none(Uri)
check metaInfo.logoImageUrl == some(parseUri("https://example.com/logo.png"))
check metaInfo.maxNoteTextLength == 3000
check metaInfo.defaultLightTheme == some("""{"id":"01234567-89ab-4cde-f012-3456789abcde","base":"light","desc":"description","name":"Test light theme","props":{},"author":"@maintainer@example.com"}""")
check metaInfo.defaultDarkTheme == none(string)
check metaInfo.ads == @[
  (
    id: "01234abcde",
    place: "square",
    url: parseUri("https://example.com"),
    imageUrl: parseUri("https://picsum.photos/72"),
    ratio: 1.0
  )
]
check metaInfo.enableEmail
check metaInfo.enableServiceWorker
check not metaInfo.translatorAvailable
check metaInfo.serverRules == @[
  "Rule 1",
  "Rule 2"
]
check metaInfo.policies == (
  gtlAvailable: true,
  ltlAvailable: true,
  canPublicNote: true,
  canInvite: false,
  canManageCustomEmojis: false,
  canSearchNotes: false,
  canHideAds: false,
  driveCapacityMb: 100.0,
  alwaysMarkNsfw: false,
  pinLimit: 5.Natural,
  antennaLimit: 5.Natural,
  wordMuteLimit: 200.Natural,
  webhookLimit: 3.Natural,
  clipLimit: 10.Natural,
  noteEachClipsLimit: 200.Natural,
  userListLimit: 10.Natural,
  userEachUserListsLimit: 50.Natural,
  rateLimitFactor: 0.9
)
check metaInfo.mediaProxy == parseUri("https://example.com/proxy")
check metaInfo.cacheRemoteFiles == some(false)
check metaInfo.requireSetup == some(false)
check metaInfo.proxyAccountName == none(string)
check metaInfo.features == some({
  Feature.emailRequiredForSignup,
  Feature.hcaptcha,
  Feature.turnstile,
  Feature.objectStorage,
  Feature.serviceWorker,
  Feature.miauth
})
