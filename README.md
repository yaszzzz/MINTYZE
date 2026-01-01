# Mintyze 💎

**NFT-Based Loyalty Platform on Sui Blockchain**

Mintyze is a B2B Web3 SaaS platform that helps brands increase repeat sales and referrals using utility NFT-based loyalty programs on the Sui blockchain.

## 🎯 Features

- **Wallet-Based Authentication** - Connect with Sui Wallet or Suiet
- **Campaign Builder** - Create multi-tier loyalty programs with custom benefits
- **Utility NFT Minting** - Issue verifiable NFTs to customers post-purchase
- **Benefit Verification** - On-chain verification of NFT validity and benefits
- **Analytics Dashboard** - Track repeat purchase rates and referral metrics

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | SvelteKit + Tailwind CSS |
| Backend | SvelteKit API Routes |
| Database | Neon PostgreSQL + Drizzle ORM |
| Blockchain | Sui (Move Smart Contracts) |
| Wallet | Sui Wallet / Suiet |

## 📁 Project Structure

```
MINTYZE/
├── contracts/
│   └── mintyze_loyalty/          # Sui Move smart contracts
│       └── sources/
│           └── mintyze_loyalty.move
├── frontend-mintzye/             # SvelteKit application
│   ├── src/
│   │   ├── lib/
│   │   │   └── server/db/        # Drizzle schema & connection
│   │   └── routes/
│   │       ├── api/              # REST API endpoints
│   │       ├── auth/             # Wallet connect page
│   │       ├── dashboard/        # Brand dashboard pages
│   │       └── verify/           # NFT verification page
│   └── drizzle.config.ts
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Node.js 20+
- Sui CLI (for contract development)
- Neon PostgreSQL database

### Frontend Setup

```bash
cd frontend-mintzye
npm install

# Configure environment
cp .env.example .env
# Edit .env with your DATABASE_URL

# Push database schema
npm run db:push

# Start development server
npm run dev
```

### Smart Contract Setup

```bash
cd contracts/mintyze_loyalty

# Build contract
sui move build

# Run tests
sui move test

# Deploy to testnet
sui client publish --gas-budget 100000000
```

## 📚 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/brands` | GET/POST/PATCH | Brand management |
| `/api/campaigns` | GET/POST | Campaign list & create |
| `/api/campaigns/[id]` | GET/PATCH/DELETE | Campaign CRUD |
| `/api/nfts` | GET/POST | NFT minting & listing |
| `/api/nfts/[id]` | GET/POST | NFT detail & verification |
| `/api/analytics` | GET | Dashboard metrics |

## 🔗 Smart Contract Functions

```move
// Register brand
register_brand_entry(brand_name: String)

// Create campaign
create_campaign_entry(brand_cap, campaign_id, name, clock)

// Mint NFT to customer
mint_nft_entry(brand_cap, campaign, customer_wallet, tier, expiry, benefits, referral_code, clock)

// Upgrade tier
upgrade_tier(brand_cap, nft, new_tier)

// Verify benefit
verify_benefit(nft, benefit, clock)
```

## 📊 Database Schema

- **brands** - Brand profiles and subscription data
- **campaigns** - Loyalty campaign configurations
- **nft_records** - Off-chain NFT metadata and tracking
- **analytics_events** - Event tracking for metrics
- **referrals** - Referral tracking and conversion

## 🎨 UI Pages

| Page | Route | Description |
|------|-------|-------------|
| Landing | `/` | Value proposition & pricing |
| Auth | `/auth` | Wallet connection |
| Dashboard | `/dashboard` | Overview with metrics |
| Campaigns | `/dashboard/campaigns` | Campaign list |
| Campaign Builder | `/dashboard/campaigns/new` | Create campaign |
| Analytics | `/dashboard/analytics` | Repeat & referral metrics |
| Settings | `/dashboard/settings` | Brand profile |
| Verify | `/verify/[nftId]` | Customer NFT verification |

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

Built with 💜 on Sui Blockchain
