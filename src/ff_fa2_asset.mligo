#include "../fa2/fa2/fa2_interface.mligo"
#include "../fa2/admin/simple_admin.mligo"
#include "../fa2/token/fa2_nft_token.mligo"
#include "../fa2/minter/nft_minter.mligo"

#include "./ff_custom_token.mligo"

type artwork =
[@layout:comb]
{
  artist_name : string;
  edition_size : nat;
  fingerprint : string;
  title : string;
  token_start_id : nat;
}

type artworks = (bytes, artwork) map

type bitmark_ids = string set

type asset_storage = {
  metadata : contract_metadata;
  assets : token_storage;
  admin : admin_storage;
  minter : minter_storage;
  trustee : address;
  artworks: artworks;
  bitmark_ids: bitmark_ids;
  max_edition: nat;

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
    let new_assets, new_minter = minter_main (m, storage.assets, storage.minter) in
    let new_s = { storage with assets = new_assets; minter = new_minter; } in
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
  };
  minter = ();
  metadata = Big_map.literal [
    ("", Bytes.pack "tezos-storage:content" );
    ("content", 0x00) (* bytes encoded UTF-8 JSON *)
  ];
  trustee = ("tz1YPSCGWXwBdTncK2aCctSZAXWvGsGwVJqU" : address);
  artworks = (Map.empty : artworks);
  bitmark_ids = (Set.empty : bitmark_ids);
  max_edition = 10n
}
