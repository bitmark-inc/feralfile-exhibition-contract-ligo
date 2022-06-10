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

const set_trustee = async function () {
    const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
    Tezos.setProvider({
        signer: adminSigner
    });

    const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);

    try {
        let op = await contract.methods.set_trustee(
            "tz2Vp4nbnLhNs8fi2vCjocHgv2FFqR3zK4y6"
        ).send();
        await op.confirmation()
        console.log(op)
    } catch (error) {
        console.log(error)
    }
}

set_trustee()
