//
//  Helper.swift
//  
//
//  Created by linshizai on 2022/6/15.
//

import Foundation
import RxSwift
import Moya
import Serialization

func dateStringToTimestamp(_ dateString: String) -> UInt64 {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
    let date = formatter.date(from: dateString)
    return UInt64(date?.timeIntervalSince1970 ?? 0)
}

public struct CryptolessError: Error, Decodable {
    var code: Int
    var message: String
}

/// Extension for processing Responses into objects objects through JSONDecoder
public extension ObservableType where Element == Response {

    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            let extractor = mappingToExtractor(for: response, keyPath: keyPath)
            let element = try response.mapObject(T.self, atKeyPath: keyPath, extractor: extractor)
            return .just(element)
        }
    }
}

// MARK: - Single

/// Extension for processing Responses into  objects through JSONDecoder
public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            let extractor = mappingToExtractor(for: response, keyPath: keyPath)
            return .just(try response.mapObject(type, atKeyPath: keyPath, extractor: extractor))
        }
    }
}

private func mappingToExtractor(for response: Response, keyPath: String? = nil) -> Extrator {
    return Extrator { data in
        let validRange: ClosedRange<Int> = 200...299
        let currentRange: ClosedRange<Int> = response.statusCode...response.statusCode
        if currentRange.overlaps(validRange) {
            return try response.extractRaw(atKeyPath: keyPath)
        } else if let object = try? JSONDecoder().decode(CryptolessError.self, from: data) {
            throw MoyaError.objectMapping(object, response)
        } else {
            throw MoyaError.statusCode(response)
        }
    }
}

public extension ObservableType where Element == [Any] {
    func mapObject<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> Observable<T> where T: Decodable {
        return self.map { data -> T in
            let decoder = decoder ?? JSONDecoder()
            let dic = data.first as? [String: Any]
            let array = dic?["data"] as? [Any]
            let jsonData = try JSONSerialization.data(withJSONObject: array ?? [], options: .prettyPrinted)
            return try decoder.decode(T.self, from: jsonData)
        }
    }
}
