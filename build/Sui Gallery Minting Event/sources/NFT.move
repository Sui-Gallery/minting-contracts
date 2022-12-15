// Copyright Sui Gallery
// SPDX-License-Identifier: Apache-2.0

// author: hikmove

module minting_event::NFT {

    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector as vec;

    const IMAGE_URL_ONE: vector<u8> = b"url1";
    const IMAGE_URL_TWO: vector<u8> = b"url2";

    const CHOICE_ONE: u8 = 1;
    const CHOICE_TWO: u8 = 2;

    const EMintedBefore: u64 = 100;
    const EInvalidChoice: u64 = 101;

    struct NFT has key, store {
        id: UID,
        // Name of the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url,
        // token id
        token_id: u64
    }

    struct Registery has key {
        id: UID,
        tokens_minted: u64,
        minters: vector<address>
    }

    struct MintNFTEvent has copy, drop {
        // The Object ID of the NFT
        id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        choice: u8,
    }

    fun init(ctx: &mut TxContext) {
        let id = object::new(ctx);
        transfer::share_object(Registery {
            id,
            tokens_minted: 0u64,
            minters: vec::empty()
        });
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext){
        let id = object::new(ctx);
        transfer::share_object(Registery {
            id,
            tokens_minted: 0u64,
            minters: vec::empty()
        });
    }

    public entry fun mint(
        choice: u8,
        reg: &mut Registery,
        ctx: &mut TxContext
    ) {
        assert!(!vec::contains(&reg.minters, &tx_context::sender(ctx)), EMintedBefore);
        assert!(choice == CHOICE_ONE || choice == CHOICE_TWO, EInvalidChoice);
        let url = IMAGE_URL_ONE;
        if (choice == CHOICE_TWO) {
            url = IMAGE_URL_TWO
        };
        let nft = NFT {
            id: object::new(ctx),
            name: string::utf8(b"Deneme"),
            description: string::utf8(b"Deneme Description"),
            url: url::new_unsafe_from_bytes(url),
            token_id: reg.tokens_minted + 1
        };
        let sender = tx_context::sender(ctx);
        event::emit(MintNFTEvent {
            id: object::uid_to_inner(&nft.id),
            creator: sender,
            choice
        });
        vec::push_back(&mut reg.minters, tx_context::sender(ctx));
        reg.tokens_minted = reg.tokens_minted + 1;
        transfer::transfer(nft, sender);
    }

    /// Update the `description` of `nft` to `new_description`
    public entry fun update_description(
        nft: &mut NFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: NFT, _: &mut TxContext) {
        let NFT { id, name: _, description: _, url: _, token_id: _ } = nft;
        object::delete(id)
    }

    //transfer
    public entry fun transfer(nft: NFT, to: address) {
        transfer::transfer(nft, to);
    }

    /// Get the NFT's `name`
    public fun name(nft: &NFT): &String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &NFT): &String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &NFT): &Url {
        &nft.url
    }

    public fun token_id(nft: &NFT): u64 {
        nft.token_id
    }

}