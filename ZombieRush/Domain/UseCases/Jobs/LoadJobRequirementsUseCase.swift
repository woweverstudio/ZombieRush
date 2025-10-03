//
//  LoadJobRequirementsUseCase.swift
//  ZombieRush
//
//  Created by Load Job Requirements UseCase
//

import Foundation
import Supabase

struct LoadJobRequirementsRequest {
    // 파라미터 없음 - 모든 요구사항 로드
}

struct LoadJobRequirementsResponse {
    let success: Bool
    let requirements: [JobUnlockRequirement]?
}

/// 직업 해금 요구사항 로드 UseCase
/// 서버에서 job_requirements 테이블을 로드하여 메모리에 저장
struct LoadJobRequirementsUseCase: UseCase {
    private let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
            supabaseKey: SupabaseConfig.supabaseAnonKey
        )
    }
    
    func execute(_ request: LoadJobRequirementsRequest) async -> LoadJobRequirementsResponse {
        do {
            // Supabase에서 job_requirements 테이블 로드
            let requirements: [JobUnlockRequirement] = try await supabase
                .from("job_requirements")
                .select("*")
                .execute()
                .value

            // JobUnlockRequirement에 저장 (정적 저장소)
            JobUnlockRequirement.loadRequirements(requirements)

            return LoadJobRequirementsResponse(success: true, requirements: requirements)
        } catch {
            ErrorManager.shared.report(.databaseRequestFailed)
            return LoadJobRequirementsResponse(success: false, requirements: nil)
        }
    }
}
