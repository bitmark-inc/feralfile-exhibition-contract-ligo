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

type artwork_param =
[@layout:comb]
{
  title : string;
  artist_name : string;
  fingerprint : bytes;
  max_edition : nat;
}

type issue_artworks_editions_param = nat list

type minter_entrypoints =
  | Mint_editions of mint_edition_param list
  | Update_edition_metadata of update_edition_metadata_param list
  | Register_artworks of artwork_param list

type minter_storage = {
  token_metadata : token_metadata_storage;
  ledger : ledger;
}

let ff_mint_invalid_edition = "EDITION_NUMBER_EXCEEDS_MAX_EDITION_LIMITS"
let ff_mint_duplicated_token_id = "TOKEN_HAS_ALREADY_ISSUED"
let ff_token_not_found = "TOKEN_NOT_FOUND"

(** check if the token edition exceed the maximum number of the artwork *)
let fail_if_invalid_edition (edition, artwork : nat * artwork) : unit =
  if edition > artwork.max_edition
    then failwith ff_mint_invalid_edition
  else unit

(** check if a token_id is duplicated *)
let fail_if_duplicated_token_id (token_id, storage : nat * minter_storage) : unit =
  if Big_map.mem token_id storage.token_metadata || Big_map.mem token_id storage.ledger
    then failwith ff_mint_duplicated_token_id
  else unit

(** check if a token is not found *)
let fail_if_token_not_found (token_id, storage : nat * minter_storage) : unit =
  if not Big_map.mem token_id storage.token_metadata || not Big_map.mem token_id storage.ledger
    then failwith ff_token_not_found
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
        let new_token_metadata = {
          token_id = token_id;
          token_info = t.token_info;
        } in

        let _ = fail_if_duplicated_token_id(token_id, storage) in

        let new_metadata = Big_map.add token_id new_token_metadata storage.token_metadata in
        let new_ledger = Big_map.add token_id owner storage.ledger in
        {
          token_metadata = new_metadata;
          ledger = new_ledger;
        }
  in

  List.fold (fun (storage, m : minter_storage * mint_edition_param) ->
    List.fold (mint_tokens_for_owner m.owner) m.tokens storage
  ) param storage

(**
register_artworks creates artworks for an exhibition
*)
let register_artworks(param, artworks : artwork_param list * artwork_storage) : artwork_storage =
  let register = (fun (artworks, artwork_param : artwork_storage * artwork_param) ->
    (** Generate artwork_id using keccak256 algorithm *)
    let artwork_id = Crypto.keccak artwork_param.fingerprint in
    if Map.mem artwork_id artworks then (failwith "USED_ARTWORK_ID" : artwork_storage)
    else
      let artwork_id_nat = (Tezos.constant "exprutNrs68aNmrp3DSif5U7Usq2e8f5ZH9xbDekcKdEErYPv11brk" : (bytes * nat * nat) -> nat)(artwork_id, 0n, 0n) in
      let new_artwork = {
        artist_name = artwork_param.artist_name;
        fingerprint = artwork_param.fingerprint;
        title = artwork_param.title;
        max_edition = artwork_param.max_edition;
        token_start_id = artwork_id_nat;
      } in
      Map.add artwork_id new_artwork artworks
  ) in
  List.fold register param artworks

(**
update_edition_metadata update editions' metadata
*)
let update_edition_metadata(param, storage : update_edition_metadata_param list * minter_storage) : minter_storage =
  let update = (fun (storage, p : minter_storage * update_edition_metadata_param) ->
    let _ = fail_if_token_not_found (p.token_id, storage) in
    {
      storage with
      token_metadata = Big_map.update p.token_id (Some p) storage.token_metadata
    }
  ) in
  List.fold update param storage

let minter_main (param, _tokens, _artworks
  : minter_entrypoints * token_storage * artwork_storage)
  : token_storage * artwork_storage =
  match param with
  | Mint_editions m ->
    let mint_in = {
      ledger = _tokens.ledger;
      token_metadata = _tokens.token_metadata;
    } in
    let mint_out = mint_editions (m, mint_in, _artworks) in
    let new_tokens = { _tokens with
      ledger = mint_out.ledger;
      token_metadata = mint_out.token_metadata;
    } in
    new_tokens, _artworks
  | Update_edition_metadata i ->
    let update_edition_in = {
      ledger = _tokens.ledger;
      token_metadata = _tokens.token_metadata;
    } in
    let update_edition_out = update_edition_metadata (i, update_edition_in) in
    let new_tokens = { _tokens with
      token_metadata = update_edition_out.token_metadata;
    } in
    new_tokens, _artworks
  | Register_artworks a ->
    let new_artworks = register_artworks (a, _artworks) in
    _tokens, new_artworks
