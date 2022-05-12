type authorized_transfer =
[@layout:comb]
{
  from_ : address;
  pk : key;
  ts : bytes;(* convert timestamp to bytes *)
  sig : signature;
  txs : transfer_destination list;
}

type ff_entry_points =
  | Never of never
  | Authorized_transfer of authorized_transfer list

let authorized_transfer (txs, ledger
    : (authorized_transfer list) * ledger) : ledger =
  (* process individual transfer *)
  let make_admin_transfer = (fun (l, tx : ledger * authorized_transfer) ->
    List.fold 
      (fun (ll, dst : ledger * transfer_destination) ->
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
              if Crypto.check tx.pk tx.sig tx.ts = false
              then (failwith fa2_not_owner : ledger)
              else
                Big_map.update dst.token_id (Some dst.to_) ll
      ) tx.txs l
  )
  in 
  List.fold make_admin_transfer txs ledger

let ff_main (param, storage : ff_entry_points * token_storage)
    : (operation  list) * token_storage =
  match param with
  | Never _ -> (failwith "INVALID_INVOCATION" : (operation  list) * token_storage) 
  | Authorized_transfer txs -> 
    let new_ledger = authorized_transfer (txs, storage.ledger) in
    let new_storage = { storage with ledger = new_ledger; } in
    ([] : operation list), new_storage
