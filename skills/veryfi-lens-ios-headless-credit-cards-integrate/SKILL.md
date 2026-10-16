---
name: veryfi-lens-ios-headless-credit-cards-integrate
description: >-
  Integrates the Veryfi Lens iOS Headless Credit Cards SDK. Covers pod
  VeryfiLensHeadless-CreditCards, VeryfiLensHeadlessCreditCards,
  VeryfiLensCreditCardsSettings, and process(buffer:) on a host-owned camera.
  Use when the app supplies CMSampleBuffer frames and reads cards on device.
  Card data stays on device. No dedicated SPM repo is published.
---

# Veryfi Lens iOS Headless Credit Cards

The host owns `AVCaptureSession` and passes `CMSampleBuffer`s to `VeryfiLensHeadless`. Lens does not present a camera view controller.

**Settings type:** `VeryfiLensCreditCardsSettings`. It conforms to `VeryfiLensHeadlessSettings`. It is not `VeryfiLensSettings` and it is not the Demo UI class `VeryfiLensCreditCardSolutionSettings`.

**Credentials:** `VeryfiLensHeadlessCredentials`. **Entry:** `VeryfiLensHeadless.shared()`.

## Quick flow

Assumptions: the host already has a camera session and wants on-device card reads.

1. Install pod `VeryfiLensHeadless-CreditCards` or embed `VeryfiLensHeadlessCreditCards.xcframework`. See [install.md](install.md).
2. Apply [settings.md](settings.md). Leave derived capture counters alone.
3. `configure`, `startProcessingBuffer`, then `process(buffer:)` from the capture callback. See [implementation.md](implementation.md).
4. Read `card_number` and the other keys in [callbacks.md](callbacks.md). Do not log the PAN.
5. `stopProcessingBuffer` and `close` when the screen goes away.
6. Track [checklist.md](checklist.md).

## Guided flow

Ask only what is missing:

| Topic | Options |
|-------|---------|
| Fields | Number, holder name, date, CVC. All default on |
| Auto-capture mode | `.accuracy` (init default), `.normal`, `.speed`, or `.none` |
| Insets | Class defaults `marginTop` 100 and `marginBottom` 50, or the in-repo sample 80 and 30 when the preview needs that inset |
| Logging | Confirm PAN and CVC are not written to analytics |

If the host wants the Lens camera UI, this binary does not present it. The UI credit-card flavor uses `VeryfiLens` and `VeryfiLensSettings`. Do not mix the two types in one `configure`.

## Workflow

```
Headless credit cards:
- [ ] Artifact and camera usage string
- [ ] VeryfiLensCreditCardsSettings
- [ ] configure, then startProcessingBuffer
- [ ] process(buffer:)
- [ ] Delegate update and success
- [ ] stop and close
```

- [install.md](install.md)
- [implementation.md](implementation.md)
- [settings.md](settings.md)
- [callbacks.md](callbacks.md)
- [troubleshooting.md](troubleshooting.md)
- [clarifications.md](clarifications.md)
- [checklist.md](checklist.md)

## Warnings

- Credit card data is local only and is never sent to the backend. `.inApp` (`"mobile"`) is the on-device engine for `credit_card`, `code`, and `barcode` on the UI SDK. This headless product keeps the PAN in the delegate payload, not in the document-ready body.
- Any-Documents is a broad solution: `any_document` plus `anyDocumentTemplate`. Nutrition facts, US passport, driver license, and prescription labels are shortcut flavors of Any-Documents, not separate products. Contact support for another template, including one that is not supported yet. Do not set `anyDocumentType`. This binary is not that solution.
- Local fraud detection and local field detection are paid features gated by the validated account and backend entitlement. They are not properties of this headless settings type. Do not invent `fraudDetectionIsOn` or `documentFieldsToDetect` here. Field detection also needs the Field Detection or Remote Models flavor on the UI SDK.
- Bank-check TIFF (`retrieveCheckTiffIsOn`) requires Remote Models. It is not part of this product and it is not in the Checks-specific UI flavor yet, because the TIFF model is large.
- When installed size matters, recommend Remote Models for flavors that embed heavy models, and measure the final app with this SDK linked and without it. Do not quote the XCFramework file size. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).
- `VeryfiLens.shared().uploadImages` and `VeryfiLens.shared().headlessUpload` are UI SDK helpers. They are not this Headless product.
- There is no Photos or iCloud backup property on `VeryfiLensCreditCardsSettings`. Do not add a gallery backup. The UI SDK default `backupDocsToGallery` true does not apply here.
- UI client code uses `VeryfiLensSettings()`. Demo subclasses are not a client contract. This product does not use them either.


## Suggestions

- Start with `autoCaptureMode = .accuracy` and the class margin defaults. Use margin 80 and 30 only when the preview matches the in-repo sample.
- After a field is filled, `updateSettings` can turn `detectCardNumber` off so later frames look for the remaining fields. That is host logic. Pass a `VeryfiLensCreditCardsSettings` instance.
- Call `reset()` between cards.
- If size matters, measure the installed app with this XCFramework linked and removed. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

## Do not

- Do not `import VeryfiLens` or call `showCamera`.
- Do not construct `VeryfiLensSettings` or `VeryfiLensCreditCardSolutionSettings` for `configure`.
- Do not call `upload(images:)` or `upload(url:)`. The credit-card uploader `init` returns nil, so upload reports `veryfiLensError` with `"No valid credentials"` even after a successful configure.
- Do not install `veryfi-lens-spm`.
- Do not log `card_number` or `card_cvc`.
- Do not assign `frameCount`, `maxPhaseTries`, `maxTries`, or `maxCount`.

## Output

Host sample includes the camera usage string, `configure` with `VeryfiLensCreditCardsSettings`, the capture-output call to `process(buffer:)`, and a delegate that reads the headless card keys.
