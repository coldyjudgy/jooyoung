// 배포된 컨트랙트 import
import Jooyoung from 0xf8d6e0586b0a20c7

// script에는 항상 main()이 있어야 실행됨
pub fun main() : {String : String}{
    // getAccount의 argument를 다른 계정으로 하면 Error panic: can not borrow the receiver reference
    let nftOwner = getAccount(0xf8d6e0586b0a20c7)
    let capability = nftOwner.getCapability<&{Jooyoung.NFTReceiver}>(/public/NFTReceiver)
    let receiverRef = capability.borrow()
        ?? panic("can not borrow the receiver reference")

    return receiverRef.getMetadata(id: 1)
}