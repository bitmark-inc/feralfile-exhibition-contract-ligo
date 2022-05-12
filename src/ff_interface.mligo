type artwork =
[@layout:comb]
{
  artist_name : string;
  fingerprint : string;
  title : string;
  token_start_id : nat;
  max_edition: nat;
}

type artwork_storage = (bytes, artwork) map

type bytes_nat_convert_map = (bytes, nat) map

type ff_token_metadata =
[@layout:comb]
{
  token_metadata : token_metadata;
  artwork_id: bytes;
  edition: nat;
}
