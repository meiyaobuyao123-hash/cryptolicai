# Crypto Earn

A comprehensive crypto yield data platform that helps users understand and access DeFi & CeFi financial products.

## Features

- **Market Dashboard** — Real-time DeFi TVL, total crypto market cap, chain asset distribution
- **Platform Ranking** — Top DeFi/CeFi platforms ranked by TVL with 7-day changes
- **Yield Products** — Browse and filter yield products by risk, asset type, and chain
- **Yield Mechanism Explainer** — Understand how each platform generates returns, with risk warnings
- **User Concentration Analysis** — Whale distribution, deposit size breakdown per platform
- **Wallet Connection** — Connect MetaMask, Trust Wallet via WalletConnect
- **Platform Detail** — Drill into any protocol's APY distribution, asset allocation, chain breakdown

## Data Sources

- [DefiLlama](https://defillama.com/) — DeFi TVL, protocols, yield pools, chain data
- [CoinGecko](https://www.coingecko.com/) — Market cap, prices, exchange data

## Tech Stack

- Flutter 3.x + Dart
- Riverpod 3.x (state management)
- Dio (networking + caching)
- fl_chart (data visualization)
- GoRouter (navigation)
- Reown AppKit (WalletConnect v2)

## Getting Started

```bash
flutter pub get
flutter run
```

## Research

Detailed market research reports available in [docs/market-research](./docs/market-research/README.md)

## Support

For issues and feature requests, please open an issue on this repository.

## License

MIT

## Disclaimer

This app provides data for informational purposes only and does not constitute investment advice. Crypto investments carry high risk. Please do your own research before making any investment decisions.
