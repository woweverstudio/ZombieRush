//
//  ToastManager.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

@Observable
final class ToastManager {
    static let shared = ToastManager()
        
    var currentToast: ToastMessage? = nil
    
    private init() {}
    
    func show(_ toast: ToastMessage) {
        currentToast = toast
    }
    
    func show(_ toastMessageCase: ToastMessageCase) {
        show(toastMessageCase.toast)
    }
    
    func clear() {
        currentToast = nil
    }
}
