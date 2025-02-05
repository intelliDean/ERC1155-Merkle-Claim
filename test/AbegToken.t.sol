// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {Merkle} from "../src/AbegToken.sol";

contract AbegTest is Test {
    using stdJson for string;

    Merkle public merkle;

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint tokenId;
        uint amount;
    }

    Result public result;

    User public user;

    bytes32 root = 0x9eb195b8eb8e555e09ee4572509404e9b435738b7c0ebd35a667492d3459da8b;

    address user1 = 0x9e71e69F9338E859148Ce1769F440aba4458F41A;

    function setUp() public {

        merkle = new Merkle(root);

        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkleTree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/addressData.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(string.concat(".", vm.toString(user1)));

        user.user = vm.parseJsonAddress(dataJson, string.concat(".", vm.toString(user1), ".address"));

        user.tokenId = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".tokenId"));

        user.amount = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".amount"));

        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {

        bool success = merkle.claim(user.user, user.tokenId, user.amount, result.proof);

        assertTrue(success);
    }

    function testAlreadyClaimed() public {

        merkle.claim(user.user, user.tokenId, user.amount, result.proof);
        vm.expectRevert("already claimed");
        merkle.claim(user.user, user.tokenId, user.amount, result.proof);
    }

    function testIncorrectProof() public {

        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(user.user, user.tokenId, user.amount, fakeProofleaveitleaveit);
    }
}
