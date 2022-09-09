//
//  Models.swift
//  
//
//  Created by linshizai on 2022/6/15.
//

import Foundation
import AnyCodable

public extension Cryptoless {
    struct Network: Codable, Identifiable {
        
        public init(id: String, code: String, name: String, platform: String, derivationPath: String, iconURL: String?, blockExplorerURI: String?, feeCoin: Network.FeeCoin, evmChainId: Int16?, createdTime: String, updatedTime: String) {
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
        public let iconURL: String?
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
        public init(id: String, address: String, publicKeys: [String], threshold: Int16, networkCode: String, status: Status, createdTime: String, updatedTime: String) {
            self.id = id
            self.address = address
            self.publicKeys = publicKeys
            self.threshold = threshold
            self.networkCode = networkCode
            self.status = status
            self.createdTime = createdTime
            self.updatedTime = updatedTime
        }
        
        public let id: String
        public let address: String
        public let publicKeys: [String]
        public let threshold: Int16
        public let networkCode: String
        public let status: Status
        public let createdTime: String
        public let updatedTime: String
        
        public enum Status: Int, Codable {
            case disable = 0 // Not activated
            case pending = 1 // In activating
            case enable = 2  // Activated
        }
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
        public let body: [String: AnyCodable]
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
    
    struct SwapAddress: Codable {
        public let symbol: String
        public let address: String
    }
    
    struct SwapQuote: Codable {
        
        public let symbol: String
        public let contractAddress: String
        
        public let fromTokenAddress: String
        public let fromTokenAmount: String
        public let toTokenAddress: String
        public let toTokenAmount: String
        
        public let protocols: [Swap.Protocol_]
        public let routers: [Swap.Router]
        
        public let estimatedGas: String
    }
    
    struct Swap: Codable {
        
        public struct Protocol_: Codable {
            public let name: String
            public let part: String
            public let fromTokenAddress: String
            public let toTokenAddress: String
        }
        
        public struct Router: Codable {
            
            public let symbol: String
            public let toTokenAmount: String
            public let estimatedGas: String
            public let protocols: [Protocol_]
        }
        
        public struct Transaction: Codable {
            public let from: String
            public let to: String
            public let data: String
            public let value: String
            public let gas: Int
            public let gasPrice: String
        }
        
        public let symbol: String
        public let fromTokenAddress: String
        public let fromTokenAmount: String
        public let toTokenAddress: String
        public let toTokenAmount: String
        
        public let protocols: [Swap.Protocol_]
        public let routers: [Swap.Router]
        public let tx: Swap.Transaction
    }

}
