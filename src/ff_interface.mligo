(**
Feral File exhibition artwork structure
*)
type artwork =
{
  title : string;
  artist_name : string;
  fingerprint : bytes;
  max_edition: nat;
  token_start_id : nat;
}

(**
Feral File exhibition artworks storage
*)
type artwork_storage = (bytes, artwork) map

(**
A map between bytes and nat. This is to help
generating token start id with nat type.
*)
type bytes_nat_convert_map = (bytes, nat) map

let fa2_invalid_signature = "FA2_INVALID_SIGNATURE"
let fa2_publickey_address_mismatch = "FA2_PUBLICKEY_ADDRESS_MISMATCH"
let fa2_expired_timestamp = "FA2_EXPIRED_TIMESTAMP"
