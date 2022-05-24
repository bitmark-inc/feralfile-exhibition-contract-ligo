import * as dotenv from "dotenv";
import {
    TezosOperationError,
    TezosToolkit
} from "@taquito/taquito";
import {
    MichelsonMap
} from "@taquito/taquito";
import {
    InMemorySigner
} from "@taquito/signer";
import {
    hex2buf,
    buf2hex
} from "@taquito/utils";
import {
    packData,
    packDataBytes,
    MichelsonData,
    MichelsonType
} from "@taquito/michel-codec";

dotenv.config();

const Tezos = new TezosToolkit(<string>process.env.TEZOS_RPC_URL);

const auth_transfer = async function () {
    const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
    const noXTZSigner = await InMemorySigner.fromSecretKey(<string>process.env.NO_XTZ_ACCOUNT_PRIVATE_KEY);
    const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);

    Tezos.setProvider({
        signer: adminSigner
    });

    const adminAddr = await adminSigner.publicKeyHash()
    const noXTZAddr = await noXTZSigner.publicKeyHash()
    const tokenID = <string>process.env.TEST_TOKEN_ID

    try {
        // transfer edition 0 to no XTZ account 
        let op1 = await contract.methods.transfer(
            [
                {
                    from_: adminAddr,
                    txs: [
                        {
                            to_: noXTZAddr,
                            token_id: tokenID,
                            amount: 1
                        }
                    ]
                }
            ]).send();
        await op1.confirmation()

        // transfer back from 0 xtz account to admin but call from admin
        const now = (Date.now() / 1000 | 0).toString()
        const pk = await noXTZSigner.publicKey()

        let packedTimestamp = packData({ int: now }, { prim: 'timestamp' });
        let packedTo = packData({ string: adminAddr }, { prim: 'address' });
        let packedTokenID = packData({ int: tokenID }, { prim: 'int' });

        let bytesData = buf2hex(Buffer.from(packedTimestamp.concat(packedTo).concat(packedTokenID)))
        console.log(bytesData)

        const sts = await noXTZSigner.sign(bytesData)

        let op2 = await contract.methods.authorized_transfer(
            [
                {
                    from_: noXTZAddr,
                    pk: pk,
                    ts: now,
                    txs: [
                        {
                            to_: adminAddr,
                            token_id: tokenID,
                            amount: 1,
                            sig: sts.sig
                        }
                    ]
                }
            ]).send();
        await op2.confirmation()
        console.log(op2)
    } catch (error) {
        console.log(error)
    }
}
auth_transfer()
