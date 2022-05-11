type artwork =
[@layout:comb]
{
  artist_name : string;
  edition_size : nat;
  fingerprint : string;
  title : string;
  token_start_id : nat;
  max_edition: nat;
}

type artwork_storage = (nat, artwork) map
type bytes_nat_convert_map = (bytes, nat) map


type bitmark_id_storage = (string, nat) big_map 

type ff_token_metadata =
[@layout:comb]
{
  token_metadata : token_metadata;
  artwork_id: nat;
  edition: nat;
}
