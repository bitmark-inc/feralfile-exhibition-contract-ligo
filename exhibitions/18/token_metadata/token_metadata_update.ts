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
import { createImportSpecifier } from "typescript";
dotenv.config();

const Tezos = new TezosToolkit(<string>process.env.TEZOS_RPC_URL);


let tokenInfo = [{
  "ipfs_link": "ipfs://QmQduhuwbRsSgEzaWrc8mpnazHxkbsuZs4eXjEhdKoMXPX",
  "artwork_id": "1f11e16da1c2b3450c5e1808a331a031d548ccc7b53989ce5b180a477054dcdc",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmVd9vJegy8ARyLdUCm2t9pqCj11KZjD71XZAfYnZPaoMK",
  "artwork_id": "f59b059c854533343897f95584788c76a68330c7630b62f5459dc0fbc4002e3d",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmU1HU6xzJcuLZYfwa8ZaDdwhWJ2Mj1DzKU3mBht2KLbrH",
  "artwork_id": "a01e87947e3eb4156b18cdfe866e1dbc7258d77102cd3a6bb662cc8ad5d3ffe4",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmQd8ui6v5ABqZTjg5GZKoSfUfueWwshJGqSmKh6iaMq5R",
  "artwork_id": "ed5e7bd394a231332cf331f0845ffba4cd60d98d48212d9c56630057fc1d61ac",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmVKZLakzJ1zBXfJzmYCMRk2SHV2TxuXoooyESPmBvZ8yn",
  "artwork_id": "fff2e4f11e0af88bab6fc13e8c706bb8117a03bca07dc38a1c422e7d1c1aeec1",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmSJmr4ndUwGsTUhCy57zTiJ1ucpTDmcGUWZUpZJdk86Mr",
  "artwork_id": "da3f3f8bca9803649e8943cc70c2c1654c0cea1df3ca832709bd1fd306fa092e",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmWbCrLBJVWT1YyYwhiVTbLy3jPGbYVqMPDehbkqdfUCif",
  "artwork_id": "2912526c8c002b2e3c84ae67d6ab54e585b5d0280db15ca51496ec5254ebc991",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmUMtb3P9gFzaD8ZcQ4dNk1CMQEpM1ccmQnjQntGQARKXa",
  "artwork_id": "4829cfe1fbf87e3a38f9d150faf98b91bc66d9629f6bc9e255d3ba5050886acf",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmSLHxEKhb7qX8yQbwTbfbxU3Zmcg89Mu5Ep72E7ADMghv",
  "artwork_id": "a820ba976050439ff13063f203e461b52c7a22da1493d032f9a68074c4a3ff5b",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmTHoWLpYpb7xowCX4VsAoEMa2wobpTFSRtboYq1DpWf72",
  "artwork_id": "cd438660a7a7dee244d88ffc88038de651fed6de730953bb6aad0fda3cd53f91",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmS7xsXLwjXsG1wH3BBG3VkzEHhYTzoF3yC6YaHBhszxFo",
  "artwork_id": "25b552ce32dfe973f8d0071a2251c6d46e72380dbaf44455fc3627f60d1ba281",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmSxfSqTmkYHCZHoUp2zGfknSa4dAXccLJcT2jSsGKJi4w",
  "artwork_id": "27df60a816bc5f99474d2724ab8f86ee2667f370bd7ce8c25667d29893356142",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmTvwdgHxNV4N23SwyxwQWt4qw9RxbBcgE44wPYVdWvJss",
  "artwork_id": "3ad79e8bb9f65b7aa80b9b36fa2e7e214a4eee5edc60a939f03aad709e9ff796",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmVYxqSL8pT3QvhjaHuVNqEtEaKu2mSR45DTpwbYirFVX4",
  "artwork_id": "53f8e760cf9ea1ed7aa02b14d2409a132312c5f8a6036ef738e32e4afb031053",
  "edition": 1
},
{
  "ipfs_link": "ipfs://Qmc43gfo3k8iWXphHEzfqNYHSxWkpjJRY4MTR8mhP56tD6",
  "artwork_id": "fa29ba202e691a9e7ae40e5d0859683dee63cd5211276aa1935e04f2b0546aa6",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmXi3xABDKuQFCZoMbfJ9EVKTrVZ8hijjHVbkxQsEsoApP",
  "artwork_id": "91983bd02c4356c3b426976094fcd0cf2e70a157a34d76e5e215bd41a02da030",
  "edition": 1
},
{
  "ipfs_link": "ipfs://Qmf2cyWRkgMeiMCjQnPuSiosms4Ay8hxK9s1QQxqHQxMW1",
  "artwork_id": "cd2c60c713405fd989d4c16c84d2109078c50ed256f6075753304fd37f9bed6b",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmS5fvNpXrHXLAVyqbc9H7ZfzNviw8ac2ytekTxwHzC6cM",
  "artwork_id": "f6c048c37e38ae88ffe6cfab3c0acda1a959d02ad37dfc554148fe43956b12d2",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmNWFVeLpXRFf9G8QbwQsRyNE2uQawB9EvFi2ssBvQo6ew",
  "artwork_id": "765a10cb5af7f7984c14a0dbeb99d8813dc72863fd795512f9a7e0d6a807582b",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmYEzEDgtKwHWuLUXEtXnfvUx5fZgUzhx8W4E1jqv8Wg33",
  "artwork_id": "b17c9b5fdda3352a26d35807455f68e0524fc82f9920f289d44b8f29800552a9",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmU5UcZpCFbsKv9sAY8oL9Sc8CuDPD4qJBMBniev98U7qi",
  "artwork_id": "2e070d565c64da377ddba5baf7d60b68889778f7b3723d98ef1129bd8e147160",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmU7CK5nA45zr8q7x4mpDzk832DfRSpiiVrwkUtLmnZynh",
  "artwork_id": "7e0db3d0103872c1f7f78187f888042aaf84c0a0e619df79db2fc114e06925ef",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmWvhSKU5aynVshuPZXZNh2mDjtCPpcmoR5ThaLqYPPLxi",
  "artwork_id": "cd6c44bcef041fc2390f2b5a42e63346705f2ab15aaaa172f0c6124bfd40f0c1",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmaFnoQEFv72GAkqCoAK7tyEcPiLTWUJWw6sbVU2kStCid",
  "artwork_id": "3a9c5ee0561e1f143f8040b2640a9bfe70b67b428304c7690c1e67586e66f264",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmYgu2xopZ6cmkDdHQQSjnSqqnvnGCJP83Ev13om982rqm",
  "artwork_id": "160d53c31fa4bfbb316954ad8e924e6bd49ffdc199196af2648390f91ed0b5b4",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmaftiLLt2WLYDRMzrz6Jug1VrpJEo9rtRPhUeg33Fkv8H",
  "artwork_id": "773ac901cc171fcae206052d5a5ee145ea92de2e43d81674f8616ed2e1e2e287",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmTxhfEMnKX2JMQCnbm18aP4qfA4J2ZaHrK3rZvNPoDGD6",
  "artwork_id": "471797816632b332226c4a10d2da29e466ca90da06c6ea190cbe1a0e88e5513e",
  "edition": 1
},
{
  "ipfs_link": "ipfs://Qmc4Ey79y8rQb6E3gBeoh7wSduJXr6p3URN2Lg2W5HiyiD",
  "artwork_id": "924cc41a70ae1cd61902ca794c6b79a196e747bf1cfadcd2124251163f7835e1",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmVb6FWgqkCVTJHGD4meZhYGeawNB82DtqDQTFLXNJoGFE",
  "artwork_id": "ca2a439b031dc8742754c07042cbf4f1262d3570d95a4f4a6b29bcfa7d51e257",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmbENoZPpRSdAjmi9vwBZTzVuiZtj4j1vqg7SrY1ZS3cDT",
  "artwork_id": "68c93c6d36fe74b61014a6db0ef823d1a31fe1bb4a30e31e7ef42676025c698c",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmXsxYP9MGLdzympbnKCZEnGR6wRFjUAM1o6DqkJYCsV2u",
  "artwork_id": "1d56a4c1b26e5d7d75dd651d91b6e048e38bddaf4ff1b9cbd24c0e04b116585b",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmVaFYiwce1yMiFZnKRqNeSFfMd97H4cLQPGCQwpqxGmzh",
  "artwork_id": "94144ca2d3e2be949b79c1a5b438f5b21b2eacb679e8fa9328e893ebec19a7f7",
  "edition": 1
},
{
  "ipfs_link": "ipfs://QmYneGYN4wmimXbKr7thCgKzVeFJDW8uj1mhLAgyPMxxm7",
  "artwork_id": "237bfb7a2d90376b8e8b27c1bb1e93b922509592f8e1ec8345d07a60a23a9337",
  "edition": 1
}
]

const storageLink = "https://api.tzkt.io/v1/contracts/KT1RnhKKsAD7ScFi3Nb7HKK2hnPCqXcbNG3k/storage"


function loadCode(path: string) {
  return new Promise(function (resolve, reject) {
    fs.readFile(path, "binary", function (err, data) {
      if (err) {
        reject(err)
      } else {
        resolve(data)
      }
    })
  })
}

const update_edition_metadata = async function () {
  const adminSigner = await InMemorySigner.fromSecretKey(<string>process.env.DEPLOYER_PRIVATE_KEY);
  Tezos.setProvider({
    signer: adminSigner
  });

  const contract = await Tezos.wallet.at(<string>process.env.CONTRACT_ADDRESS);
  const tokenID = <string>process.env.TEST_TOKEN_ID

  const resp = await axios.get(storageLink)

  const artworks = resp.data.artworks
  for (let i = 0; i < tokenInfo.length; i++) {
    let token = tokenInfo[i]
    console.log(i, artworks[token.artwork_id].title)
    let code = <string>(await loadCode("./code-metadata/" + artworks[token.artwork_id].title + ".js"))
    let m = MichelsonMap.fromLiteral({
      "": Uint8Array.from(Buffer.from(token.ipfs_link)),
      "code": Uint8Array.from(Buffer.from(code))
    })

    console.log(m)

    let tokenID = new BigNumber(artworks[token.artwork_id].token_start_id)
    tokenID = tokenID.plus(1)
    console.log(tokenID.toFixed())
    try {
      let op = await contract.methods.update_edition_metadata(
        [{
          token_id: tokenID.toFixed(),
          token_info: m,
        }]).send();
      await op.confirmation(1)
      console.log(op)
    } catch (error) {
      console.log(error)
    }

    return
    // console.log(m)
  }
}

update_edition_metadata()
