//
//  ErrorManager.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

@Observable
final class AlertManager {
    var currentError: SystemError? = nil
    var currentToast: ToastMessage? = nil
    
    init() {}
    
    func showError(_ error: SystemError) {
        currentError = error
    }
    
    func showToast(_ toast: ToastMessage) {
        currentToast = toast
    }
    
    func clearError() {
        currentError = nil
    }
    
    func clearToast() {
        currentToast = nil
    }
}

