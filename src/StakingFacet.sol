// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LibAppStorage.sol";
import "./AdminFacet.sol";

// StakingFacet.sol
contract StakingFacet {
    
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    
    function stakeERC20(IERC20 token, uint256 amount) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(amount > 0, "Cannot stake 0");
        token.transferFrom(msg.sender, address(this), amount);
        s.stakedERC20[msg.sender] = s.stakedERC20[msg.sender] + amount;
        s.lastStakeTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }
    
    function unstakeERC20(IERC20 token) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        uint256 amount = s.stakedERC20[msg.sender];
        require(amount > 0, "No staked balance");
        claimRewards();
        s.stakedERC20[msg.sender] = 0;
        token.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claimRewards() public {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        uint256 stakedTime = block.timestamp - s.lastStakeTime[msg.sender];
        uint256 reward = calculateReward(msg.sender, stakedTime);
        s.rewardToken.transfer(msg.sender, reward);
        s.lastStakeTime[msg.sender] = block.timestamp;
        emit RewardClaimed(msg.sender, reward);
    }

    function calculateReward(address user, uint256 timeStaked) internal view returns (uint256) {
    LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
    uint256 amount = s.stakedERC20[user];

    uint256 apr = (s.baseAPR * timeStaked * 1e18) / 365; // Move multiplication before division
    uint256 decay = (apr * s.decayRate) / 1e18;
    
    uint256 nftMultiplier = s.nftBoostMultiplier[user] > 0 ? s.nftBoostMultiplier[user] : 1e18;
    
    return (amount * (apr - decay) * nftMultiplier) / 1e36; // Reduce division errors
}
function stakeERC721(IERC721 token, uint256 tokenId) external {
    token.transferFrom(msg.sender, address(this), tokenId);
    // Additional staking logic here
}
function unstakeERC721(address nftAddress, uint256 tokenId) external {
    LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
    require(s.stakedERC721[msg.sender][tokenId], "NFT not staked");
    s.stakedERC721[msg.sender][tokenId] = false;
    IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
}

function stakeERC1155(address token, uint256 tokenId, uint256 amount) external {
    LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
    require(amount > 0, "Cannot stake zero");
    IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
    s.stakedERC1155[msg.sender][tokenId] += amount;
}
 function unstakeERC1155(address token, uint256 id, uint256 amount) external {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        require(s.stakedERC1155[msg.sender][id] >= amount, "Not enough balance");
        s.stakedERC1155[msg.sender][id] -= amount;
        IERC1155(token).safeTransferFrom(address(this), msg.sender, id, amount, "");
    }

}