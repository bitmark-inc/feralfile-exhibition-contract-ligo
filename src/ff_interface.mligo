(**
Feral File exhibition artwork structure
*)
type artwork =
{
  title : string;
  artist_name : string;
  fingerprint : string;
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

type ff_token_metadata =
[@layout:comb]
{
  token_info: (string, bytes) map;
  artwork_id: bytes;
  edition: nat;
}
