// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/utils/MerkleProofLib.sol";
import "lib/solmate/src/tokens/ERC1155.sol";

contract Merkle is ERC1155 {
    bytes32 root;

    constructor(bytes32 _root) {
        root = _root;
    }

    mapping(address => bool) public hasClaimed;

    function uri(uint256 id) public view virtual override returns (string memory) {
        return "";
    }

    function claim(address _claimer, uint256 id, uint _amount, bytes32[] calldata _proof) external returns (bool) {
        require(!hasClaimed[_claimer], "already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(_claimer, id, _amount));
        bool verificationStatus = MerkleProofLib.verify(_proof, root, leaf);

        require(verificationStatus, "not whitelisted");

        hasClaimed[_claimer] = true;

        _mint(_claimer, id, _amount, "");

        return true;
    }
}
