## 0.6.1
- fix(in-app): dismiss presented vc before handling action
- chore: bump iterable native sdks to the latest version

## 0.6.0
- feat(deeplinks): support app links and universal links
- feat(deeplinks): support openUrl action
- feat(inbox): support mobile inbox
- feat(inbox): support custom actions

## 0.5.7
- build(Dependencies): update iterable android and iOS dependencies #57

## 0.5.6
### Fix
- fix(UpdateUser): waiting for user update never ends on Android #54

## 0.5.5
### Fix
- fix(PayLoad Push): IOS SDK sends the push payload encoded sometimes.

## 0.5.4
### Features
- feat(Data Push): have a single delivery format of the push notification metadata. 🧾 #47.
- feat(Library Pubspec): add pubspec to the ignore file by recommendation #43
### Fix
- Fix Crash on API 31+ #46.
- fix(Open Push IOS): could not read push data when app was closed. #45
- fix(Last Push Payload): when you open the app, reload the latest data from the push notification #42
### Other work
- ci(Android): fix ci builds for android #44

## 0.3.0+1
Added to update pubspec info.

## 0.3.0
- Implement signOut on iOS (thanks to @Gabriel-Azevedo: https://github.com/la-haus/iterable-flutter/pull/37

## 0.1.1
- Add updateUser support and registerForPush in iOS

## 0.1.0
Initial release
