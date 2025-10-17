// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PropertyNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    // Store property metadata (could point to IPFS)
    mapping(uint256 => string) public propertyMetadata;

    constructor() ERC721("PropChain", "PROP") Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    // Mint a new property NFT
    function mintProperty(address to, string memory metadata) public onlyOwner returns (uint256) {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        propertyMetadata[tokenId] = metadata; // Store metadata (e.g., IPFS hash)
        emit PropertyMinted(tokenId, to, metadata);
        return tokenId;
    }

    // Event for tracking minting
    event PropertyMinted(uint256 indexed tokenId, address indexed owner, string metadata);
}