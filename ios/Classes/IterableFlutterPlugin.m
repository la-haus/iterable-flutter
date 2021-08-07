#import "IterableFlutterPlugin.h"
#if __has_include(<iterable_flutter/iterable_flutter-Swift.h>)
#import <iterable_flutter/iterable_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "iterable_flutter-Swift.h"
#endif

@implementation IterableFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIterableFlutterPlugin registerWithRegistrar:registrar];
}
@end
