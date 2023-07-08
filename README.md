# PropyToken
# AssetProxy Contract

The AssetProxy contract is a proxy contract that implements the ERC20 interface and acts as a gateway to a single EToken2 asset. This contract adds the EToken2 symbol and caller (sender) when forwarding requests to EToken2. Every request made by the caller is first sent to the specific asset implementation contract, which then calls back to be forwarded onto EToken2.

## Implemented Corrections

The following corrections have been made to the contract code:

- All functions have been updated to be compatible with Solidity compiler version `0.8.0`.
- The `memory` modifier has been added to string parameters in functions to specify that the data should be stored in memory instead of storage.
- The `constant` modifier has been replaced with the `view` modifier in functions that do not modify the contract's state.
- The `throw` modifier has been replaced with `revert` in the `_performGeneric` function to throw an exception and revert changes in case of an error.
- The `Transfer` and `Approval` events have been updated to be compatible with Solidity version `0.8.0`.
- The `onlyEToken2` and `onlyAssetOwner` modifiers have been fixed to properly use the `modifier` structure.
- The `payable` modifier has been added to the `fallback` function to allow the contract to receive ethers.
- The access control to the `receiveEthers` function has been updated to only allow it to be called by the assigned EToken2 contract.
- The `getVersionFor` function has been updated to check if the EToken2 symbol is locked before determining the contract version.

## Usage

The AssetProxy contract is used as a proxy for a specific EToken2 asset. To use it, follow these steps:

1. Deploy the AssetProxy contract on the Ethereum network.
2. Call the `init` function to assign the EToken2 contract address, asset symbol, and name.
3. Interact with the AssetProxy contract using the functions of the ERC20 interface.

## Contributions

Contributions are welcome. If you find any issues or have any improvements, please open an issue or submit a pull request.

## License

This contract is subject to the Ambisafe License Agreement. No use or distribution is allowed without written permission from Ambisafe. You can find the license agreement at [this link](https://www.ambisafe.co/terms-of-use/).
