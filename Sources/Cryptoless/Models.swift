//
//  Models.swift
//  
//
//  Created by linshizai on 2022/6/15.
//

import Foundation

public extension Cryptoless {
    struct Network: Codable, Identifiable {
        public init(id: String, code: String, name: String, platform: String, derivationPath: String, iconURL: String, blockExplorerURI: String?, feeCoin: Network.FeeCoin, evmChainId: Int16?, createdTime: String, updatedTime: String) {
            self.id = id
            self.code = code
            self.name = name
            self.platform = platform
            self.derivationPath = derivationPath
            self.iconURL = iconURL
            self.blockExplorerURI = blockExplorerURI
            self.feeCoin = feeCoin
            self.evmChainId = evmChainId
            self.createdTime = createdTime
            self.updatedTime = updatedTime
        }
        
        public let id: String
        public let code: String
        public let name: String
        public let platform: String
        public let derivationPath: String
        public let iconURL: String
        public let blockExplorerURI: String?
        public let feeCoin: FeeCoin
        public let evmChainId: Int16?
        public let createdTime: String
        public let updatedTime: String
        
        public struct FeeCoin: Codable {
            public init(symbol: String, decimals: UInt) {
                self.symbol = symbol
                self.decimals = decimals
            }
            
            public let symbol: String
            public let decimals: UInt
        }
        
        
    }

    struct Account: Codable, Identifiable {
        public init(id: String, address: String, publicKeys: [String], threshold: Int16, networkCode: String, enable: Bool, createdTime: String, updatedTime: String) {
            self.id = id
            self.address = address
            self.publicKeys = publicKeys
            self.threshold = threshold
            self.networkCode = networkCode
            self.enable = enable
            self.createdTime = createdTime
            self.updatedTime = updatedTime
        }
        
        public let id: String
        public let address: String
        public let publicKeys: [String]
        public let threshold: Int16
        public let networkCode: String
        public let enable: Bool
        public let createdTime: String
        public let updatedTime: String
    }

    struct DeployAccountRequest: Codable {
        public let publicKeys: [String]
        public let threshold: Int
    }

    struct Transaction: Codable, Identifiable {
        public let id: String
        public let hash: String
        public let networkCode: String
        public let serialized: String
        public let status: String
        public let fee: String?
        public let estimatedFee: String?
        public let requiredSignings: [Signing]?
        public let signatures: [Signature]?
        public let createdTime: String
        public let updatedTime: String
        
        public struct Signing: Codable {
            public let hash: String
            public let publicKeys: [String]
            public let threshold: UInt
        }
        
        public struct Signature: Codable {
            public init(hash: String, publicKey: String, signature: String) {
                self.hash = hash
                self.publicKey = publicKey
                self.signature = signature
            }
            
            public let hash: String
            public let publicKey: String
            public let signature: String
            
            func mappingToJson() -> [String: String] {
                return [
                    "hash" : hash,
                    "publicKey": publicKey,
                    "signature": signature
                ]
            }
        }
    }

    struct Coin: Codable, Identifiable {
        public let id: String
        public let symbol: String
        public let name: String
        public let iconURL: String
        public let category: String?
        public let source: Int16
        public let price: Double?
        public let marketCap: Double?
        public let createdTime: String
        public let updatedTime: String
        public let _embedded: Expand?
        
        public struct Expand: Codable {
            public var networks: [Network]?
        }
    }

    struct Holder: Codable {
        public let id: String
        public let address: String
        public let quantity: String
        public let symbol: String
        public let networkCode: String
        public let createdTime: String?
        public let updatedTime: String?
    }

    struct Staking: Codable {
        public let id: String
        public let name: String
        public let symbol: String
        public let apr: Double
        public let lockTime: Int
        public let minimumAmount: String
        public let networkCode: String
        public let createdTime: String
        public let updatedTime: String
    }

    struct Delegator: Codable {
        public let id: String
        public let address: String
        public let coinSymbol: String
        public let pendings: String
        public let staked: String
        public let rewards: String?
        public let networkCode: String
        public let createdTime: String
        public let updatedTime: String
        public let _embedded: Expand
        
        public struct Expand: Codable {
            public var staking: Staking
        }
    }

    struct Transfer: Codable {
        public let id: String
        public let from: String
        public let to: String
        public let amount: String
        public let status: Int16
        public let networkCode: String
        public let createdTime: String
        public let updatedTime: String
        public let symbol: String?
        public let _embedded: Expand?
        
        public struct Expand: Codable {
            public let transactions: [Transaction]
        }
    }

    struct TransactionWrapper: Codable {
        public let networkCode: String
        public let _embedded: Expand?
        
        public struct Expand: Codable {
            public let transactions: [Transaction]
        }
    }

    struct Instruction: Codable {
        public let id: String
        public let type: String
        public let body: [String: String]
        public let status: Int16
        public let networkCode: String
        public let createdTime: String
        public let updatedTime: String
        public let _embedded: Expand?
        
        public struct Expand: Codable {
            public let transactions: [Transaction]
        }
    }

    struct BalanceTransaction: Codable {
        public let id: String
        public let hash: String
        public let address: String
        public let amount: String
        public let symbol: String?
        public let type: Int
        public let blockHeight: Int
        public let blockTime: String
    }

    struct Registration: Codable {
        public let id: String
        public let status: String
        public let createdTime: String
        public let updatedTime: String
    }

}
