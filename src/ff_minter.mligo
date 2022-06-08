#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/fa2/fa2_errors.mligo"
#include "../fa2/token/fa2_nft_token.mligo"

#include "./ff_interface.mligo"

type minter_storage = unit

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

type issue_artworks_editions_param = nat list

type minter_entrypoints =
	| Mint_editions of mint_edition_param list
	| Register_artworks of artwork_param list

type mint_storage = {
	token_metadata : token_metadata_storage;
	ledger : ledger;
}

let convert_map = (Map.literal [
    (0x00, 0n); (0x01, 1n);
    (0x02, 2n); (0x03, 3n);
    (0x04, 4n); (0x05, 5n);
    (0x06, 6n); (0x07, 7n);
    (0x08, 8n); (0x09, 9n);
    (0x0a, 10n); (0x0b, 11n);
    (0x0c, 12n); (0x0d, 13n);
    (0x0e, 14n); (0x0f, 15n);
    (0x10, 16n); (0x11, 17n);
    (0x12, 18n); (0x13, 19n);
    (0x14, 20n); (0x15, 21n);
    (0x16, 22n); (0x17, 23n);
    (0x18, 24n); (0x19, 25n);
    (0x1a, 26n); (0x1b, 27n);
    (0x1c, 28n); (0x1d, 29n);
    (0x1e, 30n); (0x1f, 31n);
    (0x20, 32n); (0x21, 33n);
    (0x22, 34n); (0x23, 35n);
    (0x24, 36n); (0x25, 37n);
    (0x26, 38n); (0x27, 39n);
    (0x28, 40n); (0x29, 41n);
    (0x2a, 42n); (0x2b, 43n);
    (0x2c, 44n); (0x2d, 45n);
    (0x2e, 46n); (0x2f, 47n);
    (0x30, 48n); (0x31, 49n);
    (0x32, 50n); (0x33, 51n);
    (0x34, 52n); (0x35, 53n);
    (0x36, 54n); (0x37, 55n);
    (0x38, 56n); (0x39, 57n);
    (0x3a, 58n); (0x3b, 59n);
    (0x3c, 60n); (0x3d, 61n);
    (0x3e, 62n); (0x3f, 63n);
    (0x40, 64n); (0x41, 65n);
    (0x42, 66n); (0x43, 67n);
    (0x44, 68n); (0x45, 69n);
    (0x46, 70n); (0x47, 71n);
    (0x48, 72n); (0x49, 73n);
    (0x4a, 74n); (0x4b, 75n);
    (0x4c, 76n); (0x4d, 77n);
    (0x4e, 78n); (0x4f, 79n);
    (0x50, 80n); (0x51, 81n);
    (0x52, 82n); (0x53, 83n);
    (0x54, 84n); (0x55, 85n);
    (0x56, 86n); (0x57, 87n);
    (0x58, 88n); (0x59, 89n);
    (0x5a, 90n); (0x5b, 91n);
    (0x5c, 92n); (0x5d, 93n);
    (0x5e, 94n); (0x5f, 95n);
    (0x60, 96n); (0x61, 97n);
    (0x62, 98n); (0x63, 99n);
    (0x64, 100n); (0x65, 101n);
    (0x66, 102n); (0x67, 103n);
    (0x68, 104n); (0x69, 105n);
    (0x6a, 106n); (0x6b, 107n);
    (0x6c, 108n); (0x6d, 109n);
    (0x6e, 110n); (0x6f, 111n);
    (0x70, 112n); (0x71, 113n);
    (0x72, 114n); (0x73, 115n);
    (0x74, 116n); (0x75, 117n);
    (0x76, 118n); (0x77, 119n);
    (0x78, 120n); (0x79, 121n);
    (0x7a, 122n); (0x7b, 123n);
    (0x7c, 124n); (0x7d, 125n);
    (0x7e, 126n); (0x7f, 127n);
    (0x80, 128n); (0x81, 129n);
    (0x82, 130n); (0x83, 131n);
    (0x84, 132n); (0x85, 133n);
    (0x86, 134n); (0x87, 135n);
    (0x88, 136n); (0x89, 137n);
    (0x8a, 138n); (0x8b, 139n);
    (0x8c, 140n); (0x8d, 141n);
    (0x8e, 142n); (0x8f, 143n);
    (0x90, 144n); (0x91, 145n);
    (0x92, 146n); (0x93, 147n);
    (0x94, 148n); (0x95, 149n);
    (0x96, 150n); (0x97, 151n);
    (0x98, 152n); (0x99, 153n);
    (0x9a, 154n); (0x9b, 155n);
    (0x9c, 156n); (0x9d, 157n);
    (0x9e, 158n); (0x9f, 159n);
    (0xa0, 160n); (0xa1, 161n);
    (0xa2, 162n); (0xa3, 163n);
    (0xa4, 164n); (0xa5, 165n);
    (0xa6, 166n); (0xa7, 167n);
    (0xa8, 168n); (0xa9, 169n);
    (0xaa, 170n); (0xab, 171n);
    (0xac, 172n); (0xad, 173n);
    (0xae, 174n); (0xaf, 175n);
    (0xb0, 176n); (0xb1, 177n);
    (0xb2, 178n); (0xb3, 179n);
    (0xb4, 180n); (0xb5, 181n);
    (0xb6, 182n); (0xb7, 183n);
    (0xb8, 184n); (0xb9, 185n);
    (0xba, 186n); (0xbb, 187n);
    (0xbc, 188n); (0xbd, 189n);
    (0xbe, 190n); (0xbf, 191n);
    (0xc0, 192n); (0xc1, 193n);
    (0xc2, 194n); (0xc3, 195n);
    (0xc4, 196n); (0xc5, 197n);
    (0xc6, 198n); (0xc7, 199n);
    (0xc8, 200n); (0xc9, 201n);
    (0xca, 202n); (0xcb, 203n);
    (0xcc, 204n); (0xcd, 205n);
    (0xce, 206n); (0xcf, 207n);
    (0xd0, 208n); (0xd1, 209n);
    (0xd2, 210n); (0xd3, 211n);
    (0xd4, 212n); (0xd5, 213n);
    (0xd6, 214n); (0xd7, 215n);
    (0xd8, 216n); (0xd9, 217n);
    (0xda, 218n); (0xdb, 219n);
    (0xdc, 220n); (0xdd, 221n);
    (0xde, 222n); (0xdf, 223n);
    (0xe0, 224n); (0xe1, 225n);
    (0xe2, 226n); (0xe3, 227n);
    (0xe4, 228n); (0xe5, 229n);
    (0xe6, 230n); (0xe7, 231n);
    (0xe8, 232n); (0xe9, 233n);
    (0xea, 234n); (0xeb, 235n);
    (0xec, 236n); (0xed, 237n);
    (0xee, 238n); (0xef, 239n);
    (0xf0, 240n); (0xf1, 241n);
    (0xf2, 242n); (0xf3, 243n);
    (0xf4, 244n); (0xf5, 245n);
    (0xf6, 246n); (0xf7, 247n);
    (0xf8, 248n); (0xf9, 249n);
    (0xfa, 250n); (0xfb, 251n);
    (0xfc, 252n); (0xfd, 253n);
    (0xfe, 254n); (0xff, 255n)
  ]: bytes_nat_convert_map)

(**
mint_editions mint editions for the exhibition
*)
let mint_editions(param, storage, artworks : mint_edition_param list * mint_storage * artwork_storage) : mint_storage =
	let mint_tokens_for_owner (owner: address) (storage, t : mint_storage * ff_token_metadata) =
		match Map.find_opt t.artwork_id artworks with
			| None -> (failwith "ARTWORK_NOT_FOUND" : mint_storage)
			| Some art ->
				let _ = fail_if_invalid_edition(t.edition, art) in

				let token_id = art.token_start_id + t.edition in
				let new_token_metadata = {
					token_id = token_id;
					token_info = t.token_info;
				} in

				let _ = fail_if_duplicated_token_id(token_id, storage.token_metadata) in

				let new_metadata = Big_map.add token_id new_token_metadata storage.token_metadata in
				let new_ledger = Big_map.add token_id owner storage.ledger in
				{
					token_metadata = new_metadata;
					ledger = new_ledger;
				}
	in

	List.fold (fun (storage, m : mint_storage * mint_edition_param) ->
		List.fold (mint_tokens_for_owner m.owner) m.tokens storage
	) param storage

let rec bytes_to_nat(target, index, result : bytes * nat * nat) : nat =
	if Bytes.length target = 0n then (failwith "BYTES_LENGTH_ZERO" : nat)
	else if index < Bytes.length target then
		let byte = Bytes.sub index 1n target in
		match Map.find_opt byte convert_map with
			| None -> (failwith "UNDEFINED_BYTES_IN_MAP" : nat)
			| Some n ->
				bytes_to_nat(target, index+1n, result * 256n + n)
	else
		result

(**
register_artworks creates artworks for an exhibition
*)
let register_artworks(param, artworks : artwork_param list * artwork_storage) : artwork_storage =
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
				token_start_id = artwork_id_nat;
			} in
			Map.add artwork_id new_artwork artworks
	) in
	List.fold register param artworks

let minter_main (param, _tokens, _minter, _artworks
	: minter_entrypoints * token_storage * minter_storage * artwork_storage)
	: token_storage * minter_storage * artwork_storage =
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
		new_tokens, _minter, _artworks
	| Register_artworks a ->
		let new_artworks = register_artworks (a, _artworks) in
		_tokens, _minter, new_artworks
