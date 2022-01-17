import Flutter
import UIKit
import IterableSDK
import UserNotifications

public class SwiftIterableFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    static var channel: FlutterMethodChannel? = nil
    
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
            
            initialize(apiKey, pushIntegrationName)
            
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(_ apiKey: String, _ pushIntegrationName: String){
        let config = IterableConfig()
        config.pushIntegrationName = pushIntegrationName
        config.autoPushRegistration = true
        
        IterableAPI.initialize(apiKey: apiKey, config: config)
    }
    
    private func getPropertiesFromArguments(_ callArguments: Any?) -> [String: Any] {
        if let arguments = callArguments as? [String: Any] {
            return arguments;
        }
        return [:];
    }

    func signOut() {
        IterableAPI.disableDeviceForCurrentUser()
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IterableAPI.register(token: deviceToken)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                guard granted else { return }
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
    }
    
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        IterableAppIntegration.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
        notifyPushNotificationOpened()
    }

    public func notifyPushNotificationOpened(){
        let userInfo = IterableAPI.lastPushPayload
        
        if(userInfo != nil){
            let apsInfo = userInfo!["aps"] as? [String: AnyObject]
            let alertInfo = apsInfo?["alert"] as? [String: AnyObject]
            
            if(alertInfo != nil){
                
                let payload = [
                    "title": alertInfo?["title"] ?? "",
                    "body": alertInfo?["body"] ?? "",
                    "additionalData": IterableAPI.lastPushPayload!
                ] as [String : Any]
                
                SwiftIterableFlutterPlugin.channel?.invokeMethod("openedNotificationHandler", arguments: payload)
            }
            
        }
        
   }
}
