//
//  Endpoint.swift
//
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Alamofire
import Moya
import RxMoya

class DefaultAlamofireSession: Alamofire.Session {
    static let sharedSession: DefaultAlamofireSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        configuration.timeoutIntervalForRequest = 20   // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireSession(configuration: configuration)
    }()
}

let provider = MoyaProvider<Endpoint>(
    session: DefaultAlamofireSession.sharedSession,
    plugins: [NetworkLoggerPlugin(), SignaturePlugin()]
)

let url = "https://api.cryptoless.io"
let socketURL = "https://connect.cryptoless.net"
let testSocketURL = "http://52.77.230.103:4001"

public enum Endpoint {
    case register(_ ownerPublicKey: String)
    case networks(_ latestUpdatedAt: UInt64)
    case deployAccount(_ networkCode: String, _ publicKeys: [String], _ threshold: Int)
    case accounts(_ publicKeys: [String])
    case transactions(_ status: String, _ limit: Int = 10, _ offset: Int = 0)
    case signTransaction(_ id: String, _ signatures: [Transaction.Signature])
    case sendTransaction(_ id: String)
    case coins(_ latestUpdatedAt: UInt64 = 0)
    case holders(_ latestUpdatedAt: UInt64 = 0)
    case delegators(_ latestUpdatedAt: String? = nil)
    case instructions(_ latestUpdatedAt: UInt64 = 0)
    case balanceTransactions(_ symbol: String, _ address: String)
    case stakings(_ latestUpdatedAt: UInt64 = 0)
    case transfer(_ symbol: String, _ networkCode: String, _ from: String, _ to: String, _ amount: String)
    case stake(_ symbol: String, _ networkCode: String, _ from: String, _ amount: String)
    case unstake(_ symbol: String, _ networkCode: String, _ from: String, _ amount: String)
    case claim(_ symbol: String, _ networkCode: String, _ from: String)
}

extension Endpoint: TargetType{
    public var baseURL: URL {
        return URL(string: url)!
    }
    public var path: String {
        switch self {
        case .register(_): return "/registrations"
        case .networks:
            return "/networks"
        case .deployAccount(let networkCode, _, _):
            return "/networks/\(networkCode)/accounts"
        case .accounts:
            return "/accounts"
        case .transactions:
            return "/transactions"
        case .signTransaction(let id, _):
            return "/transactions/\(id)/signatures"
        case .sendTransaction(let id):
            return "/transactions/\(id)"
        case .coins:
            return "/cryptocurrencies"
        case .holders:
            return "/cryptocurrencies/holders"
        case .delegators:
            return "/staking/delegators"
        case .instructions:
            return "/instructions"
        case .balanceTransactions(let symbol, _):
            return "/cryptocurrencies/\(symbol)/transactions"
        case .stakings:
            return "/staking"
        case .transfer(let symbol, _, _, _, _):
            return "/cryptocurrencies/\(symbol)/transfers"
        case .stake:
            return "/staking/delegations"
        case .unstake:
            return "/staking/unbondings"
        case .claim:
            return "/staking/claims"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .register, .deployAccount, .signTransaction, .transfer, .stake, .unstake, .claim:
            return .post
        case .sendTransaction:
            return .patch
        default:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case .register, .deployAccount, .signTransaction, .transfer, .stake, .unstake, .claim:
            return .requestParameters(parameters: signedParams, encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: signedParams, encoding: JSONEncoding.default)
        }
    }
    
    public var sampleData: Data { return Data() }
    public var headers: [String: String]? { return nil }
}

extension Endpoint {
    public var requestParams: [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .register(let ownerPublicKey):
            params["ownerPublicKey"] = ownerPublicKey
            return params
        case .networks(let latestUpdatedAt):
            params["filter"] = "updatedTime:\(latestUpdatedAt).."
            params["limit"] = "10000" // all
            return params
        case .deployAccount(_, let publicKeys, let threshold):
            params["publicKeys"] = publicKeys
            params["threshold"] = threshold
            return params
        case .accounts(let publicKeys):
            params["includePublicKeys"] = publicKeys.joined(separator: ",")
            params["limit"] = "10000" // all
            return params
        case .transactions(let status, let limit, let offset):
            params["status"] = status
            params["limit"] = String(limit)
            params["offset"] = String(offset)
            return params
        case .signTransaction(_, let signatures):
            params["signatures"] = signatures
            return params
        case .sendTransaction:
            params["status"] = "PENDING" // make status be pending
            return params
        case .coins(let latestUpdatedAt):
            params["expand"] = "networks"
            params["filter"] = "updatedTime:\(latestUpdatedAt).."
            params["limit"] = "10000" // all
            return params
        case .holders(let latestUpdatedAt):
            params["filter"] = "updatedTime:\(latestUpdatedAt).."
            params["limit"] = "10000" // all
            return params
        case .delegators(let latestUpdatedAt):
            params["filter"] = "updatedTime:\(dateStringToTimestamp(latestUpdatedAt ?? "")).."
            params["limit"] = "10000" // all
            params["expand"] = "staking"
            return params
        case .instructions(let latestUpdatedAt):
            params["filter"] = "updatedTime:\(latestUpdatedAt).."
            params["limit"] = "50" // default
            return params
        case .balanceTransactions:
            return params
        case .stakings(let latestUpdatedAt):
            params["filter"] = "updatedTime:\(latestUpdatedAt).."
            params["limit"] = "10000" // all
            return params
        case .transfer(_, let networkCode, let from, let to, let amount):
            params["networkCode"] = networkCode
            params["from"] = from
            params["to"] = to
            params["amount"] = amount
            return params
        case .stake(let symbol, let networkCode, let from, let amount):
            params["networkCode"] = networkCode
            params["coinSymbol"] = symbol
            params["delegator"] = from
            params["amount"] = amount
            return params
        case .unstake(let symbol, let networkCode, let from, let amount):
            params["networkCode"] = networkCode
            params["coinSymbol"] = symbol
            params["delegator"] = from
            params["amount"] = amount
            return params
        case .claim(let symbol, let networkCode, let from):
            params["networkCode"] = networkCode
            params["coinSymbol"] = symbol
            params["delegator"] = from
            return params
        }
    }
}

extension Endpoint: Signaturable {
    
    public var signatureType: SignatureType {
        return .identity(token: "Apikey f3672c3f30bf06d32f91858ab64fd384d6bb025d2d03e9f9dddb0e2196223620")
    }
}
