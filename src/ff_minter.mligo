#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/fa2/fa2_errors.mligo"
#include "../fa2/token/fa2_nft_token.mligo"

#include "./ff_interface.mligo"

type minter_storage = unit

type mint_param =
[@layout:comb]
{
  owner : address;
  tokens : ff_token_metadata list;
}

type minter_entrypoints =
  | Never of never
  | Mint of mint_param list

type mint_acc = {
  token_metadata : token_metadata_storage;
  ledger : ledger;
  bitmark_ids : bitmark_id_storage;
}

// we assume the minting will happend with bitmarkID provided, but not sure if that's true
let mint_tokens(acc, param : mint_acc * mint_param list) : mint_acc =
  let mint = (fun (acc, m : mint_acc * mint_param) ->
    List.fold
      (fun (acc, t : mint_acc * ff_token_metadata) ->
        if Big_map.mem t.token_metadata.token_id acc.token_metadata
        then (failwith "USED_TOKEN_ID" : mint_acc)
        else if Big_map.mem t.bitmark_id acc.bitmark_ids
        then (failwith "USED_BITMARK_ID" : mint_acc)
        else
          let new_meta = Big_map.add t.token_metadata.token_id t.token_metadata acc.token_metadata in
          let new_ledger = Big_map.add t.token_metadata.token_id m.owner acc.ledger in
          let new_bitmark_ids = Big_map.add t.bitmark_id t.token_metadata.token_id acc.bitmark_ids in
          {
            token_metadata = new_meta;
            ledger = new_ledger;
            bitmark_ids = new_bitmark_ids;
          }
      ) m.tokens acc
  ) in
  List.fold mint param acc

let minter_main (param, _tokens, _bitmark_ids, _minter
  : minter_entrypoints * token_storage * bitmark_id_storage * minter_storage)
  : token_storage * minter_storage * bitmark_id_storage =
  match param with
  | Never _ -> (failwith "INVALID_INVOCATION" : token_storage * minter_storage * bitmark_id_storage)
  | Mint m ->
    let source_data = {
      ledger = _tokens.ledger;
      token_metadata = _tokens.token_metadata;
      bitmark_ids = _bitmark_ids;
    } in
    let minted = mint_tokens (source_data, m) in
    let new_tokens = { _tokens with 
      ledger = minted.ledger;
      token_metadata = minted.token_metadata;
    } in
    new_tokens, _minter, minted.bitmark_ids

#endif
