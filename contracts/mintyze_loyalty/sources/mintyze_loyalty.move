/// Module: mintyze_loyalty
/// Utility NFT Smart Contract for B2B Loyalty Platform on Sui
module mintyze_loyalty::loyalty_nft;

use std::string::String;
use sui::event;
use sui::clock::Clock;

// ============== Error Codes ==============
const ENotBrandOwner: u64 = 0;
const ENFTExpired: u64 = 1;
const EInvalidTier: u64 = 2;
const EBenefitNotFound: u64 = 3;
const ECampaignInactive: u64 = 4;

// ============== Constants ==============
const TIER_BRONZE: u8 = 1;
const TIER_SILVER: u8 = 2;
const TIER_GOLD: u8 = 3;

// ============== Structs ==============

/// Capability object that authorizes a brand to create campaigns and mint NFTs
public struct BrandCap has key, store {
    id: UID,
    brand_wallet: address,
    brand_name: String,
}

/// Loyalty NFT representing customer membership with tier, expiry, and benefits
public struct LoyaltyNFT has key, store {
    id: UID,
    brand_id: address,
    campaign_id: String,
    customer_wallet: address,
    tier: u8,
    expiry_timestamp: u64,
    benefits: vector<String>,
    minted_at: u64,
    referral_code: String,
}

/// Campaign configuration stored on-chain
public struct Campaign has key, store {
    id: UID,
    brand_id: address,
    campaign_id: String,
    name: String,
    is_active: bool,
    created_at: u64,
}

// ============== Events ==============

public struct BrandRegistered has copy, drop {
    brand_wallet: address,
    brand_name: String,
}

public struct CampaignCreated has copy, drop {
    brand_id: address,
    campaign_id: String,
    name: String,
}

public struct NFTMinted has copy, drop {
    nft_id: address,
    brand_id: address,
    campaign_id: String,
    customer_wallet: address,
    tier: u8,
}

public struct TierUpgraded has copy, drop {
    nft_id: address,
    old_tier: u8,
    new_tier: u8,
}

public struct BenefitVerified has copy, drop {
    nft_id: address,
    benefit: String,
    is_valid: bool,
}

// ============== Brand Functions ==============

/// Register a new brand and receive a BrandCap
public fun register_brand(
    brand_name: String,
    ctx: &mut TxContext
): BrandCap {
    let brand_wallet = ctx.sender();
    
    event::emit(BrandRegistered {
        brand_wallet,
        brand_name,
    });

    BrandCap {
        id: object::new(ctx),
        brand_wallet,
        brand_name,
    }
}

/// Entry function to register brand and transfer cap to sender
entry fun register_brand_entry(
    brand_name: String,
    ctx: &mut TxContext
) {
    let cap = register_brand(brand_name, ctx);
    transfer::transfer(cap, ctx.sender());
}

// ============== Campaign Functions ==============

/// Create a new campaign (brand only)
public fun create_campaign(
    brand_cap: &BrandCap,
    campaign_id: String,
    name: String,
    clock: &Clock,
    ctx: &mut TxContext
): Campaign {
    let brand_id = brand_cap.brand_wallet;
    
    event::emit(CampaignCreated {
        brand_id,
        campaign_id,
        name,
    });

    Campaign {
        id: object::new(ctx),
        brand_id,
        campaign_id,
        name,
        is_active: true,
        created_at: clock.timestamp_ms(),
    }
}

/// Entry function to create campaign and share it
entry fun create_campaign_entry(
    brand_cap: &BrandCap,
    campaign_id: String,
    name: String,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let campaign = create_campaign(brand_cap, campaign_id, name, clock, ctx);
    transfer::share_object(campaign);
}

/// Toggle campaign active status
entry fun toggle_campaign(
    brand_cap: &BrandCap,
    campaign: &mut Campaign,
) {
    assert!(campaign.brand_id == brand_cap.brand_wallet, ENotBrandOwner);
    campaign.is_active = !campaign.is_active;
}

// ============== NFT Functions ==============

/// Mint a new LoyaltyNFT to a customer (brand only)
public fun mint_nft(
    brand_cap: &BrandCap,
    campaign: &Campaign,
    customer_wallet: address,
    tier: u8,
    expiry_timestamp: u64,
    benefits: vector<String>,
    referral_code: String,
    clock: &Clock,
    ctx: &mut TxContext
): LoyaltyNFT {
    // Validate
    assert!(campaign.brand_id == brand_cap.brand_wallet, ENotBrandOwner);
    assert!(campaign.is_active, ECampaignInactive);
    assert!(tier >= TIER_BRONZE && tier <= TIER_GOLD, EInvalidTier);

    let nft_uid = object::new(ctx);
    let nft_id = nft_uid.to_address();

    event::emit(NFTMinted {
        nft_id,
        brand_id: brand_cap.brand_wallet,
        campaign_id: campaign.campaign_id,
        customer_wallet,
        tier,
    });

    LoyaltyNFT {
        id: nft_uid,
        brand_id: brand_cap.brand_wallet,
        campaign_id: campaign.campaign_id,
        customer_wallet,
        tier,
        expiry_timestamp,
        benefits,
        minted_at: clock.timestamp_ms(),
        referral_code,
    }
}

/// Entry function to mint and transfer NFT to customer
entry fun mint_nft_entry(
    brand_cap: &BrandCap,
    campaign: &Campaign,
    customer_wallet: address,
    tier: u8,
    expiry_timestamp: u64,
    benefits: vector<String>,
    referral_code: String,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let nft = mint_nft(
        brand_cap,
        campaign,
        customer_wallet,
        tier,
        expiry_timestamp,
        benefits,
        referral_code,
        clock,
        ctx
    );
    transfer::transfer(nft, customer_wallet);
}

/// Upgrade NFT tier (brand only)
entry fun upgrade_tier(
    brand_cap: &BrandCap,
    nft: &mut LoyaltyNFT,
    new_tier: u8,
) {
    assert!(nft.brand_id == brand_cap.brand_wallet, ENotBrandOwner);
    assert!(new_tier >= TIER_BRONZE && new_tier <= TIER_GOLD, EInvalidTier);
    assert!(new_tier > nft.tier, EInvalidTier);

    let old_tier = nft.tier;
    nft.tier = new_tier;

    event::emit(TierUpgraded {
        nft_id: nft.id.to_address(),
        old_tier,
        new_tier,
    });
}

/// Update NFT benefits (brand only)
entry fun update_benefits(
    brand_cap: &BrandCap,
    nft: &mut LoyaltyNFT,
    new_benefits: vector<String>,
) {
    assert!(nft.brand_id == brand_cap.brand_wallet, ENotBrandOwner);
    nft.benefits = new_benefits;
}

/// Extend NFT expiry (brand only)
entry fun extend_expiry(
    brand_cap: &BrandCap,
    nft: &mut LoyaltyNFT,
    new_expiry: u64,
) {
    assert!(nft.brand_id == brand_cap.brand_wallet, ENotBrandOwner);
    nft.expiry_timestamp = new_expiry;
}

// ============== Verification Functions ==============

/// Check if NFT is valid (not expired)
public fun is_valid(nft: &LoyaltyNFT, clock: &Clock): bool {
    clock.timestamp_ms() < nft.expiry_timestamp
}

/// Check if NFT has a specific benefit
public fun has_benefit(nft: &LoyaltyNFT, benefit: &String): bool {
    let mut i = 0;
    let len = nft.benefits.length();
    while (i < len) {
        if (&nft.benefits[i] == benefit) {
            return true
        };
        i = i + 1;
    };
    false
}

/// Verify NFT ownership and benefit - emits event for off-chain tracking
entry fun verify_benefit(
    nft: &LoyaltyNFT,
    benefit: String,
    clock: &Clock,
) {
    let is_valid_nft = is_valid(nft, clock);
    let has_benefit_result = has_benefit(nft, &benefit);

    event::emit(BenefitVerified {
        nft_id: nft.id.to_address(),
        benefit,
        is_valid: is_valid_nft && has_benefit_result,
    });
}

// ============== View Functions ==============

public fun get_tier(nft: &LoyaltyNFT): u8 {
    nft.tier
}

public fun get_expiry(nft: &LoyaltyNFT): u64 {
    nft.expiry_timestamp
}

public fun get_benefits(nft: &LoyaltyNFT): &vector<String> {
    &nft.benefits
}

public fun get_brand_id(nft: &LoyaltyNFT): address {
    nft.brand_id
}

public fun get_campaign_id(nft: &LoyaltyNFT): String {
    nft.campaign_id
}

public fun get_customer_wallet(nft: &LoyaltyNFT): address {
    nft.customer_wallet
}

public fun get_referral_code(nft: &LoyaltyNFT): String {
    nft.referral_code
}

public fun get_minted_at(nft: &LoyaltyNFT): u64 {
    nft.minted_at
}

// ============== Burn Functions ==============

/// Customer can burn their own NFT
entry fun burn_nft(nft: LoyaltyNFT, ctx: &TxContext) {
    assert!(nft.customer_wallet == ctx.sender(), ENotBrandOwner);
    let LoyaltyNFT { 
        id, 
        brand_id: _, 
        campaign_id: _, 
        customer_wallet: _, 
        tier: _, 
        expiry_timestamp: _, 
        benefits: _, 
        minted_at: _, 
        referral_code: _ 
    } = nft;
    object::delete(id);
}
