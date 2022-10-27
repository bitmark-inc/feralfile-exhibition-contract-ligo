#include "./ff_fa2_asset.mligo"

let default_storage: asset_storage = {
  exhibition_title = "test exhibition";
  code_version = "FeralfileExhibitionV2";
  secondary_sale_royalty_bps = 1000n;
  max_royalty_bps = 10000n;

  assets= ({
    token_metadata = (Big_map.literal[]: token_metadata_storage);
    ledger = (Big_map.literal[] : ledger);
    operators = (Big_map.literal[] : operator_storage);
  }: token_storage);
  admin = {
    admin = ("tz1MpyrZzHRy7JjRJzENcEgPcBMjGfXuxhb6" : address);
    pending_admin = (None : address option);
  };
  artworks = (Map.empty : artwork_storage);
  metadata = Big_map.literal [
    // ipfs://QmdYCrcjbdsHmhC9bZ9Tf9NvhSsTQXs8DBKpsBwGGdafrH // Alpha Code
    ("", 0x697066733a2f2f516d64594372636a626473486d684339625a395466394e76685373545158733844424b7073427747476461667248);
  ];
  trustee = ({
    trustees = Set.literal[("tz1Z7o6TDzBGzKerNMQndWEpVui1MCvRfN9A" : address)];
    max_trustee = 2n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = true;
  bridgeable = true;
  bytes_utils = Big_map.literal[(0n, _bytes_to_nat)];
}
