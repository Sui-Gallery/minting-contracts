import React, { useEffect, useState } from "react";

const useSuiWallet = () => {
  const [wallet, setWallet] = useState(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const cb = () => {
      setLoaded(true);
      setWallet(window.suiWallet);
    };
    if (window.suiWallet) {
      cb();
      return;
    }
    window.addEventListener("load", cb);
    return () => {
      window.removeEventListener("load", cb);
    };
  }, []);
  return wallet || (loaded ? false : null);
};

function App() {
  const suiWallet = useSuiWallet();

  const onClickMint = async () => {
    try {
      const result = await suiWallet.executeMoveCall({
        packageObjectId: "0x0be33bf00b18f751ca6b05ba798f7c682ef809b4",
        module: "NFT",
        function: "mint",
        typeArguments: [],
        arguments: [1, "0xf316efeacef2a5da1635ad36af020dd07add2300"],
        gasBudget: 10000,
      });
      const nftID = await
        result?.effects?.created?.[0]?.reference?.objectId;
      console.log(result)
      console.log(nftID)
    } catch (e) {
      console.log(e)
    }
  }

  const connectWallet = async () => {
    try {
      await suiWallet.requestPermissions();
    } catch(e) {
      console.log(e)
    }
  }

  return (
    < div >
      <button onClick={connectWallet}>Connect Wallet</button>
      <button onClick={onClickMint}>Mint</button>
    </div >
  )
}



export default App;
