type burn_edition_param = token_id

type burner_storage = {
  token_metadata : token_metadata_storage;
  token_attribute : token_attribute_storage;
  ledger : ledger;
}

let _burn_editions(param, storage : burn_edition_param list * burner_storage) : burner_storage =
  let burn_tokens_for_owner = (fun(storage, tid : burner_storage * token_id) ->
    let _ = fail_if_token_metadata_not_found (tid, storage.token_metadata) in
    match Big_map.find_opt tid storage.ledger with
      | None -> (failwith fa2_token_undefined : burner_storage)
      | Some o ->
        let _ = fail_if_sender_not_token_owner (o) in
        let new_s = match Big_map.find_opt tid storage.token_attribute with
          | None -> (failwith ff_token_attribute_not_found : burner_storage)
          | Some attr ->
            let new_attr = { attr with burned = true; } in
            {
              token_metadata = Big_map.remove tid storage.token_metadata;
              token_attribute = Big_map.update tid (Some(new_attr)) storage.token_attribute;
              ledger = Big_map.remove tid storage.ledger;
            } 
        in
        new_s
  ) in
  List.fold burn_tokens_for_owner param storage

let burn_editions (burns, _tokens, _token_attribute 
  : burn_edition_param list * token_storage * token_attribute_storage)
  : token_storage * token_attribute_storage =
    let burn_in = {
        ledger = _tokens.ledger;
        token_metadata = _tokens.token_metadata;
        token_attribute = _token_attribute;
    } in
    let burn_out = _burn_editions (burns, burn_in) in
    let new_tokens = { _tokens with
        ledger = burn_out.ledger;
        token_metadata = burn_out.token_metadata;
    } in
    new_tokens, burn_out.token_attribute
