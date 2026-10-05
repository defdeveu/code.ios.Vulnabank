# VulnaBank
### defdev's iOS development security exam app.

This deliberately vulnerable application (DVA) is exam material used in the ‘Development security in iOS' blue level course by Zsombor Kovács (huobb0). The application has some serious security issues while providing ‘life like’ functionality (of a conceptual banking app). It's used as code-review material in the course. It is a teaching artifact: the app exists to be read, not to be deployed :).

## Requirements

- Xcode 27 or later with an iOS 17.5 simulator runtime.
- No third-party dependencies and no package manager.

## Build and run

- Open `vulnabankIOs.xcodeproj`.
- Select the `vulnabankIOs` scheme and run with Command-R.
- Run the tests with Command-U.

The exercise run steps are in [MANUAL.md](MANUAL.md).

## Application overview

### Structure

#### Techno

- SwiftUI app, Swift 6 with complete concurrency checking.
- `@MainActor @Observable` view models with protocol-based dependency injection
  assembled by `AppRepository`.
- Raw SQLite3 persistence.
- Swift Testing suites in `vulnabankIOsTests/`.

##### UI Structure

The app has one shared `AppModel` and the PIN fields keep a small `PinFieldModel`; views read state and call methods, so there are no per-controller observers or callbacks.

- **RootView**: hosts the navigation stack and the authentication gate
- **RegistrationView**: shows the registration form when no PIN is stored
- **LoginView**: shows the login form when a PIN is stored and the session is locked
- **TransactionsView**: shows the transaction list with the navigation bar
- **NewTransactionView**: shows the new transaction form as a sheet

##### Injected services by protocols
- **DatabaseDaoProtocol**: SQLite database access
- **AuthServiceProtocol**: Authentication service
- **BackendServiceProtocol**: Network layer for sending transaction
- **TransactionRepositoryProtocol**: Repository for the transactions

##### Utilities

- **DeepLink**: handles the app's incoming URLs
- **Logger**: custom file logger
- **MessageCrypto** / **MessageEncryption** / **KeyRepository**: RSA and AES encoding and decoding

#### Backend

The app posts an encrypted request to the endpoint named by the
`LabVulnaBankURL` key in `vulnabankIOs/Info.plist`. The checked-in
`Config/Hosted.xcconfig` points it at
`https://zsk.labs.def.dev/secure-communication/request`; copying
`Config/Local.example.xcconfig` to the gitignored `Config/Local.xcconfig`
switches it to a local server instead.


### Operation
- **Registration and first run**
    - Install and run VulnaBank application
    - Type a PIN in both fields; the Register button enables when the two match
    - When the two pins are not equal, local validation shows an error message
- **Login**
    - Start the application
    - Type incorrect pin, press Login button, local validation error message shows
    - Type correct pin, press Login button, application enters the transaction screen
    - Send app to background, select application from running apps, application shows the Login screen
- **Send transaction**
    - Start and log into the application
    - Press + button on the NavigationBar
    - If you press cancel in the dialog, ot will close down
    - Fill the form with any data. The amount must be numeric.
    - Send the transaction with the send button. The popup form will disappear, and the new transaction going to be in the list.
    - In case of failed transaction, the error shows in the transaction list as well.
- **Edit**
    - You can delete transactions individually with left swipe, or with Edit button on the NavigationBar on multiple items.

[![social image](https://raw.githubusercontent.com/defdeveu/vulnabankIOS/master/assets/agustin-mariano-quezada-FwA9_0uZcPQ-unsplash.crop.ksenia-edit-a.jpg)](https://github.com/defdeveu/vulnabankIOS)


## Credits
* First implemented by Ferenc Sági (sagifer)
* Idea and specification by Zsombor Kovács (huobb0)
* Contributors: Julia Hanol (JGanol), Sander Frenken (sanderfrenken)
* Photo by Agustin Mariano Quezada used under the Unsplash Licence; derived work by Ksenia Kotelnikova
* Modernization in 2026 by Deepseek 4.1 Flash / Crush / Hypercrush under guidance of Timur Khrotko (timurxyz)
