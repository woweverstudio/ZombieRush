import Foundation

// MARK: - Map Unlock Requirement
struct MapUnlockRequirement {
    let elementType: ElementType
    let requiredCount: Int

    var description: String {
        "\(elementType.localizedDisplayName) \(requiredCount)개"
    }
}

// MARK: - Map Model
struct Map: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String  // isometric 이미지 이름
    let totalWaves: Int
    let clearedWave: Int   // 플레이어가 클리어한 최종 웨이브
    let unlockRequirement: MapUnlockRequirement?
    
    // 계산 프로퍼티들
    var progressPercentage: Double {
        Double(clearedWave) / Double(totalWaves)
    }

    var isCompleted: Bool {
        clearedWave >= totalWaves
    }

    var isUnlocked: Bool {
        unlockRequirement == nil // 해금 조건이 없으면 기본 해금
    }

    // 해금 조건 체크 (실제로는 elementsRepository에서 확인)
    func isUnlockable(with elements: [ElementType: Int]) -> Bool {
        guard let requirement = unlockRequirement else { return true }
        return (elements[requirement.elementType] ?? 0) >= requirement.requiredCount
    }
    
    static func ==(lhs: Map, rhs: Map) -> Bool {
        lhs.id == rhs.id
    }
    
    // 해시도 id만 사용 (==와 일관)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
