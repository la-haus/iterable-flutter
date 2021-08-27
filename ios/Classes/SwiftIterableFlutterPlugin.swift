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
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        registerForPushNotifications()
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            print("===== Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
      }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          print("===== Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
        }
      }
}
