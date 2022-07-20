import * as dotenv from "dotenv";
import {
  TezosToolkit, TezosOperationError
} from "@taquito/taquito";
import {
  InMemorySigner
} from "@taquito/signer";
dotenv.config();

const Tezos = new TezosToolkit(<string>process.env.TEZOS_RPC_URL);

const register_art = async function () {
  const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
  Tezos.setProvider({
    signer: adminSigner
  });

  const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);
  const adminAddress = await adminSigner.publicKeyHash()
  try {
    let op = await contract.methods.register_artworks([{
      artist_name: "fail-test",
      fingerprint: Uint8Array.from(Buffer.from("fail-test")),
      title: "fail-test",
      max_edition: 10,
      royalty_address: adminAddress
    }]).send({ amount: 0.1 });
    await op.confirmation()
    console.log(op)
  } catch (error) {
    if (error instanceof TezosOperationError) {
      console.log(error.message)
    } else {
      console.log(error)
    }
  }
}

register_art()
