type trustee_storage = {
    trustees : address set;
    max_trustee : nat;
}

type trustee_entrypoints =
    | Set_trustee of address
    | Remove_trustee of address

let ff_over_max_trustee_amount = "FF_OVER_MAX_TRUSTEE_AMOUNT"
let ff_trustee_already_exist = "FF_TRUSTEE_ALREADY_EXIST"
let ff_not_trustee = "FF_NOT_TRUSTEE"

[@inline]
let fail_if_over_max_trustee_amount (storage : trustee_storage) : unit =
    if Set.cardinal storage.trustees >= storage.max_trustee
        then failwith ff_over_max_trustee_amount
    else unit

[@inline]
let is_trustee (storage : trustee_storage) : bool =
  Set.mem Tezos.sender storage.trustees

let fail_if_trustee_already_exist (trustee, storage : address * trustee_storage) : unit =
    if Set.mem trustee storage.trustees
        then failwith ff_trustee_already_exist
    else unit

let fail_if_not_trustee (trustee, storage : address * trustee_storage) : unit =
    if not Set.mem trustee storage.trustees
        then failwith ff_not_trustee
    else unit

let set_trustee(new_trustee, storage : address * trustee_storage) : trustee_storage = 
    let _ = fail_if_over_max_trustee_amount storage in
    let _ = fail_if_trustee_already_exist (new_trustee, storage) in
     { storage with trustees =  Set.add new_trustee storage.trustees; }

let remove_trustee(old_trustee, storage : address * trustee_storage) : trustee_storage =
    let _ = fail_if_not_trustee (old_trustee, storage) in
    { storage with trustees = Set.remove old_trustee storage.trustees; }

let trustee_main(param, storage : trustee_entrypoints * trustee_storage)
    : trustee_storage =
    match param with
    | Set_trustee new_trustee ->
        set_trustee (new_trustee, storage)
    | Remove_trustee old_trustee ->
        remove_trustee (old_trustee, storage)
