// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable {
    struct Listing {
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed nftContract, uint256 indexed tokenId, address seller, uint256 price);
    event Purchased(address indexed nftContract, uint256 indexed tokenId, address buyer);

    function listNFT(address nftContract, uint256 tokenId, uint256 price) external {
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(nft.isApprovedForAll(msg.sender, address(this)) || nft.getApproved(tokenId) == address(this), "Marketplace not approved");

        listings[nftContract][tokenId] = Listing(msg.sender, price);
        emit Listed(nftContract, tokenId, msg.sender, price);
    }

    function buyNFT(address nftContract, uint256 tokenId) external payable {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.price > 0, "NFT not listed");
        require(msg.value == listing.price, "Incorrect price");

        delete listings[nftContract][tokenId];
        IERC721(nftContract).safeTransferFrom(listing.seller, msg.sender, tokenId);
        payable(listing.seller).transfer(msg.value);

        emit Purchased(nftContract, tokenId, msg.sender);
    }

    function delistNFT(address nftContract, uint256 tokenId) external {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.seller == msg.sender, "Not the seller");

        delete listings[nftContract][tokenId];
        // Optional: Emit an event for delisting
    }
}
