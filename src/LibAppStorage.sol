// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "forge-std/console.sol";


// LibAppStorage.sol
library LibAppStorage {
    struct AppStorage {
        mapping(address => uint256) stakedERC20;
        mapping(address => mapping(uint256 => bool)) stakedERC721;
        mapping(address => mapping(uint256 => uint256)) stakedERC1155;
        mapping(address => uint256) lastStakeTime;
        uint256 baseAPR;
        uint256 decayRate;
        IERC20 rewardToken;
        mapping(address => uint256) nftBoostMultiplier;
        address admin;
    }

    function appStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = keccak256("diamond.storage.app");
        assembly {
            ds.slot := position
        }
    }
   
function getStakedERC1155(address user, uint256 tokenId) external view returns (uint256) {
    AppStorage storage s = LibAppStorage.appStorage();
    return s.stakedERC1155[user][tokenId];
}


}



