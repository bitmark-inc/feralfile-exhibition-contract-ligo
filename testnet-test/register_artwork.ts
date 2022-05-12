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

  try {
    let op = await contract.methods.register_artworks([{
      artist_name: "BRDN-test",
      edition_size: 10,
      fingerprint: "IamFingerprint",
      title: "test",
      token_start_id: 0,
      max_edition: 10
    }]).send();
    await op.confirmation()
    console.log(op)
  } catch (error) {
    console.log(error)
  }
}

mint()
