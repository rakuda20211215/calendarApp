//
//  View.swift
//  calendarApp
//
//  Created by 蒔苗純平 on 2024/03/13.
//

import Foundation
import SwiftUI


extension View {
    func onLongPressRepeatGesture(maximumDistance distance: Double = 10, action: @escaping () -> Void, startedAction: @escaping () -> Void = { return }, finishedAction: @escaping () -> Void = { return }) -> some View {
        let timer = PressTimer(action: action)
        return self.onLongPressGesture(minimumDuration: .infinity, maximumDistance: distance, perform: {
            /// Press has completed successfully
            timer.stop()
        },onPressingChanged: { value in
            if value == true {
                /// Press has started
                print("timer start")
                startedAction()
                timer.start()
            } else {
                /// Press has cancelled
                print("timer stop")
                finishedAction()
                timer.stop()
            }
        })
    }
}


class PressTimer: ObservableObject {
    var timer: Timer?
    var delayTimer: Timer?
    private let executionDelay: Double
    private let interval: Double
    private let action: () -> Void
    
    init(executionDelay: Double = 500, interval: Double = 100, action: @escaping () -> Void) {
        self.executionDelay = executionDelay / 1000
        self.interval = interval / 1000
        self.action = action
    }
    
    func start() {
        delayTimer = Timer.scheduledTimer(withTimeInterval: executionDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {[weak self] _ in
                guard let self = self else { return }
                self.action()
            })
        }
    }
    
    func stop() {
        print("stop")
        self.delayTimer?.invalidate()
        self.delayTimer = nil
        self.timer?.invalidate()
        self.timer = nil
    }
}

