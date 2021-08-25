import Flutter
import UIKit
import IterableSDK

public class SwiftIterableFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "iterable_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftIterableFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
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
}

extension SwiftIterableFlutterPlugin: IterableURLDelegate {

    public func handle(iterableURL url: URL, inContext context: IterableActionContext) -> Bool {
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let webpageURL = userActivity.webpageURL else {
            return false
        }

        return IterableAPI.handle(universalLink: webpageURL)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("======= deviceToken \(deviceToken)")
        
        IterableAPI.register(token: deviceToken)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        IterableAppIntegration.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }
}
