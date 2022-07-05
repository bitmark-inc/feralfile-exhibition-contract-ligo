#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/admin/simple_admin.mligo"
#include "../fa2/token/fa2_nft_token.mligo"
#include "../fa2/fa2/fa2_errors.mligo"

#include "./ff_interface.mligo"

#include "./ff_minter.mligo"
#include "./ff_burner.mligo"
#include "./ff_custom_token.mligo"
#include "./ff_trustee.mligo"

type asset_storage =
{
  // exhibition metadata
  exhibition_title : string;
  exhibition_max_edition : nat;
  secondary_sale_royalty_bps : nat;
  max_royalty_bps : nat;

  assets : token_storage;
  admin : admin_storage;
  artworks: artwork_storage;
  metadata : contract_metadata;
  trustee : trustee_storage;
  token_attribute: token_attribute_storage;
  burnable : bool;
  bridgable : bool;
}

type asset_entrypoints =
  | Assets of fa2_entry_points
  | Admin of admin_entrypoints
  | Minter of minter_entrypoints
  | Burn_editions of burn_edition_param list
  | Authorized_transfer of authorized_transfer list
  | Trustee of trustee_entrypoints

[@inline]
let fail_if_not_authorized_user (storage : asset_storage) : unit =
  if not is_trustee (storage.trustee)
  then
    let _ = fail_if_not_admin storage.admin in
    unit
  else unit

[@inline]
let fail_if_token_not_burnable (burnable : bool) : unit =
  if not burnable
    then failwith ff_token_not_burnable
  else unit

let main (param, storage : asset_entrypoints * asset_storage)
    : (operation list) * asset_storage =
  match param with
  | Assets a ->
    let ops, new_assets = fa2_main (a, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    (ops, new_s)

  | Admin a ->
    let ops, new_admin = admin_main (a, storage.admin) in
    let new_s = { storage with admin = new_admin; } in
    (ops, new_s)

  | Minter m ->
    let _ = fail_if_not_authorized_user storage in
    let new_assets, new_artworks, new_token_attribute = minter_main (m, storage.assets, storage.artworks, storage.token_attribute, storage.exhibition_max_edition) in
    let new_s = { storage with assets = new_assets; artworks = new_artworks; token_attribute = new_token_attribute } in
    ([] : operation list) , new_s

  | Burn_editions b ->
    let _ = fail_if_token_not_burnable storage.burnable in
    let new_assets, new_token_attribute = burn_editions (b, storage.assets, storage.token_attribute) in
    let new_s = { storage with assets = new_assets; token_attribute = new_token_attribute } in
    ([] : operation list) , new_s

  | Authorized_transfer transfers ->
    let _ = fail_if_not_authorized_user storage in
    let new_assets = authorized_transfer (transfers, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    ([] : operation list), new_s

  | Trustee t ->
    let _ = fail_if_not_admin storage.admin in
    let new_trustee = trustee_main (t, storage.trustee) in
    let new_s = { storage with trustee = new_trustee; } in
    ([] : operation list), new_s

let default_storage: asset_storage = {
  exhibition_title = "test exhibition";
  exhibition_max_edition = 1000n;
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
    ("", Bytes.pack "tezos-storage:content" );
    ("content", 0x00) (* bytes encoded UTF-8 JSON *)
  ];
  trustee = ({
    trustees = Set.literal[("tz1Z7o6TDzBGzKerNMQndWEpVui1MCvRfN9A" : address)];
    max_trustee = 2n
  }: trustee_storage);
  token_attribute = (Big_map.literal[] : token_attribute_storage);
  burnable = true;
  bridgable = false;
}
