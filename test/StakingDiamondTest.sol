// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LibAppStorage.sol";
import "../src/StakingFacet.sol";
import "../src/AdminFacet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1e24);
    }
}

contract MockERC721 is ERC721 {
    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}

contract MockERC1155 is ERC1155 {
    constructor() ERC1155("") {}

    function mint(address to, uint256 id, uint256 amount) external {
        _mint(to, id, amount, "");
    }
}

contract StakingDiamondTest is Test {
    StakingFacet stakingFacet;
    AdminFacet adminFacet;
    MockERC20 rewardToken;
    MockERC20 stakeToken;
    MockERC721 nftToken;
    MockERC1155 multiToken;
    address user = address(1);

    function setUp() public {
        stakingFacet = new StakingFacet();
        adminFacet = new AdminFacet();
        rewardToken = new MockERC20();
        stakeToken = new MockERC20();
        nftToken = new MockERC721();
        multiToken = new MockERC1155();

        stakeToken.transfer(user, 1e20);
        rewardToken.transfer(address(stakingFacet), 1e24);
    }

    function testStakeERC20() public {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();
        
        vm.startPrank(user);
        stakeToken.approve(address(stakingFacet), 1e18);
        stakingFacet.stakeERC20(stakeToken, 1e18);
        assertEq(s.stakedERC20[user], 1e18);
        vm.stopPrank();
    }

    function testUnstakeERC20() public {
        testStakeERC20();
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        vm.startPrank(user);
        stakingFacet.unstakeERC20(stakeToken);
        assertEq(s.stakedERC20[user], 0);
        vm.stopPrank();
    }

    function testStakeERC721() public {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        nftToken.mint(user, 1);
        vm.startPrank(user);
        nftToken.approve(address(stakingFacet), 1);
        stakingFacet.stakeERC721(nftToken, 1);
        assertEq(s.stakedERC721[user][1], true);
        vm.stopPrank();
    }

    function testUnstakeERC721() public {
        testStakeERC721();
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        vm.startPrank(user);
        stakingFacet.unstakeERC721(address(nftToken), 1);
        assertEq(s.stakedERC721[user][1], false);
        vm.stopPrank();
    }

    function testStakeERC1155() public {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        multiToken.mint(user, 1, 10);
        vm.startPrank(user);
        multiToken.setApprovalForAll(address(stakingFacet), true);
        stakingFacet.stakeERC1155(address(multiToken), 1, 5);
        assertEq(s.stakedERC1155[user][1], 5);
        vm.stopPrank();
    }

    function testUnstakeERC1155() public {
        testStakeERC1155();
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        vm.startPrank(user);
        stakingFacet.unstakeERC1155(address(multiToken), 1, 5);
        assertEq(s.stakedERC1155[user][1], 0);
        vm.stopPrank();
    }

    function testClaimRewards() public {
        testStakeERC20();
        vm.warp(block.timestamp + 30 days);

        vm.startPrank(user);
        stakingFacet.claimRewards();
        assertGt(rewardToken.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testAdminSetAPR() public {
        LibAppStorage.AppStorage storage s = LibAppStorage.appStorage();

        vm.startPrank(s.admin);
        adminFacet.setAPR(15);
        assertEq(s.baseAPR, 15);
        vm.stopPrank();
    }
}
