(**
Feral File exhibition artwork structure
*)
type artwork =
{
  title : string;
  artist_name : string;
  fingerprint : bytes;
  max_edition : nat;
  token_start_id : nat;
  royalty_address : address;
}

(**
Feral File edition token artribute structure
*)
type token_attribute =
{
  artwork_id : bytes;
  edition_number : nat;
  burned : bool;
}

(**
Feral File exhibition artworks storage
*)
type artwork_storage = (bytes, artwork) map

(**
Feral File exhibition token artribute storage
*)
type token_attribute_storage = (nat, token_attribute) big_map

let fa2_invalid_signature = "FA2_INVALID_SIGNATURE"
let fa2_publickey_address_mismatch = "FA2_PUBLICKEY_ADDRESS_MISMATCH"
let fa2_expired_timestamp = "FA2_EXPIRED_TIMESTAMP"

let ff_token_not_burnable = "TOKEN_NOT_BURNABLE"

let ff_token_not_found = "TOKEN_NOT_FOUND"
let ff_token_metadata_not_found = "TOKEN_METADATA_NOT_FOUND"
let ff_token_attribute_not_found = "TOKEN_ATTRIBUTE_NOT_FOUND"

let ff_extra_xtz_sent = "EXTRA_XTZ_SENT"

(** check if a token is not found *)
let fail_if_token_not_found (token_id, ledger : nat * ledger) : unit =
  if not Big_map.mem token_id ledger
    then failwith ff_token_not_found
  else unit

(** check if a token_metadata is not found *)
let fail_if_token_metadata_not_found (token_id, metadata : nat * token_metadata_storage) : unit =
  if not Big_map.mem token_id metadata
    then failwith ff_token_metadata_not_found
  else unit

(** check if a token_metadata is not found *)
// [@inline]
let fail_if_sender_not_token_owner (owner : address) : unit =
  if owner <> Tezos.sender
    then failwith fa2_not_owner
  else unit
