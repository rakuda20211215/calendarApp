//
//  CustomColor.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2023/11/12.
//

import Foundation
import SwiftUI

class CustomColor: ObservableObject {
    // ホーム 後ろ
    var homeBack: Color
    var foreGround: Color
    var backGround: Color
    var calendarBack: Color
    var cancel: Color = .red
    var complete: Color = .blue
    var invalid: Color
    var workdays: Color = .black
    var sundays: Color = .blue
    var holidays: Color = .red
    var past: Color
    
    init(foreGround: Color, backGround: Color) {
        self.foreGround = foreGround
        self.backGround = backGround
        self.invalid = foreGround.opacity(0.8)
        self.homeBack = foreGround.opacity(0.8)
        self.calendarBack = backGround
        self.past = homeBack.opacity(0.3)
        
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(foreGround.opacity(0.5))], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(foreGround)], for: .selected)
    }
}
