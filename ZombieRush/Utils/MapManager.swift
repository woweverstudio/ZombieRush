import Foundation

// MARK: - Map Manager (ViewModel)
@MainActor
@Observable
final class MapManager {
    // MARK: - Properties
    var maps: [Map] = []
    var selectedMap: Map?

    // MARK: - Private Properties
    private let useCaseFactory: UseCaseFactory

    // MARK: - Initialization
    init(useCaseFactory: UseCaseFactory) {
        self.useCaseFactory = useCaseFactory
        setupMaps()
    }

    // MARK: - Map Data Setup (임시 데이터)
    private func setupMaps() {
        maps = [
            Map(
                id: UUID(),
                name: "네모의 숲",
                description: "신비로운 숲 속에서 시작되는 모험. 나무들 사이로 숨어든 좀비들을 처치하세요.",
                imageName: "world_forest",
                totalWaves: 5,
                clearedWave: 5,
                unlockRequirement: nil  // 기본 해금
            ),
            Map(
                id: UUID(),
                name: "성벽 입구",
                description: "고대 성벽의 입구를 지키는 수호자들. 전략적으로 접근하여 승리를 쟁취하세요.",
                imageName: "world_castle",
                totalWaves: 8,
                clearedWave: 3,
                unlockRequirement: MapUnlockRequirement(
                    elementType: .fire,
                    requiredCount: 20
                )
            ),
            Map(
                id: UUID(),
                name: "지하 동굴",
                description: "어두운 동굴 속 깊은 곳에서 기다리는 위협. 횃불을 밝히며 전진하세요.",
                imageName: "world_cave",
                totalWaves: 10,
                clearedWave: 0,
                unlockRequirement: MapUnlockRequirement(
                    elementType: .dark,
                    requiredCount: 30
                )
            )
        ]
    }

    // MARK: - Public Methods
    func selectMap(_ map: Map) {
        selectedMap = map
    }

    // MARK: - Server Communication (TODO: 추후 구현)
    func loadMapsFromServer() async {
        // TODO: 서버에서 맵 데이터 로드
        // 현재는 임시 데이터 사용
    }

    func updateMapProgress(for map: Map, clearedWave: Int) async {
        // TODO: 서버에 진행도 업데이트
        if let index = maps.firstIndex(where: { $0.id == map.id }) {
            maps[index] = Map(
                id: map.id,
                name: map.name,
                description: map.description,
                imageName: map.imageName,
                totalWaves: map.totalWaves,
                clearedWave: clearedWave,
                unlockRequirement: map.unlockRequirement
            )
        }
    }
}
