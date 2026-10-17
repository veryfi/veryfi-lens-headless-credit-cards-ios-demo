# Callbacks

`VeryfiLensHeadlessDelegate` has four required methods and no `onHelpButtonClicked`.

```swift
func veryfiLensClose(_ json: [String: Any]) {}
func veryfiLensError(_ json: [String: Any]) {}
func veryfiLensSuccess(_ json: [String: Any]) {}
func veryfiLensUpdate(_ json: [String: Any]) {}
```

Autocapture updates and success use the same card dictionary.

| Event | `status` | `msg` | `data` |
|-------|----------|-------|--------|
| Live update | `inprogress` | `autocapture` | Headless card JSON |
| Finished read | `done` | `autocapture` | Same dictionary |

Keys:

| Key | Value |
|-----|--------|
| `card_number` | PAN string |
| `card_name` | Holder |
| `card_type` | Brand |
| `card_dates` | `[date, date2]` strings. Missing dates are `""` |
| `card_cvc` | CVC |
| `card_uuid` | Local UUID |
| `card_is_invalid` | `(!isValidLuhn).description` string, not a Bool |

These keys differ from the UI SDK’s `credit_card_number` / `credit_card_holder_name` dictionary. The source property that builds this dictionary is spelled `headelessJSON`. Use the keys above. Do not invent a renamed accessor.

`veryfiLensError` carries processor failures. The exact `msg` strings for blur or low confidence are **Unconfirmed**. Handle the callback without assuming a closed list. Empty credentials use `invalid_credentials`.

`veryfiLensClose` is part of the delegate. The card autocapture path emits update and success, not close. Close is emitted if an uploader calls the upload-start helper. The credit-card uploader is never created (`init` returns nil).

Copy the PAN inside the success callback for the host’s own secure use. Do not log it. Credit card data is never sent to the backend. The document-ready body has presence flags only.
