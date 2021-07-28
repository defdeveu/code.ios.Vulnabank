# VulnaBank
### defdeveu. iOS secdev exam app.

The application is the exam material for a ‘Secure iOS Coding' course. The application has some serious security issues while providing ‘life like’ functionality (of a banking app).

### Technology stack

- Swift
- MVVM app architecture
- Sqlite database implementation
- Encryption CocoaPod libraries SwiftRSA and CryptoSwift
- Dependency injection with Swinject CocoaPod.  
- XML serialization with XMLCoder CocoaPod

### Supported systems

- iOS 12.0 and later
- Xcode 10 and later

### Installation

- clone git repository
- pod install
- open the vulnabankIOs.xcworkspace in Xcode
- set your team and provisioning profile at the Signing section 


### Application overview

### Structure

##### UI Structure

Each of the ViewControllers has a ViewModel class which provides data and logic for the ViewController. 
The ViewModels use DynamicValue type which provides observable listeners for events to the ViewControllers

- **NavigationViewController**:  manages the application's ViewControllers   
- **RegistrationViewController**: shows the registration form modally 
- **LoginViewController**: shows the login form modally
- **TransactionsViewController**: shows the transactions list with the NavigationBar
- **NewTransactionsViewController**: shows the new transaction form modally

##### Injected services by protocols
- **DatabaseDaoProtocol**: SQLite database access
- **AuthServiceProtocol**: Authentication service
- **BackendServiceProtocol**: Network layer for sending transaction
- **TransactionRepositoryProtocol**: Repository for the transactions

##### Utilities

- **DeepLink**: provides URL Scheme from outside of the application
- **Logger**: Custom file logger
- **CryptoUtils**: RSA and AES encoding, decoding
 
#### Operation
- **Registration and first run**
    - Install and run VulnaBank application
    - Type correct pins (only 4 numeric characters accepted in password and re-password field -> Register button goes enabled)
    - When two pin is not equals, local validation shows error message
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

- **DeepLink**
    - The application can handle custom URL Scheme which provides add transaction functionality from other applications.    
    
    ddemsg://add?recipient=xy&amount=123
    
[![social image](https://raw.githubusercontent.com/defdeveu/vulnabankIOS/master/assets/agustin-mariano-quezada-FwA9_0uZcPQ-unsplash.crop.ksenia-edit-a.jpg)](https://github.com/defdeveu/vulnabankIOS)
    
    
### Credits
* Created by Ferenc Sági
* Specification by Zsombor Kovács
* Photo by Agustin Mariano Quezada used under the Unsplash Licence; derived work by Ksenia Kotelnikova


    
