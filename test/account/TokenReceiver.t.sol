// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import {IERC1155Receiver} from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {MockERC1155} from "../mocks/MockERC1155.sol";
import {MockERC721} from "../mocks/MockERC721.sol";
import {AccountTestBase} from "../utils/AccountTestBase.sol";

contract TokenReceiverTest is AccountTestBase {
    MockERC721 public erc721;
    MockERC1155 public erc1155;
    uint256 internal constant _NFT_TOKEN_ID = 0;
    uint256 internal constant _NFT_TOKEN_COUNT = 10;

    function setUp() public override {
        // Compute counterfactual address
        // account1 = factory.createAccount(owner1, 0, TEST_DEFAULT_VALIDATION_ENTITY_ID);
        // vm.deal(address(account1), 100 ether);

        erc721 = new MockERC721("NFT", "NFT");
        erc721.mint(owner1, _NFT_TOKEN_ID);
        erc1155 = new MockERC1155();
        erc1155.mint(owner1, _NFT_TOKEN_ID, _NFT_TOKEN_COUNT);
    }

    function test_supportedInterfaces() public withSMATest {
        assertTrue(account1.supportsInterface(type(IERC721Receiver).interfaceId));
        assertTrue(account1.supportsInterface(type(IERC1155Receiver).interfaceId));
    }

    function test_receiveERC721() public withSMATest {
        assertEq(owner1, erc721.ownerOf(_NFT_TOKEN_ID));
        vm.prank(owner1);
        erc721.transferFrom(owner1, address(account1), _NFT_TOKEN_ID);
        assertEq(address(account1), erc721.ownerOf(_NFT_TOKEN_ID));
    }

    function test_receiveERC1155() public withSMATest {
        assertEq(_NFT_TOKEN_COUNT, erc1155.balanceOf(owner1, _NFT_TOKEN_ID));
        vm.prank(owner1);
        erc1155.safeTransferFrom(owner1, address(account1), _NFT_TOKEN_ID, _NFT_TOKEN_COUNT, "");
        assertEq(_NFT_TOKEN_COUNT, erc1155.balanceOf(address(account1), _NFT_TOKEN_ID));
    }

    function test_receiveERC1155Batch() public withSMATest {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = _NFT_TOKEN_ID;
        values[0] = _NFT_TOKEN_COUNT;

        assertEq(_NFT_TOKEN_COUNT, erc1155.balanceOf(owner1, _NFT_TOKEN_ID));
        vm.prank(owner1);
        erc1155.safeBatchTransferFrom(owner1, address(account1), ids, values, "");
        assertEq(_NFT_TOKEN_COUNT, erc1155.balanceOf(address(account1), _NFT_TOKEN_ID));
    }
}