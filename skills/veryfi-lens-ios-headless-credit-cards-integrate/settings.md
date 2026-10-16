# Settings

Public type: `VeryfiLensCreditCardsSettings`. Construct it with `VeryfiLensCreditCardsSettings()`. `init(with:)` accepts a dictionary. Unknown `autoCaptureMode` raw strings fall through to `.normal`. The parameterless `init()` keeps `.accuracy`.

`VeryfiLensSettings` is the Lens UI settings type. `configure` on this product does not take it. Demo subclass `VeryfiLensCreditCardSolutionSettings` is not this type.

## Recipe

```swift
let settings = VeryfiLensCreditCardsSettings()
settings.detectCardNumber = true
settings.detectCardHolderName = true
settings.detectCardDate = true
settings.detectCardCVC = true
settings.autoCaptureMode = .accuracy
settings.marginTop = 100   // class default; in-repo sample uses 80
settings.marginBottom = 50 // class default; in-repo sample uses 30
```

Margins are in the units the detector uses. Use the defaults unless the host frame needs the sample inset.

## Complete public settings

| Property | Default | Explanation |
|----------|---------|-------------|
| `documentType` | `.creditCard` | Not a settable string list. Leave it. |
| `detectCardNumber` | `true` | Read the PAN on device. |
| `detectCardHolderName` | `true` | Read the holder name. |
| `detectCardCVC` | `true` | Read the CVC. |
| `detectCardDate` | `true` | Read the date or dates. |
| `marginTop` | `100` | Detector inset. Sample code uses `80`. |
| `marginBottom` | `50` | Detector inset. Sample code uses `30`. |
| `autoCaptureMode` | `.accuracy` | `VeryfiLensHeadlessAutoCaptureMode`: `.none`, `.speed`, `.normal`, `.accuracy`. |
| `frameCount` | derived | Read-only. Do not assign. |
| `maxPhaseTries` | derived | Read-only. Do not assign. |
| `maxTries` | derived | Read-only. Do not assign. |
| `maxCount` | derived | Read-only. Do not assign. |

`json` includes `documentType`, the four detect flags, both margins, and `autoCaptureMode`. It does not include the derived counters.

There is no backup flag, no `dataExtractionEngine`, no `documentTypes` array, no `ignoreRemoteSettings`, and no `dictateIsOn` on this type. Do not invent them.

Gallery and iCloud backups are UI SDK settings (`backupDocsToGallery` defaults true there). Leave them off if you are also shipping a UI flavor. They are not how this headless type works.
