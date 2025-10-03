//
//  RPCDecoder.swift
//  ZombieRush
//
//  Created by Supabase RPC JSON Decoder with custom date support
//

import Foundation

/// Supabase RPC 호출을 위한 JSON 디코딩 유틸리티
/// PostgreSQL to_char 형식의 날짜를 지원
final class RPCDecoder {

    /// RPC 응답을 위한 JSONDecoder 반환
    /// PostgreSQL to_char('YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') 형식 지원
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // PostgreSQL to_char format: 2024-01-01T12:00:00.123456Z
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatter.date(from: dateString) {
                return date
            }

            // ISO8601 fallback
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }

            // RFC3339 fallback
            let rfc3339Formatter = DateFormatter()
            rfc3339Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            rfc3339Formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = rfc3339Formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode RPC date: \(dateString)"
            )
        }

        return decoder
    }

    /// 간단한 RPC 응답 파싱용 헬퍼 메서드
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = makeDecoder()
        return try decoder.decode(type, from: data)
    }

    /// RPC 응답 파싱용 헬퍼 메서드 (타입 명시)
    static func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = makeDecoder()
        return try decoder.decode(type, from: data)
    }
}
