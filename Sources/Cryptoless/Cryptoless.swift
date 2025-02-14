import SocketIO
import Foundation
import RxSwift
import ReactiveX
import Reachability
import UIKit

public final class Cryptoless {
    
    public enum Environment {
        case production(web3Token: String)
        case development(web3Token: String)
        
        var token: String {
            switch self {
            case .production(let web3Token):
                return web3Token
            case .development(let web3Token):
                return web3Token
            }
        }
    }
    
    public var connectStatus: Observable<Bool> {
        proxy.rx.connected.share()
    }
    
    private var reachabilityBag = DisposeBag()
    private lazy var reachability: Reachability? = {
        Reachability()
    }()
    private lazy var reachabilitySignal: Observable<Bool> = {
        reachability?.rx.isReachable ?? .never()
    }()
    
    private lazy var mannager: SocketManager = {
        return SocketManager(socketURL: URL(string: testSocketURL)!, config: [
            .log(true), .secure(false)
        ])
    }()
    
    private lazy var proxy: SocketIOProxy = {
        return SocketIOProxy(
            manager: mannager,
            namespace: EventNamespace.default.rawValue,
            payload: ["token": requestToken]
        )
    }()
    
    private let env: Environment
    public init(env: Environment) {
        self.env = env
        requestToken = env.token
    }
}

// MARK: - HTTP Without Token
extension Cryptoless {
    public static func register(ownerPublicKey: String) -> Observable<Registration> {
        return provider
            .rx.request(.register(ownerPublicKey))
            .asObservable()
            .mapObject(Registration.self)
    }
}

// MARK: - HTTP With Token
extension Cryptoless {
    
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
    
    public func fetchDelegators() -> Observable<[Delegator]> {
        return provider
            .rx.request(.delegators)
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

    public func transfer(symbol: String, networkCode: String, from: String, to: String, amount: String) -> Observable<TransactionWrapper> {
        return provider
            .rx.request(.transfer(symbol, networkCode, from, to, amount))
            .asObservable()
            .mapObject(TransactionWrapper.self)
    }
    
    public func stake(symbol: String, networkCode: String, from: String, amount: String) -> Observable<TransactionWrapper> {
        return provider
            .rx.request(.stake(symbol, networkCode, from, amount))
            .asObservable()
            .mapObject(TransactionWrapper.self)
    }
    
    public func unstake(symbol: String, networkCode: String, from: String, amount: String) -> Observable<TransactionWrapper> {
        return provider
            .rx.request(.unstake(symbol, networkCode, from, amount))
            .asObservable()
            .mapObject(TransactionWrapper.self)
    }
    
    public func claim(symbol: String, networkCode: String, from: String) -> Observable<TransactionWrapper> {
        return provider
            .rx.request(.claim(symbol, networkCode, from))
            .asObservable()
            .mapObject(TransactionWrapper.self)
    }
    
    public func addCustomToken(networkCode: String, address: String) -> Observable<Coin> {
        return provider
            .rx.request(.addCustomToken(networkCode, address))
            .asObservable()
            .mapObject(Coin.self)
    }
    
    public func swapAddress(chainId: String) -> Observable<SwapAddress> {
        return provider
            .rx.request(.swapAddress(chainId: chainId))
            .asObservable()
            .mapObject(SwapAddress.self)
    }
    
    public func swapQuote(chainId: String, from: String, to: String, amount: String) -> Observable<SwapQuote> {
        return provider
            .rx.request(.swapQuote(chainId: chainId, from: from, to: to, amount: amount))
            .asObservable()
            .mapObject(SwapQuote.self)
    }
    
    public func swap(chainId: String, from: String, to: String, amount: String, slippage: String) -> Observable<Swap> {
        return provider
            .rx.request(.swap(chainId: chainId, from: from, to: to, amount: amount, slippage: slippage))
            .asObservable()
            .mapObject(Swap.self)
    }
}

// MARK: - WebSocket
extension Cryptoless {
    
    private func subscribeReachability() {
        releaseBag()
        let reachable = reachabilitySignal.filter { $0 }.startWith(true).map { _ in () }
        let enterForeground = UIApplication.rx.willEnterForeground.asObservable().startWith(())
        Observable
            .combineLatest(connectStatus, reachable, enterForeground)
            .subscribe(onNext: { [weak self] (connectStatus, reachable, enterForeground) in
                guard let self = self else { return }
                guard !connectStatus else { return }
                self.proxy.connectIfNeed()
            })
            .disposed(by: reachabilityBag)
    }
    
    private func releaseBag() {
        reachabilityBag = DisposeBag()
    }
    
    public func subscribe(_ event: Event) -> Observable<[Any]> {
        connectStatus
            .filter { $0 }
            .flatMapLatest { [weak self] connected -> Observable<Void> in
                guard let self = self else { return .never() }
                self.subscribeReachability()
                return self.proxy.rx.emit(
                    Event.Action.subscribe.rawValue,
                    SocketIODataItem(id: UUID(), scope: event.scope, payload: event.payload)
                )
            }
            .observe(on: MainScheduler.asyncInstance)
            .flatMapLatest { [weak self] _ -> Observable<[Any]> in
                guard let self = self else { return .never() }
                return self.proxy.rx.on(event.keyPath).map { $0.0 }
            }
    }
    
    public func unsubscribe(_ event: Event) -> Observable<Void> {
        connectStatus
            .filter { $0 }
            .flatMapLatest { [weak self] connected -> Observable<Void> in
                guard let self = self else { return .never() }
                return self.proxy.rx.emit(
                    Event.Action.unsubscribe.rawValue,
                    SocketIODataItem(id: UUID(), scope: event.scope, payload: event.payload)
                )
            }
    }
    
    public func disconnect() {
        releaseBag()
        proxy.disconnected()
    }
    
    public func connect() {
        releaseBag()
        proxy.connectIfNeed()
    }
}
