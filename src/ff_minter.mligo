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

type register_arts_param = artwork list

type issue_artworks_editions_param = nat list

type minter_entrypoints =
	| Never of never
	| MintEditions of mint_edition_param list
	| RegisterArtworks of register_arts_param

type mint_edition_acc = {
	token_metadata : token_metadata_storage;
	ledger : ledger;
}

let mint_editions(acc, param, artworks : mint_edition_acc * mint_edition_param list * artwork_storage) : mint_edition_acc =
	let mint = (fun (acc, m : mint_edition_acc * mint_edition_param) ->
		List.fold
			(fun (acc, t : mint_edition_acc * ff_token_metadata) ->
				if Big_map.mem t.token_metadata.token_id acc.token_metadata
				then (failwith "USED_TOKEN_ID" : mint_edition_acc)
				else 
					match Map.find_opt t.artwork_id artworks with
						| None -> (failwith "ARTWORK_NOT_FOUND" : mint_edition_acc)
						| Some art ->
							if t.token_metadata.token_id < art.token_start_id || t.token_metadata.token_id >= art.token_start_id + art.max_edition
							then (failwith "TOKEN_ID_OUT_OF_ARTWORK_MAX_EDITION" : mint_edition_acc)
							else
                let new_meta = Big_map.add t.token_metadata.token_id t.token_metadata acc.token_metadata in
                let new_ledger = Big_map.add t.token_metadata.token_id m.owner acc.ledger in
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

let register_artworks(arts, param, convet_map : artwork_storage * register_arts_param * bytes_nat_convert_map) : artwork_storage =
	let register = (fun (arts, art : artwork_storage * artwork) ->
		let packed_f = Bytes.pack art.fingerprint in
		let keccak_f = Crypto.keccak packed_f in
		let artwork_id = bytes_to_nat(convet_map, keccak_f, 0n, 0n) in
		if Map.mem artwork_id arts
		then (failwith "USED_ARTWORK_ID" : artwork_storage)
		else
			Map.add artwork_id art arts
	) in
	List.fold register param arts

let minter_main (param, _tokens, _minter, _artworks, _bytes_nat_convert_map
	: minter_entrypoints * token_storage * minter_storage * artwork_storage *bytes_nat_convert_map)
	: token_storage * minter_storage * artwork_storage=
	match param with
	| Never _ -> (failwith "INVALID_INVOCATION" : token_storage * minter_storage * artwork_storage  )
	| MintEditions m ->
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
	| RegisterArtworks artp ->
		let new_artworks = register_artworks (_artworks, artp, _bytes_nat_convert_map) in
		_tokens, _minter, new_artworks
