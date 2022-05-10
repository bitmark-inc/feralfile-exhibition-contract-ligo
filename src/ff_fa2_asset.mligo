#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/admin/simple_admin.mligo"
#include "../fa2/token/fa2_nft_token.mligo"
#include "../fa2/minter/nft_minter.mligo"

#include "./ff_custom_token.mligo"

type asset_storage = {
  metadata : contract_metadata;
  assets : token_storage;
  admin : admin_storage;
  minter : minter_storage;
}

type asset_entrypoints =
  | Assets of fa2_entry_points
  | FFAssets of ff_entry_points
  | Admin of admin_entrypoints
  | Minter of minter_entrypoints

[@inline]
let fail_if_not_minter (storage : asset_storage) : unit =
  let _ = fail_if_not_admin storage.admin in
  unit

let asset_main (param, storage : asset_entrypoints * asset_storage)
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
    let new_assets, new_minter = minter_main (m, storage.assets, storage.minter) in
    let new_s = { storage with assets = new_assets; minter = new_minter; } in
    ([] : operation list), new_s