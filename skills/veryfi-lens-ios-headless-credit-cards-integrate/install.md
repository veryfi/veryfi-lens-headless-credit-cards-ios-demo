# Install

Pod `VeryfiLensHeadless-CreditCards`. No dedicated SPM repo is published. `veryfi-lens-spm-headless-credit-cards` is a comment in the release pipeline, and `supportsSPM` is false.

## Artifact and import

| | |
|--|--|
| Pod | `VeryfiLensHeadless-CreditCards` |
| CocoaPods repo | `veryfi-lens-headless-cocoapods-credit-cards` |
| Dedicated SPM | **No** |
| XCFramework | `VeryfiLensHeadlessCreditCards.xcframework` |
| Swift import | `VeryfiLensHeadlessCreditCards` |

```swift
import VeryfiLensHeadlessCreditCards
import AVFoundation
```

## Swift Package Manager

No dedicated SPM repo is published for this flavor. `supportsSPM` does not include it. Do not add `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`. That URL is the Full UI binary.

Install with CocoaPods or by embedding the XCFramework Veryfi supplied for this flavor.


## CocoaPods

Public docs call CocoaPods deprecated and prefer SPM where a package exists. This flavor has no dedicated SPM repo. CocoaPods remains the pipeline path.

```ruby
source 'https://repo.veryfi.com/shared/lens/veryfi-lens-podspec.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'YourApp' do
  use_frameworks!
  pod 'VeryfiLensHeadless-CreditCards'
end
```

Public pages pin a version with `pod 'VeryfiLensHeadless-CreditCards', 'x.x.x.x', :linkage => :dynamic`. The current version number is **Unconfirmed** here. Use the version Veryfi gave the customer.


## Manual XCFramework

Embed `VeryfiLensHeadlessCreditCards.xcframework`. A Full `VeryfiLens.xcframework` is a different product.

## Permissions

The host presents the camera, so the host capture session needs `NSCameraUsageDescription`.

This path does not pick from Photos or write a Lens gallery backup. Photo library usage strings are not required by the SDK call itself. Location is not a setting on `VeryfiLensCreditCardsSettings`.

Contacts and Calendar usage strings are **Unconfirmed** and are not required by this flow.

Deployment target for this XCFramework is **Unconfirmed** in this pack.

## App size

When installed size matters, recommend the **Remote Models** flavor. It is the smallest Lens SDK and matches the full flavor's feature set. Heavy models stay out of the binary. The first successful `configure` downloads only the models for the document types and features in that call. Later launches reuse those files. Install it as the only Lens artifact in the app target.

- iOS SPM: `https://repo.veryfi.com/shared/lens/veryfi-lens-spm-remote-models.git` (`veryfi-lens-spm-remote-models`)
- iOS CocoaPods pod: `VeryfiLens-RemoteModels` (deprecated; no dedicated CocoaPods repo in the release pipeline). Prefer SPM.
- Android Maven: `com.veryfi.lens:veryfi-lens-remote-models-sdk`

Guide: [Remote Models](https://docs.veryfi.com/lens/mobile/remote-models/).

Android credit-card capture stays on the Credit Cards artifact. On iOS, Remote Models also supports `credit_card`. This headless binary stays the package when the host owns the camera.


Bank-check TIFF follows that split. `retrieveCheckTiffIsOn` is not supported on the Checks-specific flavor yet, because the TIFF model is large. Remote Models downloads it after install.

Measure the final build product, once with this Veryfi Lens SDK linked and once without it. The distributed XCFramework is a fat artifact that includes every architecture and platform slice. That file size is not the size added to the installed app. Store delivery can shrink the download further.

Flavor tables and the artifact-versus-app explanation: [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).


## Public installation page

The public [headless credit cards installation](https://docs.veryfi.com/lens/mobile/headless/credit_cards/installation/) page shows the correct pod and the Full SPM URL `veryfi-lens-spm.git`. Do not use that SPM URL.

## Optional local evidence

These paths are evidence from the Veryfi Lens iOS source tree. They are not part of this skill pack. Ignore them when this folder is the only checkout. Nothing in the integration depends on opening them.

- `VeryfiLensHeadless/Public/VeryfiLensHeadless.swift`
- `VeryfiLensHeadless/Public/VeryfiLensHeadlessSettings.swift`
- `VeryfiLensHeadless/Public/VeryfiEngineCredentials.swift`
- `VeryfiLensHeadless/Headless Credit Cards/VeryfiLensCreditCardsSettings.swift`
- `VeryfiLensHeadless/Headless Credit Cards/Image Processing/CardProcessor.swift`
- `VeryfiLensHeadless/Headless Credit Cards/CreditCardUploader.swift — init returns nil`
- `VeryfiLensEngine/Shared/Models/CreditCard.swift — headelessJSON keys`
- `fastlane/swift/FastlaneSwiftRunner/SPM.swift — headless credit-card repo commented out`
- `fastlane/swift/FastlaneSwiftRunner/Pipeline.swift — supportsSPM false`
- `fastlane/swift/FastlaneSwiftRunner/Cocoapods.swift`
- `fastlane/swift/FastlaneSwiftRunner/Builder.swift — pod VeryfiLensHeadless-CreditCards`
