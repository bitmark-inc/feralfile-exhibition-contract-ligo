let default_storage: asset_storage = {
  exhibition_title = "Memento 2 - Unsupervised Installation";
  code_version = "FeralfileExhibitionV2";
  secondary_sale_royalty_bps = 2000n;
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
    ("", 0x697066733a2f2f516d647a5045464846424a63376337795143564c6e784c426153334a4d486a797477514461313137696146734667);
  ];
  trustee = ({
    trustees = Set.literal[
      ("tz1Q4DxSJ2VTp4qmVBB3otPffxyBBcdFeC3S" : address);
      ("tz1fcVFFVujFmnDsWEV1nhGukJTkgXtDKZmm" : address)
    ];
    max_trustee = 2n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = true;
  bridgeable = true;
  bytes_utils = Big_map.literal[(0n, _bytes_to_nat)];
}
