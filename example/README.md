# Iterable Plugin Example

Demonstrates how to use the iterable_flutter plugin.

## Usage
As Iterable API uses Firebase Cloud Messaging (FCM) internally as third party to send push notifications, we need to set it up to the example project.
Then first thing is to set up (or use) a project in Firebase where Cloud Messaging is configured (one for Android and another for iOS). It's important
that package name configuration matches with Iterable's push integration name.

Remember to:
 * For Android configuration, to download `google-services.json` file and place it in example's `android/app` folder.
 * Also, in `app/build.gradle` file apply Google services plugin:
    `apply plugin: 'com.google.gms.google-services'`
 * In example's project `build/gradle` add the Google Services classpath as dependency:
    `classpath 'com.google.gms:google-services:4.3.10'`
 
With this basic configuration and getting project's Server Key from `Project Overview > Project Settings > Cloud Messaging` section, now it's
possible to send a push notification from Firebase to the device we have plugin's Example App installed.

## Example
```dart

```     
  
