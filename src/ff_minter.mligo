#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/fa2/fa2_errors.mligo"
#include "../fa2/token/fa2_nft_token.mligo"

#include "./ff_interface.mligo"

type minter_storage = unit

type mint_edition_param =
[@layout:comb]
{
	owner : address;
	tokens : ff_token_metadata list;
}

type artwork_param =
[@layout:comb]
{
  title : string;
  artist_name : string;
  fingerprint : string;
  max_edition : nat;
}

type issue_artworks_editions_param = nat list

type minter_entrypoints =
	| Mint_editions of mint_edition_param list
	| Register_artworks of artwork_param list

type mint_edition_acc = {
	token_metadata : token_metadata_storage;
	ledger : ledger;
}

let mint_editions(acc, param, artworks : mint_edition_acc * mint_edition_param list * artwork_storage) : mint_edition_acc =
	let mint = (fun (acc, m : mint_edition_acc * mint_edition_param) ->
		List.fold
			(fun (acc, t : mint_edition_acc * ff_token_metadata) ->
					match Map.find_opt t.artwork_id artworks with
						| None -> (failwith "ARTWORK_NOT_FOUND" : mint_edition_acc)
						| Some art ->
							let new_token_metadata = {t.token_metadata with token_id = art.token_start_id + t.edition} in
							if new_token_metadata.token_id < art.token_start_id || new_token_metadata.token_id >= art.token_start_id + art.max_edition
							  then (failwith "TOKEN_ID_OUT_OF_ARTWORK_MAX_EDITION" : mint_edition_acc)
							else if Big_map.mem new_token_metadata.token_id acc.token_metadata
							  then (failwith "USED_TOKEN_ID" : mint_edition_acc)
							else
								let new_meta = Big_map.add new_token_metadata.token_id new_token_metadata acc.token_metadata in
								let new_ledger = Big_map.add new_token_metadata.token_id m.owner acc.ledger in
								{
									token_metadata = new_meta;
									ledger = new_ledger;
								}
			) m.tokens acc
	) in
	List.fold mint param acc

let rec bytes_to_nat(convet_map, target, index, result : bytes_nat_convert_map * bytes * nat * nat) : nat =
	if Bytes.length target = 0n then (failwith "BYTES_LENGTH_ZERO" : nat)
	else if index < Bytes.length target then
		let byte = Bytes.sub index 1n target in
		match Map.find_opt byte convet_map with
			| None -> (failwith "UNDEFINED_BYTES_IN_MAP" : nat)
			| Some n ->
				bytes_to_nat(convet_map, target, index+1n, result * 256n + n)
	else
		result

(**
register_artworks creates artworks for an exhibition
*)
let register_artworks(param, artworks, convet_map : artwork_param list * artwork_storage * bytes_nat_convert_map) : artwork_storage =
	let register = (fun (artworks, artwork_param : artwork_storage * artwork_param) ->
		let packed_fingerprint = Bytes.pack artwork_param.fingerprint in

		(** Generate artwork_id using keccak256 algorithm *)
		let artwork_id = Crypto.keccak packed_fingerprint in
		if Map.mem artwork_id artworks then (failwith "USED_ARTWORK_ID" : artwork_storage)
		else
			let artwork_id_nat = bytes_to_nat(convet_map, artwork_id, 0n, 0n) in
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

let minter_main (param, _tokens, _minter, _artworks, _bytes_nat_convert_map
	: minter_entrypoints * token_storage * minter_storage * artwork_storage *bytes_nat_convert_map)
	: token_storage * minter_storage * artwork_storage =
	match param with
	| Mint_editions m ->
		let source_data = {
			ledger = _tokens.ledger;
			token_metadata = _tokens.token_metadata;
		} in
		let minted = mint_editions (source_data, m, _artworks) in
		let new_tokens = { _tokens with
			ledger = minted.ledger;
			token_metadata = minted.token_metadata;
		} in
		new_tokens, _minter, _artworks
	| Register_artworks a ->
		let new_artworks = register_artworks (a, _artworks, _bytes_nat_convert_map) in
		_tokens, _minter, new_artworks
