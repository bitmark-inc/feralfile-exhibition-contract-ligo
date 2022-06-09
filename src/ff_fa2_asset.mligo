#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/admin/pausable_simple_admin.mligo"
#include "../fa2/token/fa2_nft_token.mligo"

#include "./ff_interface.mligo"
#include "./ff_minter.mligo"
#include "./ff_custom_token.mligo"

type asset_storage =
{
  assets : token_storage;
  admin : admin_storage;
  artworks: artwork_storage;
  metadata : contract_metadata;
  trustee : address;
}

type asset_entrypoints =
  | Assets of fa2_entry_points
  | Admin of admin_entrypoints
  | Minter of minter_entrypoints
  | Authorized_transfer of authorized_transfer list

[@inline]
let fail_if_not_trustee (storage : asset_storage) : unit =
  if Tezos.sender <> storage.trustee
  then
    let _ = fail_if_not_admin storage.admin in
    unit
  else unit

let main (param, storage : asset_entrypoints * asset_storage)
    : (operation list) * asset_storage =
  match param with
  | Assets a ->
    let _ = fail_if_paused storage.admin in
    let ops, new_assets = fa2_main (a, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    (ops, new_s)

  | Admin a ->
    let ops, new_admin = admin_main (a, storage.admin) in
    let new_s = { storage with admin = new_admin; } in
    (ops, new_s)

  | Minter m ->
    let _ = fail_if_paused storage.admin in
    let _ = fail_if_not_trustee storage in
    let new_assets, new_artworks = minter_main (m, storage.assets, storage.artworks) in
    let new_s = { storage with assets = new_assets; artworks = new_artworks; } in
    ([] : operation list) , new_s

  | Authorized_transfer transfers ->
    let _ = fail_if_not_trustee storage in
    let new_assets = authorized_transfer (transfers, storage.assets) in
    let new_s = { storage with assets = new_assets; } in
    ([] : operation list), new_s

let default_storage: asset_storage = {
  assets= ({
    token_metadata = (Big_map.literal[]: token_metadata_storage);
    ledger = (Big_map.literal[] : ledger);
    operators = (Big_map.literal[] : operator_storage);
  }: token_storage);
  admin = {
    admin = ("tz1MpyrZzHRy7JjRJzENcEgPcBMjGfXuxhb6" : address);
    pending_admin = (None : address option);
    paused = false;
  };
  artworks = (Map.empty : artwork_storage);
  metadata = Big_map.literal [
    ("", Bytes.pack "tezos-storage:content" );
    ("content", 0x00) (* bytes encoded UTF-8 JSON *)
  ];
  trustee = ("tz1Z7o6TDzBGzKerNMQndWEpVui1MCvRfN9A" : address);
}
