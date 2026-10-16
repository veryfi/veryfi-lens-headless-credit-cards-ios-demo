# Clarifications

## Resolved enough to integrate

- Settings type is `VeryfiLensCreditCardsSettings`. Entry is `VeryfiLensHeadless.shared()`.
- Extraction stays on device. Document-ready does not include the PAN.
- Upload helpers on this class do not create an uploader (`init` returns nil).
- `autoCaptureMode` unknown strings become `.normal`. Parameterless init is `.accuracy`.
- Derived counters are not assignable inputs.

## Unconfirmed

- Exact `veryfiLensError` `msg` strings for blur or low confidence.
- Whether a future card processor will use `setCameraSessionQueue`.
- XCFramework deployment target.
- Whether a Remote Models artifact replaces this headless binary when size matters. Ask Veryfi before substituting. Still measure with and without the dependency you actually link.
- Contacts and Calendar usage strings. Do not add them for this flow.
