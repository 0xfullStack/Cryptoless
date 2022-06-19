import XCTest
@testable import Cryptoless
import Signer
import RxSwift
import Moya

final class CryptolessTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Cryptoless().text, "Hello, World!")
    }
    
    
    let bag = DisposeBag()
    let cryptoless = Cryptoless(
        web3Token:"eyJib2R5IjoiV2ViMyBUb2tlbiBWZXJzaW9uOiAyXG5Ob25jZTogODA4MDc3Nzdcbklzc3VlZCBBdDogU2F0LCAxOCBKdW4gMjAyMiAwODo0Njo0OSBHTVRcbkV4cGlyYXRpb24gVGltZTogU3VuLCAxOCBKdW4gMjAyMyAwODo0Njo0OSBHTVQiLCJzaWduYXR1cmUiOiIweDZkY2JiY2Q1MmVhYmU0NTEwN2NjOWExMTMxMzYzMDZiOTY2YTExNWFhODY0YWI1ZGFkYTU5NWI0ODYyMjg4OTQxZWE3MDcwMDE2ODdjNmQ0MDRiYjY0NTc3YjI5ZjE2MjkwZjkxMzJmNGI4NTFhMjhjNjJiMDI4MWMwMmFmM2QzMWMifQ=="
    )
    let testSeedPhrase = "protect notable remember dress swamp wife train thrive blur spirit claw charge arch enhance crumble"
    
    func testFetchNetworks() {
        let expectation = XCTestExpectation(description: "Fetching networks")
        cryptoless
            .fetchNetworks()
            .subscribe(onNext: { networks in
                print("=================================================================")
                print("Networks: \(networks)")
                print("=================================================================")
                expectation.fulfill()
            }, onError: { err in
                if case MoyaError.objectMapping(let error, _) = err, let cryptolessError = error as? CryptolessError {
                    print("ErrorCode: \(cryptolessError.code) =====>> Msg: \(cryptolessError.message)")
                }
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: TimeInterval(10000))
    }
    
    func testEthereumTransfer() throws {
        let expectation = XCTestExpectation(description: "Making Ethereum transfer")
        let networkId = "eth"
        let coinId = "eth"
        
        let wallet = try HDWallet(testSeedPhrase)
        let key = wallet.deriveKeyPair(path: "m/44'/60'/0'/0/")
        
        cryptoless
            .transfer(
                symbol: coinId,
                networkCode: networkId,
                from: "0xADB6e54257207d6B5df204Aa4038C4B64B9586f1",
                to: "0xADB6e54257207d6B5df204Aa4038C4B64B9586f1",
                amount: "0.001"
            )
            .flatMapLatest({ [weak self] transfer -> Observable<Cryptoless.Transaction> in
                guard let self = self else { return .never() }
                print("=================================================================")
                print("1. Make Transfer: \(transfer)")
                print("=================================================================")
                
                let tx = transfer._embedded!.transactions.first!
                let signing = tx.requiredSignings!.first!
                let sig = try! key.sign([UInt8](hex: signing.hash))
                let signatures = Cryptoless.Transaction.Signature(
                    hash: signing.hash,
                    publicKey: signing.publicKeys.first!,
                    signature: sig.toHexString()
                )
                return self.cryptoless.signTransaction(id: tx.id, signatures: [signatures])
            })
            .flatMapLatest({ [weak self] transaction -> Observable<Cryptoless.Transaction> in
                guard let self = self else { return .never() }
                print("=================================================================")
                print("2. SignTransaction: \(transaction)")
                print("=================================================================")
                return self.cryptoless.sendTransaction(id: transaction.id)
            })
            .subscribe(onNext: { transaction in
                print("=================================================================")
                print("3. SendTransaction: \(transaction)")
                print("=================================================================")
                expectation.fulfill()
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: TimeInterval(10000))
    }
    
    func testSocketIO() throws {

        let expectation = XCTestExpectation(description: "Subscribe events")
        
        cryptoless
            .on(.holder)
            .mapObject([Cryptoless.Holder].self)
            .subscribe(onNext: { holders in
                print(holders)
                print("=================================================================")
                print("Holders: \(holders)")
                print("=================================================================")
            })
            .disposed(by: bag)
        
        cryptoless
            .on(.instruction)
            .mapObject([Cryptoless.Instruction].self)
            .subscribe(onNext: { instructions in
                print("=================================================================")
                print("Instructions: \(instructions)")
                print("=================================================================")
            })
            .disposed(by: bag)

        try testEthereumTransfer()
        
        wait(for: [expectation], timeout: TimeInterval(10000))
    }
}
