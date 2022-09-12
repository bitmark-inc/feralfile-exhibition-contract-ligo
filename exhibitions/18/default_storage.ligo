
let default_storage: asset_storage = {
  exhibition_title = "gamma";
  secondary_sale_royalty_bps = 1500n;
  max_royalty_bps = 10000n;

  assets= ({
    token_metadata = (Big_map.literal[]: token_metadata_storage);
    ledger = (Big_map.literal[] : ledger);
    operators = (Big_map.literal[] : operator_storage);
  }: token_storage);
  admin = {
    admin = ("tz1af6xXFXVZnttqpVjnwFdza6g8LKUiT25K" : address);
    pending_admin = (None : address option);
  };
  artworks = (Map.empty : artwork_storage);
  metadata = Big_map.literal [
    ("", 0x697066733a2f2f6261666b72656963796736666c627378666e7734786d763333376d33326b75716d343273356936737761783676646d687877617336696a78346d75);
  ];
  trustee = ({
    trustees = Set.literal[];
    max_trustee = 2n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = false;
  bridgeable = false;
  bytes_utils = Big_map.literal[(0n, _bytes_to_nat)];
}
