////
////  EnvironmentKeys.swift
////  ZombieRush
////
////  Created by Environment Keys for Repository Dependency Injection
////
//
//import SwiftUI
//
//// MARK: - UserRepository Environment Key
//private struct UserRepositoryKey: EnvironmentKey {
//    static let defaultValue: UserRepository = SupabaseUserRepository()
//}
//
//extension EnvironmentValues {
//    var userRepository: UserRepository {
//        get { self[UserRepositoryKey.self] }
//        set { self[UserRepositoryKey.self] = newValue }
//    }
//}
//
//// MARK: - StatsRepository Environment Key
//private struct StatsRepositoryKey: EnvironmentKey {
//    static let defaultValue: StatsRepository = SupabaseStatsRepository()
//}
//
//extension EnvironmentValues {
//    var statsRepository: StatsRepository {
//        get { self[StatsRepositoryKey.self] }
//        set { self[StatsRepositoryKey.self] = newValue }
//    }
//}
//
//// MARK: - SpiritsRepository Environment Key
//private struct SpiritsRepositoryKey: EnvironmentKey {
//    static let defaultValue: SpiritsRepository = SupabaseSpiritsRepository()
//}
//
//extension EnvironmentValues {
//    var spiritsRepository: SpiritsRepository {
//        get { self[SpiritsRepositoryKey.self] }
//        set { self[SpiritsRepositoryKey.self] = newValue }
//    }
//}
//
//// MARK: - JobsRepository Environment Key
//private struct JobsRepositoryKey: EnvironmentKey {
//    static let defaultValue: JobsRepository = SupabaseJobsRepository()
//}
//
//extension EnvironmentValues {
//    var jobsRepository: JobsRepository {
//        get { self[JobsRepositoryKey.self] }
//        set { self[JobsRepositoryKey.self] = newValue }
//    }
//}
//
//// MARK: - UseCaseFactory Environment Key
//private struct UseCaseFactoryKey: EnvironmentKey {
//    static let defaultValue: UseCaseFactory = UseCaseFactory(
//        userRepository: SupabaseUserRepository(),
//        statsRepository: SupabaseStatsRepository(),
//        spiritsRepository: SupabaseSpiritsRepository(),
//        jobsRepository: SupabaseJobsRepository()
//    )
//}
//
//extension EnvironmentValues {
//    var useCaseFactory: UseCaseFactory {
//        get { self[UseCaseFactoryKey.self] }
//        set { self[UseCaseFactoryKey.self] = newValue }
//    }
//}
