import fs from 'fs';
import { BigNumber } from 'bignumber.js';

import * as dotenv from "dotenv";
import axios from "axios";
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

import tokenMetadata from './token_metadata.json'

const contractAddress = "KT1WgvCKC8vvjbAYEgaXHo9A6GprKDyaw7N3"

const storageLink = `https://api.tzkt.io/v1/contracts/${contractAddress}/storage`


const update_edition_metadata = async function () {
  const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
  Tezos.setProvider({
    signer: adminSigner
  });

  const contract = await Tezos.wallet.at(contractAddress);
  const resp = await axios.get(storageLink)
  const artworks = resp.data.artworks

  let tokenUpdates: any[] = [];
  for (let i = 0; i < tokenMetadata.length; i++) {
    let token = tokenMetadata[i]
    let m = MichelsonMap.fromLiteral({
      "": Uint8Array.from(Buffer.from(token.ipfs_link)),
    })

    let tokenID = new BigNumber(artworks[token.artwork_id].token_start_id)
    tokenID = tokenID.plus(<number>token.edition)
    console.log(i, token.artwork_id, token.edition, artworks[token.artwork_id].title, tokenID.toFixed(), token.ipfs_link)

    tokenUpdates.push({
      token_id: tokenID.toFixed(),
      token_info: m,
    })

    if (tokenUpdates.length >= 101) {
      try {
        let op = await contract.methods.update_edition_metadata(tokenUpdates).send();
        await op.confirmation(1)
        console.log(op)
        tokenUpdates = []
      } catch (error) {
        console.log(error)
      }
    }
  }

  if (tokenUpdates.length > 0) {
    try {
      let op = await contract.methods.update_edition_metadata(tokenUpdates).send();
      await op.confirmation(1)
      console.log(op)
    } catch (error) {
      console.log(error)
    }
  }
}

update_edition_metadata()
