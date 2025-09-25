// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * NFT 合约
 * 实现 ERC721 标准的 NFT 合约，支持铸造和转移
 */
contract NFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    constructor(address initialOwner) ERC721("NFTAuction", "NFTA") Ownable(initialOwner) {}

    /**
     * 铸造新的 NFT
     */
    function mintNFT(address recipient, string memory tokenURI) public onlyOwner returns (uint256) {
        _tokenIds++;
        _mint(recipient, _tokenIds);
        _setTokenURI(_tokenIds, tokenURI);
        return _tokenIds;
    }
}