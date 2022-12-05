//
//  LogUtils.swift
//  iterable_flutter
//
//  Created by Alex Queudot on 22/11/22.
//

import Foundation

struct LogUtils {
    static var enabled: Bool = true
    
    static func debug(message: String, tag: String = "SwiftIterableFlutterPlugin") {
        if enabled {
            print("\(tag): \(message)")
        }
    }
}
