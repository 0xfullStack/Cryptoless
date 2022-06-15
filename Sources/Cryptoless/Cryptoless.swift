import SocketIO
import Foundation
import RxSwift
import ReactiveX

public final class Cryptoless {
    
    public var connectStatus: Observable<Bool> {
        proxy.rx.connected.share()
    }
    
    
    private let bag = DisposeBag()
    private let web3Token: String
    
    private lazy var mannager: SocketManager = {
        return SocketManager(socketURL: URL(string: socketURL)!, config: [
            .log(false), .secure(false)
        ])
    }()
    
    private lazy var proxy: SocketIOProxy = {
        return SocketIOProxy(
            manager: mannager,
            namespace: EventNamespace.default.rawValue,
            payload: ["token": web3Token]
        )
    }()
    
    public init(web3Token: String) {
        self.web3Token = web3Token
        subscribeReachability()
    }
}

// MARK: - Coins

extension Cryptoless {
    
    public func register(ownerPublicKey: String) -> Observable<Registration> {
        return provider
            .rx.request(.register(ownerPublicKey))
            .asObservable()
            .mapObject(Registration.self)
    }
    
    public func fetchNetworks(latestUpdatedAt: UInt64 = 0) -> Observable<[Network]> {
        return provider
            .rx.request(.networks(latestUpdatedAt))
            .asObservable()
            .mapObject([Network].self)
    }
    
    public func deployAccount(networkCode: String, publicKeys: [String], threshold: Int) -> Observable<Account> {
        return provider
            .rx.request(.deployAccount(networkCode, publicKeys, threshold))
            .asObservable()
            .mapObject(Account.self)
    }

    public func fetchAccounts(publicKeys: [String]) -> Observable<[Account]> {
        return provider
            .rx.request(.accounts(publicKeys))
            .asObservable()
            .mapObject([Account].self)
    }
    
    public func fetchTransactions(status: String, limit: Int = 10, offset: Int = 0) -> Observable<[Transaction]> {
        return provider
            .rx.request(.transactions(status, limit, offset))
            .asObservable()
            .mapObject([Transaction].self)
    }
    
    public func signTransaction(id: String, signatures: [Transaction.Signature]) -> Observable<Transaction> {
        return provider
            .rx.request(.signTransaction(id, signatures))
            .asObservable()
            .mapObject(Transaction.self)
    }
    
    public func sendTransaction(id: String) -> Observable<Transaction> {
        return provider
            .rx.request(.sendTransaction(id))
            .asObservable()
            .mapObject(Transaction.self)
    }
    
    public func fetchCoins(latestUpdatedAt: UInt64 = 0) -> Observable<[Coin]> {
        return provider
            .rx.request(.coins(latestUpdatedAt))
            .asObservable()
            .mapObject([Coin].self)
    }
    
    public func fetchHolders(latestUpdatedAt: UInt64 = 0) -> Observable<[Holder]> {
        return provider
            .rx.request(.holders(latestUpdatedAt))
            .asObservable()
            .mapObject([Holder].self)
    }
    
    public func fetchDelegators(latestUpdatedAt: String? = nil) -> Observable<[Delegator]> {
        return provider
            .rx.request(.delegators(latestUpdatedAt))
            .asObservable()
            .mapObject([Delegator].self)
    }
    
    public func fetchInstructions(latestUpdatedAt: UInt64 = 0) -> Observable<[Instruction]> {
        return provider
            .rx.request(.instructions(latestUpdatedAt))
            .asObservable()
            .mapObject([Instruction].self)
    }
    
    public func fetchBalanceTransactions(symbol: String, address: String) -> Observable<[BalanceTransaction]> {
        return provider
            .rx.request(.balanceTransactions(symbol, address))
            .asObservable()
            .mapObject([BalanceTransaction].self)
    }
    
    public func fetchStakings(latestUpdatedAt: UInt64 = 0) -> Observable<[Staking]> {
        return provider
            .rx.request(.stakings(latestUpdatedAt))
            .asObservable()
            .mapObject([Staking].self)
    }

    public func transfer(symbol: String, networkCode: String, from: String, to: String, amount: String) -> Observable<TransactionWapper> {
        return provider
            .rx.request(.transfer(symbol, networkCode, from, to, amount))
            .asObservable()
            .mapObject(TransactionWapper.self)
    }
    
    public func stake(symbol: String, networkCode: String, from: String, amount: String) -> Observable<TransactionWapper> {
        return provider
            .rx.request(.stake(symbol, networkCode, from, amount))
            .asObservable()
            .mapObject(TransactionWapper.self)
    }
    
    public func unstake(symbol: String, networkCode: String, from: String, amount: String) -> Observable<TransactionWapper> {
        return provider
            .rx.request(.unstake(symbol, networkCode, from, amount))
            .asObservable()
            .mapObject(TransactionWapper.self)
    }
    
    public func claim(symbol: String, networkCode: String, from: String) -> Observable<TransactionWapper> {
        return provider
            .rx.request(.claim(symbol, networkCode, from))
            .asObservable()
            .mapObject(TransactionWapper.self)
    }
}

// MARK: - Socket
extension Cryptoless {
    
    private func subscribeReachability() {
        
    }
    
    public func on(_ event: Event) -> Observable<[Any]> {
        connectStatus
            .filter { $0 }
            .flatMapLatest { [weak self] connected -> Observable<Void> in
                guard let self = self else { return .never() }
                return self.proxy.rx.emit(
                    event.action.rawValue,
                    SocketIODataItem(id: UUID(), scope: event.scope, payload: event.payload)
                )
            }
            .observe(on: MainScheduler.asyncInstance)
            .flatMapLatest { [weak self] _ -> Observable<[Any]> in
                guard let self = self else { return .never() }
                return self.proxy.rx.on(event.keyPath).map { $0.0 }
            }
    }
    
    public func off(_ event: Event) -> Observable<Void> {
        fatalError("Not implemented!!")
    }
//    public func subscribe<T: Decodable>(_ event: CryptolessEvent, type: T.Type, with callback: @escaping (Result<T, Web3Error>)->Void) {
//        let socketClient = socketManager.socket(forNamespace: event.namespace.rawValue)
//        socketClient.on(event.keyPath) { data, ack in
//            do {
//                let data: T = try event.decode(data: data)
//                callback(.success(data))
//            } catch {
//                if let err = error as? Web3Error {
//                    callback(.failure(err))
//                }
//            }
//        }
//    }
}
