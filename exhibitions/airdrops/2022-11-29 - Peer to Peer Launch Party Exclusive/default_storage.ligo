let default_storage: asset_storage = {
  exhibition_title = "Peer to Peer Launch Party Exclusive";
  code_version = "FeralfileExhibitionV2";
  secondary_sale_royalty_bps = 1000n;
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
    ("", 0x697066733a2f2f516d593868465a61595470596a725475564639523362347358344a384b38395951326b55725731384c634744474c);
  ];
  trustee = ({
    trustees = Set.literal[
      ("tz1Q4DxSJ2VTp4qmVBB3otPffxyBBcdFeC3S" : address);
      ("tz1fcVFFVujFmnDsWEV1nhGukJTkgXtDKZmm" : address)
    ];
    max_trustee = 4n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = true;
  bridgeable = true;
  bytes_utils = Big_map.literal[(0n, _bytes_to_nat)];
}
