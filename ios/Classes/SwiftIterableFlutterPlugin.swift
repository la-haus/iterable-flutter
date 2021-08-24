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
    let args = getPropertiesFromArguments(call.arguments)
    
    switch (call.method) {
    case "initialize":
        let apiKey = args["apiKey"] as! String
        let pushIntegrationName = args["pushIntegrationName"] as! String
        
        initialize(apiKey, pushIntegrationName)
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
    
    private func initialize(_ apiKey: String, _ pushIntegrationName: String){
        let config = IterableConfig()
        config.pushIntegrationName = pushIntegrationName
        IterableAPI.initialize(apiKey: apiKey, config: config)
    }
    
    private func getPropertiesFromArguments(_ callArguments: Any?) -> [String: Any] {
            if let arguments = callArguments as? [String: Any] {
                return arguments;
            }
            return [:];
        }
}
