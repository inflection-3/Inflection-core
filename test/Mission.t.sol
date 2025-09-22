// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Mission.sol";
import "../src/interfaces/IUSDC.sol";

// Mock USDC contract for testing
contract MockUSDC is IUSDC {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
}

contract MissionTest is Test {
    Mission public mission;
    MockUSDC public usdcToken;
    
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);
    
    function setUp() public {
        vm.startPrank(owner);
        usdcToken = new MockUSDC();
        mission = new Mission(address(usdcToken));
        
        // Mint some USDC to owner for testing
        usdcToken.mint(owner, 1000000 * 10**6); // 1M USDC (6 decimals)
        usdcToken.approve(address(mission), type(uint256).max);
        vm.stopPrank();
    }
    
    function testAddApplication() public {
        vm.startPrank(owner);
        
        mission.addApplication(
            "Test App",
            "Test Description",
            "https://test.com",
            "banner.jpg",
            "logo.jpg"
        );
        
        assertEq(mission.getApplicationCount(), 1);
        
        IMission.Application memory app = mission.getApplication(1);
        assertEq(app.name, "Test App");
        assertEq(app.description, "Test Description");
        assertEq(app.appUrl, "https://test.com");
        assertTrue(app.isActive);
        
        vm.stopPrank();
    }
    
    function testAddInteraction() public {
        vm.startPrank(owner);
        
        // First add an application
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        
        // Then add an interaction
        mission.addInteraction(
            1,
            "Test Interaction",
            "Test Interaction Description",
            "Click Here",
            "https://interaction.com",
            100 * 10**6 // 100 USDC
        );
        
        assertEq(mission.getInteractionCount(), 1);
        
        IMission.Interaction memory interaction = mission.getInteraction(1);
        assertEq(interaction.title, "Test Interaction");
        assertEq(interaction.applicationId, 1);
        assertEq(interaction.rewardAmount, 100 * 10**6);
        assertTrue(interaction.isActive);
        
        vm.stopPrank();
    }
    
    function testAddParticipant() public {
        vm.startPrank(owner);
        
        // Setup: Add application and interactions
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        mission.addInteraction(1, "Interaction 2", "Description 2", "Action 2", "https://2.com", 75 * 10**6);
        
        uint256[] memory interactionIds = new uint256[](2);
        interactionIds[0] = 1;
        interactionIds[1] = 2;
        
        mission.addParticipant(user1, interactionIds);
        
        assertEq(mission.getTotalParticipants(), 1);
        assertTrue(mission.isParticipant(user1));
        
        IMission.Participant memory participant = mission.getParticipant(user1);
        assertEq(participant.user, user1);
        assertEq(participant.completedInteractions.length, 2);
        assertEq(participant.totalReward, 125 * 10**6); // 50 + 75
        assertFalse(participant.hasClaimed);
        
        vm.stopPrank();
    }
    
    function testDepositRewards() public {
        vm.startPrank(owner);
        
        uint256 depositAmount = 1000 * 10**6; // 1000 USDC
        
        mission.depositRewards(depositAmount);
        
        assertEq(mission.getTotalRewardPool(), depositAmount);
        assertEq(usdcToken.balanceOf(address(mission)), depositAmount);
        
        vm.stopPrank();
    }
    
    function testDistributeRewards() public {
        vm.startPrank(owner);
        
        // Setup: Add application, interactions, and participants
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        
        uint256[] memory interactionIds1 = new uint256[](1);
        interactionIds1[0] = 1;
        mission.addParticipant(user1, interactionIds1);
        
        uint256[] memory interactionIds2 = new uint256[](1);
        interactionIds2[0] = 1;
        mission.addParticipant(user2, interactionIds2);
        
        // Deposit rewards
        uint256 depositAmount = 1000 * 10**6; // 1000 USDC
        mission.depositRewards(depositAmount);
        
        // Distribute rewards
        mission.distributeRewards();
        
        assertTrue(mission.rewardsDistributed());
        assertEq(mission.distributedRewards(), depositAmount);
        
        // Check participant rewards
        IMission.Participant memory participant1 = mission.getParticipant(user1);
        IMission.Participant memory participant2 = mission.getParticipant(user2);
        
        assertEq(participant1.totalReward, 500 * 10**6); // 1000 / 2
        assertEq(participant2.totalReward, 500 * 10**6); // 1000 / 2
        
        vm.stopPrank();
    }
    
    function testClaimReward() public {
        vm.startPrank(owner);
        
        // Setup: Add application, interactions, and participants
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        
        uint256[] memory interactionIds = new uint256[](1);
        interactionIds[0] = 1;
        mission.addParticipant(user1, interactionIds);
        
        // Deposit and distribute rewards
        mission.depositRewards(1000 * 10**6);
        mission.distributeRewards();
        
        vm.stopPrank();
        
        // User claims reward
        vm.startPrank(user1);
        
        uint256 balanceBefore = usdcToken.balanceOf(user1);
        mission.claimReward();
        uint256 balanceAfter = usdcToken.balanceOf(user1);
        
        assertEq(balanceAfter - balanceBefore, 1000 * 10**6);
        assertTrue(mission.hasClaimedReward(user1));
        
        // Try to claim again (should fail)
        vm.expectRevert("Already claimed");
        mission.claimReward();
        
        vm.stopPrank();
    }
    
    function testDistributeRewardsWithRemainder() public {
        vm.startPrank(owner);
        
        // Setup: Add application, interactions, and participants
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        
        uint256[] memory interactionIds = new uint256[](1);
        interactionIds[0] = 1;
        
        mission.addParticipant(user1, interactionIds);
        mission.addParticipant(user2, interactionIds);
        mission.addParticipant(user3, interactionIds);
        
        // Deposit rewards (1001 USDC - will have remainder)
        mission.depositRewards(1001 * 10**6);
        mission.distributeRewards();
        
        // Check participant rewards (first participant gets remainder)
        IMission.Participant memory participant1 = mission.getParticipant(user1);
        IMission.Participant memory participant2 = mission.getParticipant(user2);
        IMission.Participant memory participant3 = mission.getParticipant(user3);
        
        // 1001000000 / 3 = 333666666 remainder 2, so first participant gets 333666668, others get 333666666
        assertEq(participant1.totalReward, 333666668); // 333666666 + 2 remainder
        assertEq(participant2.totalReward, 333666666);
        assertEq(participant3.totalReward, 333666666);
        
        vm.stopPrank();
    }
    
    function testOnlyOwnerFunctions() public {
        vm.startPrank(user1);
        
        vm.expectRevert();
        mission.addApplication("Test", "Test", "https://test.com", "banner.jpg", "logo.jpg");
        
        vm.expectRevert();
        mission.addInteraction(1, "Test", "Test", "Test", "https://test.com", 100);
        
        vm.expectRevert();
        mission.addParticipant(user1, new uint256[](0));
        
        vm.expectRevert();
        mission.depositRewards(100);
        
        vm.expectRevert();
        mission.distributeRewards();
        
        vm.stopPrank();
    }
    
    function testOnlyParticipantClaim() public {
        vm.startPrank(owner);
        
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        
        uint256[] memory interactionIds = new uint256[](1);
        interactionIds[0] = 1;
        mission.addParticipant(user1, interactionIds);
        
        mission.depositRewards(1000 * 10**6);
        mission.distributeRewards();
        
        vm.stopPrank();
        
        // Non-participant tries to claim
        vm.startPrank(user2);
        vm.expectRevert("Not a participant");
        mission.claimReward();
        vm.stopPrank();
    }
    
    function testRewardsNotDistributed() public {
        vm.startPrank(owner);
        
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Interaction 1", "Description 1", "Action 1", "https://1.com", 50 * 10**6);
        
        uint256[] memory interactionIds = new uint256[](1);
        interactionIds[0] = 1;
        mission.addParticipant(user1, interactionIds);
        
        mission.depositRewards(1000 * 10**6);
        
        vm.stopPrank();
        
        // Try to claim before distribution
        vm.startPrank(user1);
        vm.expectRevert("Rewards not yet distributed");
        mission.claimReward();
        vm.stopPrank();
    }
    
    function testDeactivateApplication() public {
        vm.startPrank(owner);
        
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        
        IMission.Application memory app = mission.getApplication(1);
        assertTrue(app.isActive);
        
        mission.deactivateApplication(1);
        
        app = mission.getApplication(1);
        assertFalse(app.isActive);
        
        vm.stopPrank();
    }
    
    function testDeactivateInteraction() public {
        vm.startPrank(owner);
        
        mission.addApplication("Test App", "Test Description", "https://test.com", "banner.jpg", "logo.jpg");
        mission.addInteraction(1, "Test Interaction", "Test Description", "Test Action", "https://test.com", 100);
        
        IMission.Interaction memory interaction = mission.getInteraction(1);
        assertTrue(interaction.isActive);
        
        mission.deactivateInteraction(1);
        
        interaction = mission.getInteraction(1);
        assertFalse(interaction.isActive);
        
        vm.stopPrank();
    }
}
