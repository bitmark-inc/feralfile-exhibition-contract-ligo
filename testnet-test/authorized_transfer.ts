import * as dotenv from "dotenv";
import {
    TezosToolkit
} from "@taquito/taquito";
import {
    InMemorySigner
} from "@taquito/signer";
import {
    buf2hex
} from "@taquito/utils";
import {
    packData
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
        const expiry = ((Date.now() / 1000 | 0) + 300).toString()
        const pk = await noXTZSigner.publicKey()

        let packedTimestamp = packData({ int: expiry }, { prim: 'timestamp' });
        let contractAddress = packData({ string: <string>process.env.CONTRACT_ADDRESS }, { prim: 'address' });
        let packedTo = packData({ string: adminAddr }, { prim: 'address' });
        let packedTokenID = packData({ int: tokenID }, { prim: 'int' });

        let bytesData = Buffer.from(packedTimestamp.concat(contractAddress).concat(packedTo).concat(packedTokenID))

        let prefix = Buffer.from("54657a6f73205369676e6564204d6573736167653a", "hex")

        let rm = Buffer.concat([prefix, bytesData])
        let result_msg = packData({ bytes: rm.toString('hex') }, { prim: 'bytes' })

        const sts = await noXTZSigner.sign(buf2hex(Buffer.from(result_msg)))

        let op2 = await contract.methods.authorized_transfer(
            [
                {
                    from_: noXTZAddr,
                    pk: pk,
                    expiry: expiry,
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
