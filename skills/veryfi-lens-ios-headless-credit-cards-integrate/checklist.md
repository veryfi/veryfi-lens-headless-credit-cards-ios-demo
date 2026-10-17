# Checklist

```
Headless credit cards:
- [ ] Pod VeryfiLensHeadless-CreditCards or VeryfiLensHeadlessCreditCards.xcframework
- [ ] import VeryfiLensHeadlessCreditCards
- [ ] NSCameraUsageDescription
- [ ] VeryfiLensCreditCardsSettings, not VeryfiLensSettings
- [ ] Delegate on VeryfiLensHeadless.shared()
- [ ] configure success before startProcessingBuffer
- [ ] process(buffer:) from the capture callback
- [ ] Success reads card_number, card_name, card_dates, card_cvc, card_type
- [ ] stopProcessingBuffer and close on exit
- [ ] No upload(images:) and no PAN logging
- [ ] Unconfirmed error strings not promised
```

No dedicated SPM. Do not add `veryfi-lens-spm`.

If the host asked about size, quote a with-and-without app measurement, not the XCFramework file. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).

[clarifications.md](clarifications.md) items stay marked Unconfirmed.
