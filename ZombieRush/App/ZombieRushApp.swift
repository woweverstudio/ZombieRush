//
//  ZombieRushApp.swift
//  ZombieRush
//
//  Created by 김민성 on 8/16/25.
//

import SwiftUI


@main
struct ZombieRushApp: App {
    // Repository instances (SSOT) - managed as StateObjects for proper lifecycle
    @StateObject var userRepository: SupabaseUserRepository
    @StateObject var statsRepository: SupabaseStatsRepository
    @StateObject var elementsRepository: SupabaseElementsRepository
    @StateObject var jobsRepository: SupabaseJobsRepository

    // UseCaseFactory with injected repositories
    @StateObject var useCaseFactory: UseCaseFactory

    @State private var appRouter = AppRouter()
    @State private var configManager = ConfigManager()
    @State private var gameKitManager = GameKitManager()
    @State private var processor = Processor()

    @State private var storeKitManager: StoreKitManager
    @State private var alertManager: AlertManager
    @State private var mapManager: MapManager
    
    init() {
        let userRepository = SupabaseUserRepository()
        let statsRepository = SupabaseStatsRepository()
        let elementsRepository = SupabaseElementsRepository()
        let jobsRepository = SupabaseJobsRepository()
        let transactionRepository = SupabaseTransactionRepository()

        // StateObject 먼저 초기화
        _userRepository = StateObject(wrappedValue: userRepository)
        _statsRepository = StateObject(wrappedValue: statsRepository)
        _elementsRepository = StateObject(wrappedValue: elementsRepository)
        _jobsRepository = StateObject(wrappedValue: jobsRepository)
        
        let alertManager = AlertManager()
        _alertManager = State(initialValue: alertManager)
        
        // Initialize UseCaseFactory with injected repositories
        let factory = UseCaseFactory(
            userRepository: userRepository,
            statsRepository: statsRepository,
            elementsRepository: elementsRepository,
            jobsRepository: jobsRepository,
            transactionRepository: transactionRepository,
            alertManager: alertManager
        )
        _useCaseFactory = StateObject(wrappedValue: factory)

        // MapManager 초기화
        let mapManager = MapManager(useCaseFactory: factory)
        _mapManager = State(initialValue: mapManager)
        
        let storekit = StoreKitManager(useCaseFactory: factory, alertManager: alertManager)
        _storeKitManager = State(initialValue: storekit)
    }

    var body: some Scene {
        WindowGroup {
            // 일반 앱 화면
            RouterView()
                .preferredColorScheme(.dark)
                .environmentObject(userRepository)
                .environmentObject(statsRepository)
                .environmentObject(elementsRepository)
                .environmentObject(jobsRepository)
                .environmentObject(useCaseFactory)
                .environment(mapManager)
                .environment(appRouter)
                .environment(gameKitManager)
                .environment(configManager)
                .environment(storeKitManager)
                .environment(alertManager)
                .environment(processor)
        }
    }

}
