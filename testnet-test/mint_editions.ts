import * as dotenv from "dotenv";
import {
  TezosToolkit
} from "@taquito/taquito";
import {
  MichelsonMap
} from "@taquito/taquito";
import {
  InMemorySigner
} from "@taquito/signer";
dotenv.config();

const Tezos = new TezosToolkit(<string>process.env.TEZOS_RPC_URL);

const mint = async function () {
  const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
  Tezos.setProvider({
    signer: adminSigner
  });

  const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);
  const adminAddr = await adminSigner.publicKeyHash()

  // use ipfs metadata
  let m = MichelsonMap.fromLiteral({
    "": Uint8Array.from(Buffer.from("ipfs://QmQd4fnE5zzYkvZ36YNSDkjsrVfHZnn2c36vGcKvgjmoKR"))
  })

  try {
    let op = await contract.methods.mint_editions(
      [
        {
          owner: adminAddr,
          tokens: [
            {
              token_info: m,
              artwork_id: "b2b4fd6e12f9d59de33f599a41c23e38c29d2b7ce468b1bd28cacc0321f33046",
              edition: 0
            }
          ]
        }
      ]).send();
    await op.confirmation()
    console.log(op)
  } catch (error) {
    console.log(error)
  }
}

mint()
