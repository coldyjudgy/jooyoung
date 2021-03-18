import Jooyoung from 0xf8d6e0586b0a20c7 // hex없이 f8부터 시작하면 에러

// signer가 f8d6e0586b0a20c7 여야지만 성공. 아니면 panic: failed to get capability 에러
transaction{
    let receiverRef: &{Jooyoung.NFTReceiver}
    // resource 타입에만 {} 사용가능 Error cannot restrict using non-resource/structure interface type
    let minterRef: &Jooyoung.NFTMinter

    prepare(acct: AuthAccount){
        self.receiverRef = acct.getCapability<&{Jooyoung.NFTReceiver}>(/public/NFTReceiver)
        .borrow()
        // panic이 없으면 Error: mismatched types. expected &AnyResource{Jooyoung.NFTReceiver}, got &AnyResource{Jooyoung.NFTReceiver}?
        ?? panic("failed to get capability")

        // panic 대신 self.minterRef = acct.borrow<&Jooyoung.NFTMinter>(from: /storage/NFTMinter)! 로 해도 에러 없어짐
        self.minterRef = acct.borrow<&Jooyoung.NFTMinter>(from: /storage/NFTMinter)
        ?? panic("failed to borrow reference")

    }

    execute{
        let metadata : {String : String} = {
            "name": "Jooyoung",
            "song": "거꾸로 강을 거슬러 오르는 저 힘찬 연어들처럼",
            "image": "ipfs://bafybeicdltlmhxyaahgoxcoajdf52xahxidlqmdrqy4wuxcvaxht7hbr3i", 
            "mp3": "ipfs://bafybeihkirufuc5hlv5qyatv75uxj4e5puz6wojlplziut3to3be734f2m"
        }

        let newNFT <- self.minterRef.mintNFT()

        self.receiverRef.deposit(token: <-newNFT, metadata: metadata)
        log("NFT minted and deposited")
    }


}