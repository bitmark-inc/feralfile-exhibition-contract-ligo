import * as dotenv from "dotenv";
import {
  TezosToolkit
} from "@taquito/taquito";
import {
  InMemorySigner
} from "@taquito/signer";
dotenv.config();

const Tezos = new TezosToolkit(<string>process.env.TEZOS_RPC_URL);

const burn = async function () {
  const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
  Tezos.setProvider({
    signer: adminSigner
  });

  const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);
  const adminAddr = await adminSigner.publicKeyHash()
  const tokenID = <string>process.env.TEST_TOKEN_ID

  try {
    let op = await contract.methods.burn_editions(
      [
        {
          owner: adminAddr,
          tokens: [
            tokenID
          ]
        }
      ]).send();
    await op.confirmation()
    console.log(op)
  } catch (error) {
    console.log(error)
  }
}

burn()
