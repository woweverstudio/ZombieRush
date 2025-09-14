//
//  VersionManager.swift
//  ZombieRush
//
//  Created by Simple Version Check Manager with Supabase
//

import Foundation
import Supabase

@Observable
class VersionManager {
    static let shared = VersionManager()

    // MARK: - Properties
    var shouldForceUpdate = false
    var hasCheckedVersion = false
    var isCheckingVersion = false

    // Supabase 설정 - block_buster 프로젝트
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
        supabaseKey: SupabaseConfig.supabaseAnonKey
    )

    // MARK: - Public Methods

    /// 앱 시작 시 버전 체크 수행
    func checkAppVersion() async {
        guard !hasCheckedVersion else { return }

        isCheckingVersion = true
        defer { isCheckingVersion = false }

        do {
            // Supabase에서 버전 정보 가져오기
            let config = try await fetchRemoteConfig()

            // 버전 비교 및 강제 업데이트 결정
            if let forceUpdateVersion = config["force_update_version"] as? String {
                shouldForceUpdate = needsForceUpdate(currentVersion: getCurrentAppVersion(),
                                                   forceUpdateVersion: forceUpdateVersion)
            }

            hasCheckedVersion = true

        } catch {
            // 네트워크 실패 등 조회 실패시 그냥 무시하고 진행
            print("⚠️ 버전 체크 실패: \(error.localizedDescription)")
            hasCheckedVersion = true
        }
    }

    // MARK: - Public Methods

    // MARK: - Private Methods

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
