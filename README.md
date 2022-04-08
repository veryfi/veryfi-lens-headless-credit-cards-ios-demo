# Veryfi Lens Headless

Veryfi Lens Headless is a framework for your mobile app to give it document capture superpowers in minutes.

Let Veryfi handle the complexities of frame processing, asset preprocessing, edge routing, and machine vision challenges in document capture. We have been at this for a long time and understand the intricate nature of mobile capture. That’s why we built Lens. Veryfi Lens is built by developers for developers; making the whole process of integrating Lens into your app fast and easy with as few lines as possible.

Veryfi Lens is a Framework: a self-contained, reusable chunks of code and resources you can import into you app.

Lens Headless is built in native code and optimized for fast performance, clean user experience and low memory usage.

You can read further about Lens in Veryfi's dedicated page: https://www.veryfi.com/lens/

## Table of content
1. [Veryfi Lens Headless iOS Example](#example)
2. [Other Lens iOS Examples](#examples)
3. [Configuration](#configuration)
4. [Other platforms](#other_platforms)
5. [Get in contact with our team](#contact)

## Veryfi Lens Headless iOS Example <a name="example"></a>
![headless-gif](https://user-images.githubusercontent.com/30237430/162486140-8ddfd256-8cbd-470a-aeef-03a0e422574a.gif)

## Other Lens iOS Examples <a name="examples"></a>
This is an example of how to use Veryfi Lens Credit Cards in your app, you can find the developer documentation [here](iOSLensCreditCards.pdf).
You can find five example projects, which are the five versions of Lens that we currently offer:
- [Lens for Long Receipts](https://github.com/veryfi/veryfi-lens-long-receipts-ios-demo)
- [Lens for Receipts](https://github.com/veryfi/veryfi-lens-receipts-ios-demo)
- [Lens for Credit Cards](https://github.com/veryfi/veryfi-lens-credit-cards-ios-demo)
- [Lens for Business Cards](https://github.com/veryfi/veryfi-lens-business-cards-ios-demo)
- [Lens for Checks](https://github.com/veryfi/veryfi-lens-checks-ios-demo)

### Configuration <a name="configuration"></a>
- Clone this repository
- Make sure your SSH key has been granted access to Veryfi's private Cocoapods repository [here](https://hub.veryfi.com/api/settings/keys/#package-managers-container)
- Also make sure your SSH key has been added to ssh-agent by running this command in the Terminal: `ssh-add -K /path/to/private_key`
- Run `pod install`
- Replace credentials in `HeadlessCreditCardsViewController.viewDidLoad()` with yours
```
VeryfiLensHeadlessCredentials(clientId: "XXXXXX", // replace XXXXXX with your assigned Client Id
                              username: "XXXXXX", // replace XXXXXX with your assigned Username
                                apiKey: "XXXXXX", // replace XXXXXX with your assigned API Key
                                   url: "XXXXXX") // replace XXXXXX with your assigned Endpoint URL
```
- Run the project on the real device to test Scanning experience

### Other platforms <a name="other_platforms"></a>
We also support the following wrappers for hybrid frameworks:
- [Cordova](https://hub.veryfi.com/lens/docs/cordova/)
- [React Native](https://hub.veryfi.com/lens/docs/react-native/)
- [Flutter](https://hub.veryfi.com/lens/docs/flutter/)
- [Xamarin](https://hub.veryfi.com/lens/docs/xamarin/)

If you don't have access to our Hub, please contact our sales team, you can find the contact bellow.

### Get in contact with our sales team <a name="contact"></a>
Contact sales@veryfi.com to learn more about Veryfi's awesome products.
