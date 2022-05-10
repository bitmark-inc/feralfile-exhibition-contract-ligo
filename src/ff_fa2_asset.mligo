#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/admin/pausable_simple_admin.mligo"
#include "../fa2/token/fa2_nft_token.mligo"

#include "./ff_custom_token.mligo"
#include "./ff_minter.mligo"
#include "./ff_interface.mligo"

type asset_storage = {
  assets : token_storage;
  admin : admin_storage;
  minter : minter_storage;
  artworks: artwork_storage;
  bitmark_ids: bitmark_id_storage;
  metadata : contract_metadata;
  max_edition: nat;
  trustee : address;
}

type asset_entrypoints =
  | Assets of fa2_entry_points
  | FFAssets of ff_entry_points
  | Admin of admin_entrypoints
  | Minter of minter_entrypoints

[@inline]
let fail_if_not_minter (storage : asset_storage) : unit =
  if Tezos.sender <> storage.trustee 
  then
    let _ = fail_if_not_admin storage.admin in unit
  else unit

let main (param, storage : asset_entrypoints * asset_storage)
    : (operation list) * asset_storage =
  match param with
  | Assets a ->
    let _ = fail_if_paused storage.admin in
    let ops, new_assets = fa2_main (a, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    (ops, new_s)

  | FFAssets a ->
    let _ = fail_if_not_admin storage.admin in
    let ops, new_assets = ff_main (a, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    (ops, new_s)

  | Admin a ->
    let ops, new_admin = admin_main (a, storage.admin) in
    let new_s = { storage with admin = new_admin; } in
    (ops, new_s)

  | Minter m ->
    let _ = fail_if_paused storage.admin in
    let _ = fail_if_not_minter storage in
    let new_assets, new_minter, new_bitmark_ids = minter_main (m, storage.assets, storage.bitmark_ids, storage.minter) in
    let new_s = { storage with assets = new_assets; minter = new_minter; bitmark_ids = new_bitmark_ids; } in
    ([] : operation list), new_s

let sample_storage : asset_storage = {
  assets = {
    token_metadata = (Big_map.empty : token_metadata_storage);
    ledger = (Big_map.empty : ledger);
    operators = (Big_map.empty : operator_storage);
  };
  admin = {
    admin = ("tz1YPSCGWXwBdTncK2aCctSZAXWvGsGwVJqU" : address);
    pending_admin = (None : address option);
    paused = false
  };
  minter = ();
  metadata = Big_map.literal [
    ("", Bytes.pack "tezos-storage:content" );
    ("content", 0x00) (* bytes encoded UTF-8 JSON *)
  ];
  trustee = ("tz1YPSCGWXwBdTncK2aCctSZAXWvGsGwVJqU" : address);
  artworks = (Map.empty : artwork_storage);
  bitmark_ids = (Big_map.empty : bitmark_id_storage);
  max_edition = 10n
}
