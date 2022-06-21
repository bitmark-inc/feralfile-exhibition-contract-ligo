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

const update_edition_metadata = async function () {
    const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
    Tezos.setProvider({
        signer: adminSigner
    });

    const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);
    const tokenID = <string>process.env.TEST_TOKEN_ID

    // use ipfs metadata
    let m = MichelsonMap.fromLiteral({
        "": Uint8Array.from(Buffer.from("ipfs://test-update"))
    })

    try {
        let op = await contract.methods.update_edition_metadata(
            [
                {
                    token_id: tokenID,
                    token_info: m,
                }
            ]).send();
        await op.confirmation()
        console.log(op)
    } catch (error) {
        console.log(error)
    }
}

update_edition_metadata()
