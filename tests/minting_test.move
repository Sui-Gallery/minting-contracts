#[test_only]
module minting_event::nft_test {

    use minting_event::NFT::{Self, NFT, Registery};
    use sui::test_scenario::Self;
    use sui::url;

    const MINTER1: address = @0x1;
    const MINTER2: address = @0x2;
    const ADMIN: address = @0x3;


    #[test]
    fun minting_test() {
        let scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            NFT::init_for_testing(ctx);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
           let reg = test_scenario::take_shared<Registery>(scenario);
           let ctx = test_scenario::ctx(scenario); 
           NFT::mint(1, &mut reg, ctx);
           test_scenario::return_shared(reg);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
            let nft1 = test_scenario::take_from_address<NFT>(scenario, MINTER1);
            assert!(NFT::token_id(&nft1) == 1, 10);
            assert!(*NFT::url(&nft1) == *&url::new_unsafe_from_bytes(b"url1"), 11);
            test_scenario::return_to_address<NFT>(MINTER1, nft1);
        };
        test_scenario::next_tx(scenario, MINTER2);
        {
           let reg = test_scenario::take_shared<Registery>(scenario);
           let ctx = test_scenario::ctx(scenario); 
           NFT::mint(2, &mut reg, ctx);
           test_scenario::return_shared(reg);
        };
        test_scenario::next_tx(scenario, MINTER2);
        {
           let nft2 = test_scenario::take_from_address<NFT>(scenario, MINTER2);
           assert!(NFT::token_id(&nft2) == 2, 12);
           assert!(*NFT::url(&nft2) == *&url::new_unsafe_from_bytes(b"url2"), 13);
           test_scenario::return_to_address<NFT>(MINTER2, nft2);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = NFT::EMintedBefore)]
    fun mint_twice() {
        let scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            NFT::init_for_testing(ctx);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
           let reg = test_scenario::take_shared<Registery>(scenario);
           let ctx = test_scenario::ctx(scenario); 
           NFT::mint(1, &mut reg, ctx);
           test_scenario::return_shared(reg);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
            let nft1 = test_scenario::take_from_address<NFT>(scenario, MINTER1);
            assert!(NFT::token_id(&nft1) == 1, 10);
            assert!(*NFT::url(&nft1) == *&url::new_unsafe_from_bytes(b"url1"), 11);
            test_scenario::return_to_address<NFT>(MINTER1, nft1);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
           let reg = test_scenario::take_shared<Registery>(scenario);
           let ctx = test_scenario::ctx(scenario); 
           NFT::mint(2, &mut reg, ctx);
           test_scenario::return_shared(reg);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = NFT::EInvalidChoice)]
    fun mint_invalid_choice() {
        let scenario_val = test_scenario::begin(ADMIN);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            NFT::init_for_testing(ctx);
        };
        test_scenario::next_tx(scenario, MINTER1);
        {
           let reg = test_scenario::take_shared<Registery>(scenario);
           let ctx = test_scenario::ctx(scenario); 
           NFT::mint(3, &mut reg, ctx);
           test_scenario::return_shared(reg);
        };
        test_scenario::end(scenario_val);
    }

}