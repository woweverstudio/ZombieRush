//
//  ErrorManager.swift
//  ZombieRush
//
//  Created by 김민성 on 9/26/25.
//

import SwiftUI

@Observable
final class ErrorManager {
    static let shared = ErrorManager()
    
    var currentError: SystemError? = nil
    
    init() {}
    
    func report(_ errorCase: SystemErrorCase) {
        currentError = errorCase.error
    }
    
    func report(_ error: SystemError) {
        currentError = error
    }
    
    func clear() {
        currentError = nil
    }
}

