import React, { useState } from "react";
import * as fcl from "@onflow/fcl";
import ReactPlayer from "react-player";

const TokenData = () => {
  const [nftInfo, setNftInfo] = useState(null)
  const fetchTokenData = async () => {
    const encoded = await fcl
      .send([
        fcl.script`
        import Jooyoung from 0xf8d6e0586b0a20c7
        pub fun main() : {String : String} {
          let nftOwner = getAccount(0xf8d6e0586b0a20c7)  
          let capability = nftOwner.getCapability<&{Jooyoung.NFTReceiver}>(/public/NFTReceiver)
      
          let receiverRef = capability.borrow()
              ?? panic("Could not borrow the receiver reference")
      
          return receiverRef.getMetadata(id: 1)
        }
      `
      ])
    
    const decoded = await fcl.decode(encoded)
    setNftInfo(decoded)
  };
  return (
    <div className="token-data">
      <div className="center">
        <button className="btn-primary" onClick={fetchTokenData}>Fetch Token Data</button>        
      </div>
      {
        nftInfo &&
        <div>
          {
            Object.keys(nftInfo).map(k => {
              return (
                <p>{k}: {nftInfo[k]}</p>
              )
            })
          }
          <div className="center image">
            <img src={`https://ipfs.io/ipfs/${nftInfo["image"].split("://")[1]}`} width="600" height="400" alt="He is Jooyoung">
            </img>
            <ReactPlayer
              url={`https://ipfs.io/ipfs/${nftInfo["mp3"].split("://")[1]}`}
              width="600"
              height="50px"
              playing={false}
              controls={true} />
          </div>
          <div className="center">
          <button onClick={() => setNftInfo(null)} className="btn-secondary">Clear Token Info</button>
          </div>
        </div>
      }
    </div>
  );
};

export default TokenData;
