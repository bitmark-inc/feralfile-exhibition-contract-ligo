type authorized_transfers_destination =
[@layout:comb]
{
  to_ : address;
  token_id : token_id;
  amount : nat;
  sig : signature;
}

type authorized_transfers =
[@layout:comb]
{
  from_ : address;
  pk : key;
  expiry : timestamp;
  txs : authorized_transfers_destination list;
}

let fail_if_key_mismatch (key, from : key * address) : unit =
  let c : unit contract = Tezos.implicit_account (Crypto.hash_key key) in
  if Tezos.address c <> from 
    then failwith fa2_publickey_address_mismatch
  else unit

let fail_if_expired (expire_time : timestamp) : unit =
  if Tezos.now > expire_time
    then failwith fa2_expired_timestamp
  else unit

let fail_if_invalid_signature (k, sig, msg : key * signature * bytes) : unit =
  if Crypto.check k sig msg = false
    then failwith fa2_invalid_signature  
  else unit

type ff_entry_points =
  | Never of never
  | Authorized_transfers of authorized_transfers list

let authorized_transfers (txs, ledger, sig_prefix
    : (authorized_transfers list) * ledger * bytes) : ledger =
  (* process individual transfer *)
  let make_admin_transfer = (fun (l, tx : ledger * authorized_transfers) ->
    let _ = fail_if_key_mismatch(tx.pk, tx.from_) in
    let _ = fail_if_expired tx.expiry in
    let p_bytes_expiry = Bytes.pack tx.expiry in
    List.fold 
      (fun (ll, dst : ledger * authorized_transfers_destination) ->
        if dst.amount = 0n
          then ll
        else if dst.amount <> 1n
          then (failwith fa2_insufficient_balance : ledger)
        else
          let owner = Big_map.find_opt dst.token_id ll in
          match owner with
          | None -> (failwith fa2_token_undefined : ledger)
          | Some o -> 
            if o <> tx.from_
              then (failwith fa2_insufficient_balance : ledger)
            else 
              let p_bytes_to_ = Bytes.pack dst.to_ in
              let p_bytes_token_id = Bytes.pack dst.token_id in
              let bytes_msg = Bytes.concat sig_prefix (Bytes.concat p_bytes_expiry (Bytes.concat p_bytes_to_ p_bytes_token_id)) in
              let bytes_sign_msg = Bytes.pack bytes_msg in
              let _ = fail_if_invalid_signature(tx.pk, dst.sig, bytes_sign_msg) in
              Big_map.update dst.token_id (Some dst.to_) ll
      ) tx.txs l
  )
  in 
  List.fold make_admin_transfer txs ledger

let ff_main (param, storage, sig_prefix : ff_entry_points * token_storage * bytes)
    : (operation  list) * token_storage =
  match param with
  | Never _ -> (failwith "INVALID_INVOCATION" : (operation  list) * token_storage) 
  | Authorized_transfers txs -> 
    let new_ledger = authorized_transfers (txs, storage.ledger, sig_prefix) in
    let new_storage = { storage with ledger = new_ledger; } in
    ([] : operation list), new_storage
