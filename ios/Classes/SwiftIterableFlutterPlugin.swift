import Flutter
import UIKit
import IterableSDK
import UserNotifications

public class SwiftIterableFlutterPlugin: NSObject, FlutterPlugin {
    
    static var channel: FlutterMethodChannel? = nil
    
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "iterable_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftIterableFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "initialize":
            let args = getPropertiesFromArguments(call.arguments)
            
            let apiKey = args["apiKey"] as! String
            let pushIntegrationName = args["pushIntegrationName"] as! String
            let allowedProtocols = args["allowedProtocols"] as! [String]
            let activeLogDebug = args["activeLogDebug"] as? Bool
            
            LogUtils.enabled = activeLogDebug ?? false
            initialize(apiKey, pushIntegrationName, allowedProtocols)
            
            result(nil)
        case "setEmail":
            let email = call.arguments as! String
            IterableAPI.email = email
            
            result(nil)
        case "setUserId":
            let userId = call.arguments as! String
            IterableAPI.userId = userId
            
            result(nil)
        case "track":
            let eventName = call.arguments as! String
            IterableAPI.track(event: eventName)
            
            result(nil)
        case "checkRecentNotification":
            notifyPushNotificationOpened()
            
            result(nil)
        case "updateUser":
            let args = getPropertiesFromArguments(call.arguments)
            if let userInfo = args["params"] as? [String : Any] {
                IterableAPI.updateUser(userInfo, mergeNestedObjects: false)
            }
            
            result(nil)
        case "registerForPush":
            registerForPushNotifications()
            
            result(nil)
        case "signOut":
            signOut()
            
            result(nil)
        case "showMobileInbox":
            if let rootViewController = getRootViewController() {
                let args = getPropertiesFromArguments(call.arguments)
                
                let viewController = IterableInboxNavigationViewController()
                if let screenTitle = args["screenTitle"] as? String {
                    viewController.navTitle = screenTitle
                }
                if let noMessagesTitle = args["noMessagesTitle"] as? String {
                    viewController.noMessagesTitle = noMessagesTitle
                }
                if let noMessagesBody = args["noMessagesBody"] as? String {
                    viewController.noMessagesBody = noMessagesBody
                }
                
                viewController.modalPresentationStyle = .fullScreen
                rootViewController.present(viewController, animated: true)
            }
            result(nil)
        case "getUnreadInboxMessagesCount":
            result(IterableAPI.inAppManager.getUnreadInboxMessagesCount())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(_ apiKey: String, _ pushIntegrationName: String, _ allowedProtocols: [String]){
        let config = IterableConfig()
        config.pushIntegrationName = pushIntegrationName
        config.allowedProtocols = allowedProtocols
        config.autoPushRegistration = false
        config.useInMemoryStorageForInApps = true
        config.urlDelegate = self
        config.customActionDelegate = self
        
        IterableAPI.initialize(apiKey: apiKey, launchOptions: launchOptions, config: config)
    }
    
    private func getPropertiesFromArguments(_ callArguments: Any?) -> [String: Any] {
        if let arguments = callArguments as? [String: Any] {
            return arguments;
        }
        return [:]
    }
    
    func signOut() {
        IterableAPI.disableDeviceForCurrentUser()
        IterableAPI.logoutUser()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                guard granted else { return }
                guard self != nil else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
    }
    
    private func notifyPushNotificationOpened() {
        guard let channel = SwiftIterableFlutterPlugin.channel else { return }
        
        if var lastPushPayload = IterableAPI.lastPushPayload {
            lastPushPayload["source"] = "push"
            channel.invokeMethod("actionHandler", arguments: lastPushPayload)
        }
        
    }
    
    private func notifyIterableAction(_ context: IterableActionContext) {
        guard let channel = SwiftIterableFlutterPlugin.channel else { return }
        
        var source = ""
        switch context.source {
        case .push:
            if let _ = IterableAPI.lastPushPayload {
                return notifyPushNotificationOpened()
            } else {
                source = "push"
            }
        case .universalLink:
            source = "universalLink"
        case .inApp:
            source = "inApp"
        }
        let arguments: [AnyHashable: Any?] = [
            "itbl": [
                "defaultAction": [
                    "type": context.action.type,
                    "data": context.action.data
                ]
            ],
            "source": source
        ]
        
        if let presentedViewController = getRootViewController()?.presentedViewController {
            // Dismiss presented view controller before handling action
            LogUtils.debug(message: "Dismissing presented view controller \(presentedViewController)")
            getRootViewController()?.dismiss(animated: true) {
                channel.invokeMethod("actionHandler", arguments: arguments)
            }
        } else {
            channel.invokeMethod("actionHandler", arguments: arguments)
        }
        
        LogUtils.debug(message: "notifyIterableAction with data \(arguments)")
    }
    
    private func getWindow() -> UIWindow? {
        var keyWindow: UIWindow? = nil
        for window in UIApplication.shared.windows {
            if window.isKeyWindow {
                keyWindow = window
                break
            }
        }
        return keyWindow
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let window = getWindow() else { return nil }
        
        return window.rootViewController
    }
}

// MARK: IterableInAppDelegate
extension SwiftIterableFlutterPlugin: IterableInAppDelegate {
    
    public func onNew(message: IterableInAppMessage) -> InAppShowResponse {
        return .show
    }
}

// MARK: IterableURLDelegate
extension SwiftIterableFlutterPlugin: IterableURLDelegate {
    
    public func handle(iterableURL url: URL, inContext context: IterableActionContext) -> Bool {
        notifyIterableAction(context)
        return true
    }
}

// MARK: IterableCustomActionDelegate
extension SwiftIterableFlutterPlugin: IterableCustomActionDelegate {
    
    public func handle(iterableCustomAction action: IterableAction, inContext context: IterableActionContext) -> Bool {
        notifyIterableAction(context)
        return true
    }
}

// MARK: AppDelegate
extension SwiftIterableFlutterPlugin {
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        var launchOptionsWithKeys: [UIApplication.LaunchOptionsKey: Any] = [:]
        for option in launchOptions {
            if let key = option.key as? String {
                launchOptionsWithKeys[UIApplication.LaunchOptionsKey(rawValue: key)] = option.value
            }
        }
        self.launchOptions = launchOptionsWithKeys
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IterableAPI.register(token: deviceToken)
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LogUtils.debug(message: "didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    // Silent Push for in-app
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        // Ensure it's an iterable notification
        guard userInfo.contains(where: { $0.key as? String == "itbl"}) else { return false }
        
        IterableAppIntegration.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        return true
    }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        
        // Ensure it's an universal link
        guard let url = userActivity.webpageURL, isIterableDeepLink(url.absoluteString) else {
            return false
        }
        
        // This tracks the click, retrieves the original URL, and uses it to
        // call handleIterableURL:context:
        return IterableAPI.handle(universalLink: url)
    }
    
    private func isIterableDeepLink(_ urlString: String) -> Bool {
        let ITBL_DEEPLINK_REGEX = "/a/[a-zA-Z0-9]+"
        guard let regex = try? NSRegularExpression(pattern: ITBL_DEEPLINK_REGEX, options: []) else {
            return false
        }
        
        return regex.firstMatch(in: urlString, options: [], range: NSMakeRange(0, urlString.count)) != nil
    }
}
// MARK: UNUserNotificationCenterDelegate
extension SwiftIterableFlutterPlugin: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list])
        } else {
            // Fallback on earlier versions
            completionHandler([.badge, .sound, .alert])
        }
    }
    
    // Background push notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        IterableAppIntegration.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
