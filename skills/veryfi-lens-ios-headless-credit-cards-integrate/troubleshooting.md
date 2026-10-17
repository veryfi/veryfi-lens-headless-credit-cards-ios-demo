# Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Wrong VeryfiLensHeadlessSettings instance is used` | Receipts settings, or `VeryfiLensSettings`, passed to this binary | Pass `VeryfiLensCreditCardsSettings` |
| `"No valid credentials"` after configure succeeded | `upload(images:)` or `upload(url:)` | Use `process(buffer:)` |
| `invalid_credentials` | An empty credential field | Fill client id, username, API key, and URL. Set the delegate first |
| No callbacks | Delegate set on `VeryfiLens.shared()` | Set `VeryfiLensHeadless.shared().delegate` |
| Camera never opens | This product does not present UI | Host `AVCaptureSession`, then `startProcessingBuffer` |
| PAN in analytics or a cloud body | Host logged `data`, or used the UI cloud engine | Keep the value in the delegate only. Card data is never sent to the backend |
| `showCamera` does not compile | UI SDK API | This module is `VeryfiLensHeadlessCreditCards` |

## Conflicts

- Do not mix `VeryfiLensReceiptSettings` into this configure call.
- Do not install `https://repo.veryfi.com/shared/lens/veryfi-lens-spm.git`.
- Do not treat UI `uploadImages` or `headlessUpload` as this lifecycle.
- Do not promise fraud detection, field detection, Any-Documents templates, or check TIFF from this binary.
- A wrong settings class is a hard failure string, not a silent fallback.

App size: measure the final app with the dependency and without it. [SDK binary sizes](https://docs.veryfi.com/lens/mobile/settings/sdk_binary_sizes/).
