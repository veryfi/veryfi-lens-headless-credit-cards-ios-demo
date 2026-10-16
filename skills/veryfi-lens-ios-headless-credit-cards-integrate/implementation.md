# Implementation

Lens does not present a view controller. The host creates the camera.

## Credentials

```swift
let credentials = VeryfiLensHeadlessCredentials(
    clientId: "<clientId>",
    username: "<username>",
    apiKey: "<apiKey>",
    url: "https://api.veryfi.com"
)
```

Store secrets outside git. All four fields must be non-empty. An empty field calls `completion(false)` and, once a delegate exists, `veryfiLensError` with message `invalid_credentials` and `data.empty_fields`.

Set `VeryfiLensHeadless.shared().delegate` before or with `configure`.

## Configure and process

```swift
let settings = VeryfiLensCreditCardsSettings()

VeryfiLensHeadless.shared().delegate = self
VeryfiLensHeadless.shared().configure(with: credentials, settings: settings) { success in
    guard success else { return }
    VeryfiLensHeadless.shared().startProcessingBuffer()
}

func captureOutput(_ output: AVCaptureOutput,
                   didOutput sampleBuffer: CMSampleBuffer,
                   from connection: AVCaptureConnection) {
    VeryfiLensHeadless.shared().process(buffer: sampleBuffer)
}
```

Stop and close when the host leaves the screen:

```swift
VeryfiLensHeadless.shared().stopProcessingBuffer()
VeryfiLensHeadless.shared().close()
```

`reset()` clears detector state between cards.

`updateSettings(_:)` replaces flags on the live processor. The in-repo sample turns off `detectCardNumber` after a number is already filled so the next frames look for the remaining fields. That pattern is host logic. The argument is `VeryfiLensCreditCardsSettings`.

`setCameraSessionQueue(_:)` exists on `VeryfiLensHeadless`. The credit-card processor’s `setCameraSessionQueue` body is empty. Calling it is harmless and does not wire the card detector. **Unconfirmed** whether a future card processor will use the queue.

`processWithBlock`, `crop`, and `rotate` exist on the shared headless class. The card autocapture path is `process(buffer:)`.

Passing `VeryfiLensReceiptSettings` into this binary fails the processor cast. The delegate gets `Wrong VeryfiLensHeadlessSettings instance is used. Make sure VeryfiLensHeadlessSettings instance is used`.

There is no `dataExtractionEngine` on this settings type. Extraction is on device. `CardProcessor` posts document-ready with boolean presence flags (`card_number`, `card_dates`, `card_name`, `card_cvc`, `card_type`), `sdk` `lens-headless-credit-card`, and `data_extraction_engine` `mobile`. The PAN is not in that body. It is in the delegate `data`.

## Upload is not a card path

`upload(images:)` and `upload(url:)` are not a credit-card path. `CreditCardUploader.init` returns nil, so `VeryfiLensHeadless.upload` fails the uploader check and reports `veryfiLensError` with `"No valid credentials"` even after a successful configure. Capture with `process(buffer:)`.

## UI SDK helpers

`VeryfiLens.shared().showCamera`, `uploadImages(paths:)`, and `headlessUpload` belong to the Lens UI module. They are not this product. A no-UI helper on the UI SDK is still the UI SDK.
