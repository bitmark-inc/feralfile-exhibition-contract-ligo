type authorized_transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : token_id;
  amount : nat;
  sig : signature;
}

type authorized_transfer =
[@layout:comb]
{
  from_ : address;
  pk : key;
  expiry : timestamp;
  txs : authorized_transfer_destination list;
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

let sig_prefix = 0x54657a6f73205369676e6564204d6573736167653a

let _authorized_transfer (transfers, ledger : authorized_transfer list * ledger) : ledger =
  (* process individual transfer *)
  let make_admin_transfer = (fun (l, tx : ledger * authorized_transfer) ->
    let _ = fail_if_key_mismatch(tx.pk, tx.from_) in
    let _ = fail_if_expired tx.expiry in
    let p_bytes_expiry = Bytes.pack tx.expiry in
    List.fold 
      (fun (ll, dst : ledger * authorized_transfer_destination) ->
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
  List.fold make_admin_transfer transfers ledger

(** authorized_transfer takes authorized transfer requests from users
    and executes them from the trustee account *)
let authorized_transfer (transfers, token_storage : authorized_transfer list * token_storage) : token_storage =
    let new_ledger = _authorized_transfer (transfers, token_storage.ledger) in
    let new_storage = { token_storage with ledger = new_ledger; } in
    new_storage
