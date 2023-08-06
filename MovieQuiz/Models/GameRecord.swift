import Foundation

struct GameRecord: Codable { /// значит, что структура является Decodable и Encodadle
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
}
 
