// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./LibAppStorage.sol";
import "./StakingFacet.sol";

// AdminFacet.sol
contract AdminFacet {
    
    event APRUpdated(uint256 newAPR);
    event DecayRateUpdated(uint256 newDecayRate);
    event NFTBoostMultiplierUpdated(address indexed user, uint256 multiplier);
    
    modifier onlyAdmin() {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(msg.sender == s.admin, "Not admin");
        _;
    }
    
    function setAPR(uint256 newAPR) external onlyAdmin {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        s.baseAPR = newAPR;
        emit APRUpdated(newAPR);
    }
    
    function setDecayRate(uint256 newDecayRate) external onlyAdmin {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        s.decayRate = newDecayRate;
        emit DecayRateUpdated(newDecayRate);
    }
    
    function setNFTBoostMultiplier(address user, uint256 multiplier) external onlyAdmin {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        s.nftBoostMultiplier[user] = multiplier;
        emit NFTBoostMultiplierUpdated(user, multiplier);
    }
}
