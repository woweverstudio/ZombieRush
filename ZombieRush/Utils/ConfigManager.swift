//
//  VersionManager.swift
//  ZombieRush
//
//  Created by Simple Version Check Manager with Supabase
//

import Foundation
import Supabase

@Observable
final class ConfigManager {
    // MARK: - Properties
    var isUnavailableService = false // 서비스 불가능 여부 (true면 서비스 불가)
    var shouldForceUpdate = false // 강제 업데이트 필요 여부 (true면 강제 업데이트)

    // Supabase 설정 - block_buster 프로젝트
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
        supabaseKey: SupabaseConfig.supabaseAnonKey
    )

    // MARK: - Public Methods

    /// 앱 시작 시 서비스 사용 가능 여부와 버전 체크 수행
    func checkServerConfig() async -> Bool {
        do {
            // Supabase에서 최소버전 및 서비스 가능 여부 가져오기
            let config = try await fetchRemoteConfig()
            
            // 서비스 가능 여부 체크
            if let serviceAvailable = config["is_service_available"] as? String {
                self.isUnavailableService = serviceAvailable.lowercased() == "false"
            } else {
                return false
            }
            
            if let forceUpdateVersion = config["force_update_version"] as? String {
                self.shouldForceUpdate = needsForceUpdate(currentVersion: getCurrentAppVersion(),
                                                   forceUpdateVersion: forceUpdateVersion)
            } else {
                return false
            }
            
            if (isUnavailableService || shouldForceUpdate) { // 둘 중 하나라도 true면 로딩 중단
                return false
            } else {
                return true // 조회 성공 후 둘 다 해당 사항 없으면 true 리턴 -> 프로세스 계속 진행
            }
        } catch {
            return false
        }
    }

    /// Supabase에서 remote_config 테이블 데이터 가져오기
    private func fetchRemoteConfig() async throws -> [String: Any] {
        // Supabase Swift SDK 최신 API 사용
        let configItems: [RemoteConfigItem] = try await supabase
            .from("remote_config")
            .select("key, value")
            .execute()
            .value

        // 키-값 쌍으로 변환 (간단하게 문자열 그대로 사용)
        var config = [String: Any]()
        for item in configItems {
            config[item.key] = item.value
        }

        return config
    }

    // MARK: - Remote Config Item Model
    private struct RemoteConfigItem: Decodable {
        let key: String
        let value: String
    }

    /// 현재 앱 버전 가져오기
    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// 강제 업데이트 필요 여부 판단
    private func needsForceUpdate(currentVersion: String, forceUpdateVersion: String) -> Bool {
        return compareVersions(currentVersion, forceUpdateVersion) == .orderedAscending
    }

    /// 버전 비교 함수
    private func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }

        let maxLength = max(v1Components.count, v2Components.count)

        for i in 0..<maxLength {
            let v1 = i < v1Components.count ? v1Components[i] : 0
            let v2 = i < v2Components.count ? v2Components[i] : 0

            if v1 < v2 {
                return .orderedAscending
            } else if v1 > v2 {
                return .orderedDescending
            }
        }

        return .orderedSame
    }
}
