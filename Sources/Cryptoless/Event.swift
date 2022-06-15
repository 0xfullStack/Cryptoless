//
//  Event.swift
//  
//
//  Created by linshizai on 2022/6/15.
//

import Foundation
import SocketIO

enum EventNamespace: String {
    case `default` = "/"
}

struct SocketIODataItem: Codable, SocketData {
    let id: UUID
    let scope: String
    let payload: [String: String]

    func socketRepresentation() -> SocketData {
        return [
            "id": id.uuidString,
            "scope": [scope],
            "payload": payload
        ]
    }
}

public enum Event {
    case holder
    case instruction

    var scope: String {
        switch self {
        case .holder: return "holders"
        case .instruction: return "instructions"
        }
    }

    var payload: [String: String] {
        return [:]
    }

    var action: Action {
        return .subscribe
    }

    enum Action: String {
        case get, subscribe, unsubscribe
    }

    var namespace: EventNamespace {
        return .default
    }

    // For subscribe or unsubscribe event
    var keyPath: String {
        return "receive \(scope)"
    }

//    func decode<T: Decodable>(data: [Any]) throws -> T {
//        guard let dic = data.first as? [String: Any] else {
//            return
//        }
//        guard let array = dic["data"] as? [Any] else {
//            return
//        }
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
//            let objects = try JSONDecoder().decode(T.self, from: jsonData)
//            return objects
//        } catch {
//            throw Web3Error.wrongJsonFromat(error)
//        }
//    }
}
