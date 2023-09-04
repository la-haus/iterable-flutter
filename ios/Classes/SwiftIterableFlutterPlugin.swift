import Flutter
import UIKit
import IterableSDK
import UserNotifications

public class SwiftIterableFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate, IterableCustomActionDelegate, IterableURLDelegate {
   
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
            let args = getPropertiesFromArguments(call.arguments)
            let email = args["email"] as! String
            let jwt = args["jwt"] as! String
            IterableAPI.setEmail(email, jwt)
            
            result(nil)
        case "setUserId":
            let userId = call.arguments as! String
            IterableAPI.userId = userId
            
            result(nil)
        case "track":
            let argumentData = call.arguments as! [String : Any] 
        
            let eventName = argumentData["event"] as! String
            guard let dataFields = argumentData["dataFields"] as? [String: Any]  else {
                IterableAPI.track(event: eventName)  
                result(nil)  
                return
            }

            IterableAPI.track(event: eventName, dataFields: dataFields)
            
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
        config.customActionDelegate = self
        config.urlDelegate = self
        
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
    }
    
    public func handle(iterableCustomAction action: IterableAction, inContext context: IterableActionContext) -> Bool {
        notifyPushNotificationOpened()
        return true;
    }

    
    public func handle(iterableURL url: URL, inContext context: IterableActionContext) -> Bool {
        notifyPushNotificationOpened()
        return true
    }
    
    public func notifyPushNotificationOpened(){
        guard let userInfo = IterableAPI.lastPushPayload,
              let apsInfo = userInfo["aps"] as? [String: AnyObject],
              let alertInfo = apsInfo["alert"] as? [String: AnyObject]
        else {
            return
        }
        
        let payload = [
            "title": alertInfo["title"] ?? "",
            "body": alertInfo["body"] ?? "",
            "additionalData": userInfo
        ] as [String : Any]
        
        SwiftIterableFlutterPlugin.channel?.invokeMethod("openedNotificationHandler", arguments: payload)
        
    }
    
}
