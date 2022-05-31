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
  ts : timestamp;
  txs : authorized_transfers_destination list;
}

type ff_entry_points =
  | Never of never
  | Authorized_transfers of authorized_transfers list

let authorized_transfers (txs, ledger, sig_prefix
    : (authorized_transfers list) * ledger * bytes) : ledger =
  (* process individual transfer *)
  let make_admin_transfer = (fun (l, tx : ledger * authorized_transfers) ->
    let within: int = 300 in (* 5 min*)
    let p_bytes_ts = Bytes.pack tx.ts in
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
                (* validate signature *)
                let p_bytes_to_ = Bytes.pack dst.to_ in
                let p_bytes_token_id = Bytes.pack dst.token_id in
                let bytes_msg = Bytes.concat sig_prefix (Bytes.concat p_bytes_ts (Bytes.concat p_bytes_to_ p_bytes_token_id)) in
                let bytes_sign_msg = Bytes.pack bytes_msg in
                if Crypto.check tx.pk dst.sig bytes_sign_msg = false || Tezos.now > tx.ts + within
                  then (failwith fa2_auth_transfer_sig_wrong : ledger) 
                else 
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
