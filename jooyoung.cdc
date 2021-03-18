// 컨트랙트 이름 소문자로 시작하면 에러: 인식못함
pub contract Jooyoung{
    pub resource NFT{
        pub let id: UInt64 // id로 NFT 구분가능
        init(initID: UInt64){
            self.id = initID
        }
    }

    // interface가 있어야 특정 resource만 capability 부여해서 다른 사람이 볼 수 있음
    pub resource interface NFTReceiver{
        // capability를 통해 접근 권한을 얻은 사람은 다음의 2가지 함수를 쓸 수 있음
        pub fun deposit(token: @NFT, metadata: {String: String})
        pub fun getMetadata(id: UInt64): {String: String}
    }

    // NFT를 저장하는 지갑 = Collection 생성. NFT가 resource이니 지갑도 resource여야 함
    pub resource Collection: NFTReceiver{
        pub var ownedNFTs: @{UInt64: NFT} // 사용자가 이 컨트랙트로부터 얻게 된 모든 NFT 추적
        pub var metadataObjs: {UInt64: {String : String}} // id와 metadata를 매핑. id는 항상 토큰생성 전에 먼저 존재해야 함
        
        // resource 타입은 무조건 initialize 해야함
        init() {
            self.ownedNFTs <- {} //19:27에서 @를 사용했으므로 resource라서 move operator인 <- 이용
            self.metadataObjs = {}
        }
    

    // NFT Collection resource를 위해 쓸 수 있는 모든 함수들
    // 이 함수들 안에서 쓰는 var들은 interface로 제한된 Collection 안에서 선언되었기 때문에
    // NFTReceiver capability를 보유한 사람만 사용가능
    pub fun deposit(token: @NFT, metadata: {String: String}){ // 토큰의 minter만 metadata 추가가능
        self.metadataObjs[token.id] = metadata // id와 metadata 매핑
        self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT{
        let token <-self.ownedNFTs.remove(key: withdrawID)!
        return <- token
    }

    pub fun getMetadata(id: UInt64): {String : String}{
        return self.metadataObjs[id]! // script Error: unexpectedly found nill while forcing an Optional value
    }
    // resource에 대한 destructor 없으면 에러
    destroy(){
        destroy self.ownedNFTs
    }

    }
    pub fun createEmptyCollection(): @Collection{
        return <- create Collection()
    }

    pub resource NFTMinter{
        pub var idCount: UInt64 // NFT 복제 방지

        init(){
            self.idCount = 1
        }
        
        pub fun mintNFT(): @NFT{
            var newNFT <- create NFT(initID: self.idCount)
            self.idCount = self.idCount + 1 as UInt64
            return <- newNFT
        }
    }

    // init은 맨 처음에 deploy 되었을때만 실행
    init(){
        // 컨트랙트 주인의 계쩡에 Collectoin 생성 -> 민트 가능
        self.account.save(<-self.createEmptyCollection(), to: /storage/NFTCollection)
        // 다른 사람들이 토큰을 받기 위해서는 NFTReceiver가 있어야 함
        self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)
        // 컨트랙트 주인만이 민트 가능한 것을 의미
        self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
    }
}