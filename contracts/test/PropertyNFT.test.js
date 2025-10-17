const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PropertyNFT", function () {
  let PropertyNFT, propertyNFT, owner, addr1;

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    PropertyNFT = await ethers.getContractFactory("PropertyNFT");
    propertyNFT = await PropertyNFT.deploy();
    await propertyNFT.deployed();
  });

  it("Should mint a property NFT", async function () {
    const metadata = "ipfs://test-metadata";
    await expect(propertyNFT.mintProperty(addr1.address, metadata))
      .to.emit(propertyNFT, "PropertyMinted")
      .withArgs(1, addr1.address, metadata);
    expect(await propertyNFT.ownerOf(1)).to.equal(addr1.address);
    expect(await propertyNFT.propertyMetadata(1)).to.equal(metadata);
  });
});