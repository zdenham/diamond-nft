# 💎 🪚 Diamond Saw + ERC721A Facet Example

This is a minimal proof of concept for Diamond SAW!

The idea behind this pattern is to use one Singleton contract (the saw) to facilitate cutting multiple similar diamond clones.

By doing so we take the most gas costly part of diamond cutting (storing / managing all the selector mappings) and bring it under the responsibility of one contract that can be reused accross many diamond clones.

The diamond now only needs to store a map of addresses to its faucet implementations, the saw handles the rest.

## Motivation

I'm working on https://juicelabs.io

The goal is to help a lot of NFT creators deploy custom contracts for their NFT projects. I want to reduce the deployment cost for my customers, but maintain extensibility so we can have a lot of cool extensions on top of the base ERC721A / 1155 contracts.

Minimal proxy patterns weren't my jam because they only allow you to point to one contract, not as extensible as I would like!

When I found diamond standard I was super excited! But deployment of diamond-3 out of the box was >2M gas (Plus cutting!).

My use case requires really cheap deployments for NFT creators, and for this I'm willing to sacrifice gas overhead calling to a third party contract for selector mappings on each transaction (see gas cache idea below too).

In this example, we deploy an ERC721A single cut Diamond for <400,000 gas, which is pretty cool (and affordable)!

## Files to look at

- DiamondSaw.sol
- DiamondClone.sol
- DiamondCloneCutFacet.sol
- DiamondCloneLoupeFacet.sol
- deploy.js

## TODO

- [x] Integrate AccessControl facet
- [x] Diamond Cut by updating the facet address map
- [x] Loupe by reading selectors from the Saw
- [x] SupportsInterface by reading interfaces from the saw
- [x] Diamond cut event
- [x] Make ERC721AFaucet Initializable
- [x] Whatever else is left to fully comply to the diamond standard
- [ ] Add a "gas cache" where we store SOME selector mappings locally on the diamond (for highly trafficked write calls)
- [ ] Add an optional facet array gas cache to make loupe operations cheaper
- [ ] More tests
