# Iterable Plugin

Flutter plugin to support Android and iOS push notifications from [https://iterable.com/](https://iterable.com/).

## Usage
To use this plugin, add `iterable_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Supported methods
| Method | Android | iOS |
|---|---|---|
| `initialize` | X | X |
| `setEmail` | X | X |
| `setUserId` | X | X |
| `registerForPush` | X | N/A |
| `signOut` | X | X |
| `track` | X | X |
| `setNotificationOpenedHandler` | X | |

## Installation
First, create a mobile API Key from [Iterable](https://support.iterable.com/hc/en-us/articles/360043464871#creating-api-keys).
Then, also from Iterable, [create a mobile app](https://support.iterable.com/hc/en-us/articles/115000331943#_2-create-a-mobile-app-in-iterable) and [assign a push integration](https://support.iterable.com/hc/en-us/articles/115000331943#_3-assign-a-push-integration-to-the-mobile-app)
to it.
Finally, add `iterable_flutter` as a plugin in `pubspec.yaml` file.

Once all of this is set up, call `initialize` from plugin, with Iterable's API_KEY and PUSH_INTEGRATION_NAME before identifying the user. The identification can be done either
using `setEmail` or `setUserId` methods. Don't set an email and user ID in the same session, doing so causes the SDK to treat them as different users.

Call `registerForPush` to register the device for current user if calling `setEmail` or `setUserId` after the app has already launched (for example, when a new user logs in).
To unregister the device/user from push notifications, then call `signOut`.

To track specific events, call `track` method.

### Example
***Example here***
