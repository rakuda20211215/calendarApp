//
//  CGColor.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/05.
//

import Foundation
import CoreGraphics

extension CGColor {
    var componentsFloat: [Float]? {
        guard let components = self.components else { return nil }
        return components.map({Float($0)})
    }
    
    static func fromFloats(floats: [Float]) -> CGColor? {
        let cgFloats = floats.map({ CGFloat($0) })
        if cgFloats.count == 2 {
            return self.init(gray: cgFloats[0], alpha: cgFloats[1])
        } else if cgFloats.count == 3 {
            return self.init(red: cgFloats[0], green: cgFloats[1], blue: cgFloats[2], alpha: 1)
        } else if cgFloats.count == 4 {
            return self.init(red: cgFloats[0], green: cgFloats[1], blue: cgFloats[2], alpha: cgFloats[3])
        } else {
            return nil
        }
    }
    
    // alpha は無視
    func colorToHex() -> String? {
        guard let componentsFloat = self.componentsFloat else { return nil }
        let componentsHex = componentsFloat.map({String(format: "%02x", Int($0 * 255))})
        if componentsFloat.count == 2 {
            guard let grayHex = componentsHex.first else { return nil }
            return "#\(grayHex)\(grayHex)\(grayHex)"
        } else if componentsFloat.count == 4 {
            return "#\(componentsHex[0])\(componentsHex[1])\(componentsHex[2])"
        } else {
            return nil
        }
    }
    
    static func hexToColor(hex: String) -> CGColor? {
        var hex = hex
        if hex.prefix(1) == "#" {
            hex = String(hex.dropFirst())
        }
        
        guard hex.filter({$0.isHexDigit}).count == hex.count else { return nil }
        
        var floatRGB: [Float] = []
        if hex.count == 3 {
            floatRGB = hex.map({Int(String($0), radix: 16) ?? -1}).map({Float($0) / 15}).filter({$0 >= 0})
        } else if hex.count == 6 {
            for i in 0..<3 {
                let index = i * 2
                guard let start = hex.index(hex.startIndex, offsetBy: index, limitedBy: hex.endIndex),
                      let end = hex.index(hex.startIndex, offsetBy: index + 1, limitedBy: hex.endIndex),
                      let intHex = Int(hex[start...end], radix: 16) else { continue }
                floatRGB.append(Float(intHex) / 255)
            }
        } else {
            return nil
        }
        
        guard floatRGB.count == 3 else { return nil }
        return CGColor.fromFloats(floats: floatRGB)
    }

}
