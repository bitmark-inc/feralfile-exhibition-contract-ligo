type ff_token_metadata =
[@layout:comb]
{
  token_info: (string, bytes) map;
  artwork_id: bytes;
  edition: nat;
}

type mint_edition_param =
[@layout:comb]
{
  owner : address;
  tokens : ff_token_metadata list;
}

type update_edition_metadata_param = token_metadata
type issue_artworks_editions_param = nat list

type artwork_param =
[@layout:comb]
{
  title : string;
  artist_name : string;
  fingerprint : bytes;
  max_edition : nat;
  ae_amount : nat;
  pp_amount : nat;
  royalty_address: address;
}

type minter_entrypoints =
  | Mint_editions of mint_edition_param list
  | Update_edition_metadata of update_edition_metadata_param list
  | Register_artworks of artwork_param list

type minter_storage = {
  token_metadata : token_metadata_storage;
  token_attribute : token_attribute_storage;
  ledger : ledger;
}

let ff_artwork_invalid_max_edition = "ARTWORK_MAX_EDITION_EXCEEDS_EXHIBITION_MAX_EDITION"
let ff_mint_invalid_edition = "EDITION_NUMBER_EXCEEDS_MAX_EDITION_LIMITS"
let ff_duplicated_token = "TOKEN_HAS_ALREADY_ISSUED"
let ff_duplicated_token_metadata = "TOKEN_METADATA_HAS_ALREADY_REGISTERED"
let ff_duplicated_token_attribute = "TOKEN_ATTRIBUTE_HAS_ALREADY_REGISTERED"

(** check if the token edition exceed the maximum number of the artwork *)
let fail_if_invalid_edition (edition, artwork : nat * artwork) : unit =
  if edition >= artwork.max_edition + artwork.ae_amount + artwork.pp_amount
    then failwith ff_mint_invalid_edition
  else unit

(** check if a token is duplicated *)
let fail_if_duplicated_token (token_id, ledger : nat * ledger) : unit =
  if Big_map.mem token_id ledger
    then failwith ff_duplicated_token
  else unit

(** check if a token_metadata is duplicated *)
let fail_if_duplicated_token_metadata (token_id, metadata : nat * token_metadata_storage) : unit =
  if Big_map.mem token_id metadata
    then failwith ff_duplicated_token_metadata
  else unit

(** check if a token_attribute is duplicated *)
let fail_if_duplicated_token_attribute (token_id, attribute : nat * token_attribute_storage) : unit =
  if Big_map.mem token_id attribute
    then failwith ff_duplicated_token_attribute
  else unit

(**
mint_editions mint editions for the exhibition
*)
let mint_editions(param, storage, artworks : mint_edition_param list * minter_storage * artwork_storage) : minter_storage =
  let mint_tokens_for_owner (owner: address) (storage, t : minter_storage * ff_token_metadata) =
    match Map.find_opt t.artwork_id artworks with
      | None -> (failwith "ARTWORK_NOT_FOUND" : minter_storage)
      | Some art ->
        let _ = fail_if_invalid_edition(t.edition, art) in

        let token_id = art.token_start_id + t.edition in

        let _ = fail_if_duplicated_token(token_id, storage.ledger) in
        let _ = fail_if_duplicated_token_metadata(token_id, storage.token_metadata) in
        let _ = fail_if_duplicated_token_attribute(token_id, storage.token_attribute) in

        let new_token_metadata = {
          token_id = token_id;
          token_info = t.token_info;
        } in
        let new_token_attribute = {
          artwork_id = t.artwork_id;
          edition_number = t.edition;
          burned = false;
        } in
        {
          token_metadata = Big_map.add token_id new_token_metadata storage.token_metadata;
          token_attribute = Big_map.add token_id new_token_attribute storage.token_attribute;
          ledger = Big_map.add token_id owner storage.ledger;
        }
  in

  List.fold (fun (storage, m : minter_storage * mint_edition_param) ->
    List.fold (mint_tokens_for_owner m.owner) m.tokens storage
  ) param storage

(**
register_artworks creates artworks for an exhibition
*)
let register_artworks(param, artworks, bytes_to_nat : artwork_param list * artwork_storage * ((bytes * nat * nat) -> nat)) : artwork_storage =
  let register = (fun (artworks, artwork_param : artwork_storage * artwork_param) ->
    (** Generate artwork_id using keccak256 algorithm *)
    let artwork_id = Crypto.keccak artwork_param.fingerprint in
    if Map.mem artwork_id artworks then (failwith "USED_ARTWORK_ID" : artwork_storage)
    else
      let artwork_id_nat = bytes_to_nat(artwork_id, 0n, 0n) in
      let new_artwork = {
        artist_name = artwork_param.artist_name;
        fingerprint = artwork_param.fingerprint;
        title = artwork_param.title;
        max_edition = artwork_param.max_edition;
        ae_amount = artwork_param.ae_amount;
        pp_amount = artwork_param.pp_amount;
        token_start_id = artwork_id_nat;
        royalty_address = artwork_param.royalty_address;
      } in
      Map.add artwork_id new_artwork artworks
  ) in
  List.fold register param artworks

(**
update_edition_metadata update editions' metadata
*)
let update_edition_metadata(param, token_metadata : update_edition_metadata_param list * token_metadata_storage) : token_metadata_storage =
  let update = (fun (metadata, p : token_metadata_storage * update_edition_metadata_param) ->
    let _ = fail_if_token_metadata_not_found (p.token_id, metadata) in
    Big_map.update p.token_id (Some p) metadata
  ) in
  List.fold update param token_metadata

let minter_main (param, _utils, _tokens, _artworks, _token_attribute
  : minter_entrypoints * bytes_utils * token_storage * artwork_storage * token_attribute_storage)
  : token_storage * artwork_storage * token_attribute_storage =
  match param with
  | Mint_editions m ->
    let mint_in = {
      ledger = _tokens.ledger;
      token_metadata = _tokens.token_metadata;
      token_attribute = _token_attribute;
    } in
    let mint_out = mint_editions (m, mint_in, _artworks) in
    let new_tokens = { _tokens with
      ledger = mint_out.ledger;
      token_metadata = mint_out.token_metadata;
    } in
    new_tokens, _artworks, mint_out.token_attribute
  | Update_edition_metadata i ->
    let updated_metadata = update_edition_metadata (i, _tokens.token_metadata) in
    let new_tokens = { _tokens with
      token_metadata = updated_metadata;
    } in
    new_tokens, _artworks, _token_attribute
  | Register_artworks a ->
    let _bytes_to_nat = match Big_map.find_opt 0n _utils with
      | None -> (failwith ff_util_func_not_declared : ((bytes * nat * nat) -> nat))
      | Some n -> n
    in
    let new_artworks = register_artworks (a, _artworks, _bytes_to_nat) in
    _tokens, new_artworks, _token_attribute
