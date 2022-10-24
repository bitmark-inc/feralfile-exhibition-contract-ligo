let default_storage: asset_storage = {
  exhibition_title = "Simulation Sketchbook: Works in Process";
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
    ("", 0x697066733a2f2f516d5375344b4e676139656372536f4d417a7045374179344a3731454a654c6354346d39373235674558526a7244);
  ];
  trustee = ({
    trustees = Set.literal[
      ("tz1Q4DxSJ2VTp4qmVBB3otPffxyBBcdFeC3S" : address);
      ("tz1fcVFFVujFmnDsWEV1nhGukJTkgXtDKZmm" : address)
    ];
    max_trustee = 2n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = false;
  bridgeable = true;
  bytes_utils = Big_map.literal[(0n, _bytes_to_nat)];
}
