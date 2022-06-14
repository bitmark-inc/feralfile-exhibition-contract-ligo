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

type burn_edition_param =
[@layout:comb]
{
	owner : address;
	tokens : token_id list;
}

type artwork_param =
[@layout:comb]
{
	title : string;
	artist_name : string;
	fingerprint : bytes;
	max_edition : nat;
}

let ff_mint_invalid_edition = "EDITION_NUMBER_EXCEEDS_MAX_EDITION_LIMITS"
let ff_mint_duplicated_token_id = "TOKEN_HAS_ALREADY_ISSUED"
let ff_token_metadata_not_found = "TOKEN_METADATA_NOT_FOUND"

(** check if the token edition exceed the maximum number of the artwork *)
let fail_if_invalid_edition (edition, artwork : nat * artwork) : unit =
	if edition > artwork.max_edition
		then failwith ff_mint_invalid_edition
	else unit

(** check if a token is minted *)
let fail_if_duplicated_token_id (token_id, metadata : nat * token_metadata_storage) : unit =
	if Big_map.mem token_id metadata
		then failwith ff_mint_duplicated_token_id
	else unit

(** check if a token metadata is found *)
let fail_if_token_metadata_not_found (token_id, metadata : nat * token_metadata_storage) : unit =
	if not Big_map.mem token_id metadata
		then failwith ff_token_metadata_not_found
	else unit

type issue_artworks_editions_param = nat list

type minter_entrypoints =
	| Burn_editions of burn_edition_param list
	| Mint_editions of mint_edition_param list
	| Register_artworks of artwork_param list

type minter_storage = {
	token_metadata : token_metadata_storage;
	ledger : ledger;
}

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

			let _ = fail_if_duplicated_token_id(token_id, storage.token_metadata) in

			{
				token_metadata = Big_map.add token_id new_token_metadata storage.token_metadata;
				ledger = Big_map.add token_id owner storage.ledger;
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
			let artwork_id_nat = (Tezos.constant "exprtqrC8jBxHAW1QMnPwZjarLpRj2ZLyK9stUhwtavoGPoR4BwHpz" : (bytes * nat * nat) -> nat)(artwork_id, 0n, 0n) in
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

let burn_editions(param, storage : burn_edition_param list * minter_storage) : minter_storage =
  	let burn_tokens_for_owner (owner: address) (storage, tid : minter_storage * token_id) =
	  	let _ = fail_if_token_metadata_not_found (tid, storage.token_metadata) in
		match Big_map.find_opt tid storage.ledger with
		| None -> (failwith fa2_token_undefined : minter_storage)
		| Some o ->
			if o <> owner then (failwith fa2_not_owner : minter_storage)
			else 
				{
					token_metadata = Big_map.remove tid storage.token_metadata;
					ledger = Big_map.remove tid storage.ledger;
				}
	in

	List.fold (fun (storage, b : minter_storage * burn_edition_param) ->
		List.fold (burn_tokens_for_owner b.owner) b.tokens storage
	) param storage

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
	| Burn_editions b ->
		let burn_in = {
			ledger = _tokens.ledger;
			token_metadata = _tokens.token_metadata;
		} in
		let burn_out = burn_editions (b, burn_in) in
		let new_tokens = { _tokens with
			ledger = burn_out.ledger;
			token_metadata = burn_out.token_metadata;
		} in
		new_tokens, _artworks
	| Register_artworks a ->
		let new_artworks = register_artworks (a, _artworks) in
		_tokens, new_artworks
