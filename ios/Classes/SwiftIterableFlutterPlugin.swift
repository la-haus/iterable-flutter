import Flutter
import UIKit
import IterableSDK
import UserNotifications

public class SwiftIterableFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "iterable_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftIterableFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    //appDelegate
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
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func initialize(_ apiKey: String, _ pushIntegrationName: String){
        let config = IterableConfig()
        config.pushIntegrationName = pushIntegrationName
        config.autoPushRegistration = true
        IterableAPI.initialize(apiKey: apiKey, config: config)
    
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("===== Permission granted: \(granted)")
        }
    }
    
    private func getPropertiesFromArguments(_ callArguments: Any?) -> [String: Any] {
            if let arguments = callArguments as? [String: Any] {
                return arguments;
            }
            return [:];
        }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IterableAPI.register(token: deviceToken)
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        print("===== Token: \(tokenParts.joined())")
    }
}
