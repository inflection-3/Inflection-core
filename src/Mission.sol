// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IUSDC.sol";
import "./interfaces/IMission.sol";

/**
 * @title Mission
 * @dev Individual mission contract that manages applications, interactions, and rewards
 */
contract Mission is IMission, Ownable, ReentrancyGuard {
    IUSDC public immutable usdcToken;
    
    uint256 public applicationCount;
    uint256 public interactionCount;
    uint256 public totalRewardPool;
    uint256 public distributedRewards;
    bool public rewardsDistributed;
    
    mapping(uint256 => Application) public applications;
    mapping(uint256 => Interaction) public interactions;
    mapping(address => Participant) public participants;
    address[] public participantList;
    
    event ApplicationAdded(uint256 indexed applicationId, string name, address owner);
    event InteractionAdded(uint256 indexed interactionId, uint256 applicationId, string title);
    event ParticipantAdded(address indexed user, uint256[] interactionIds);
    event RewardsDeposited(uint256 amount, uint256 totalPool);
    event RewardsDistributed(uint256 totalParticipants, uint256 rewardPerParticipant);
    event RewardClaimed(address indexed user, uint256 amount);
    
    modifier onlyValidApplication(uint256 applicationId) {
        require(applications[applicationId].id != 0, "Application does not exist");
        require(applications[applicationId].isActive, "Application is not active");
        _;
    }
    
    modifier onlyValidInteraction(uint256 interactionId) {
        require(interactions[interactionId].id != 0, "Interaction does not exist");
        require(interactions[interactionId].isActive, "Interaction is not active");
        _;
    }
    
    modifier onlyParticipant() {
        require(participants[msg.sender].user != address(0), "Not a participant");
        _;
    }
    
    modifier rewardsNotDistributed() {
        require(!rewardsDistributed, "Rewards already distributed");
        _;
    }
    
    constructor(address _usdcToken) Ownable(msg.sender) {
        usdcToken = IUSDC(_usdcToken);
    }
    
    /**
     * @dev Add a new application to the mission
     */
    function addApplication(
        string memory name,
        string memory description,
        string memory appUrl,
        string memory bannerImage,
        string memory appLogo
    ) external onlyOwner {
        applicationCount++;
        applications[applicationCount] = Application({
            id: applicationCount,
            name: name,
            description: description,
            appUrl: appUrl,
            bannerImage: bannerImage,
            appLogo: appLogo,
            isActive: true,
            owner: msg.sender
        });
        
        emit ApplicationAdded(applicationCount, name, msg.sender);
    }
    
    /**
     * @dev Add a new interaction to an application
     */
    function addInteraction(
        uint256 applicationId,
        string memory title,
        string memory description,
        string memory actionTitle,
        string memory interactionUrl,
        uint256 rewardAmount
    ) external onlyOwner onlyValidApplication(applicationId) {
        interactionCount++;
        interactions[interactionCount] = Interaction({
            id: interactionCount,
            applicationId: applicationId,
            title: title,
            description: description,
            actionTitle: actionTitle,
            interactionUrl: interactionUrl,
            isActive: true,
            rewardAmount: rewardAmount
        });
        
        emit InteractionAdded(interactionCount, applicationId, title);
    }
    
    /**
     * @dev Add a participant who has completed specific interactions
     */
    function addParticipant(address user, uint256[] memory interactionIds) external onlyOwner {
        require(user != address(0), "Invalid user address");
        require(participants[user].user == address(0), "Participant already exists");
        require(interactionIds.length > 0, "Must complete at least one interaction");
        
        // Validate all interactions exist and are active
        for (uint256 i = 0; i < interactionIds.length; i++) {
            require(interactions[interactionIds[i]].id != 0, "Invalid interaction");
            require(interactions[interactionIds[i]].isActive, "Interaction not active");
        }
        
        uint256 totalReward = 0;
        for (uint256 i = 0; i < interactionIds.length; i++) {
            totalReward += interactions[interactionIds[i]].rewardAmount;
        }
        
        participants[user] = Participant({
            user: user,
            completedInteractions: interactionIds,
            totalReward: totalReward,
            hasClaimed: false
        });
        
        participantList.push(user);
        
        emit ParticipantAdded(user, interactionIds);
    }
    
    /**
     * @dev Deposit USDC rewards into the mission contract
     */
    function depositRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(usdcToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        totalRewardPool += amount;
        
        emit RewardsDeposited(amount, totalRewardPool);
    }
    
    /**
     * @dev Distribute rewards equally among all participants
     */
    function distributeRewards() external onlyOwner rewardsNotDistributed {
        require(participantList.length > 0, "No participants");
        require(totalRewardPool > 0, "No rewards to distribute");
        require(usdcToken.balanceOf(address(this)) >= totalRewardPool, "Insufficient USDC balance");
        
        uint256 rewardPerParticipant = totalRewardPool / participantList.length;
        uint256 remainder = totalRewardPool % participantList.length;
        
        // Distribute rewards to participants
        for (uint256 i = 0; i < participantList.length; i++) {
            address participant = participantList[i];
            participants[participant].totalReward = rewardPerParticipant;
        }
        
        // Add remainder to first participant
        if (remainder > 0) {
            participants[participantList[0]].totalReward += remainder;
        }
        
        distributedRewards = totalRewardPool;
        rewardsDistributed = true;
        
        emit RewardsDistributed(participantList.length, rewardPerParticipant);
    }
    
    /**
     * @dev Allow participants to claim their rewards
     */
    function claimReward() external nonReentrant onlyParticipant {
        require(rewardsDistributed, "Rewards not yet distributed");
        require(!participants[msg.sender].hasClaimed, "Already claimed");
        
        uint256 rewardAmount = participants[msg.sender].totalReward;
        require(rewardAmount > 0, "No reward to claim");
        require(usdcToken.balanceOf(address(this)) >= rewardAmount, "Insufficient USDC balance");
        
        participants[msg.sender].hasClaimed = true;
        
        require(usdcToken.transfer(msg.sender, rewardAmount), "Transfer failed");
        
        emit RewardClaimed(msg.sender, rewardAmount);
    }
    
    /**
     * @dev Deactivate an application
     */
    function deactivateApplication(uint256 applicationId) external onlyOwner onlyValidApplication(applicationId) {
        applications[applicationId].isActive = false;
    }
    
    /**
     * @dev Deactivate an interaction
     */
    function deactivateInteraction(uint256 interactionId) external onlyOwner onlyValidInteraction(interactionId) {
        interactions[interactionId].isActive = false;
    }
    
    // View functions
    
    function getApplication(uint256 id) external view returns (Application memory) {
        require(applications[id].id != 0, "Application does not exist");
        return applications[id];
    }
    
    function getInteraction(uint256 id) external view returns (Interaction memory) {
        require(interactions[id].id != 0, "Interaction does not exist");
        return interactions[id];
    }
    
    function getParticipant(address user) external view returns (Participant memory) {
        require(participants[user].user != address(0), "Participant does not exist");
        return participants[user];
    }
    
    function getTotalParticipants() external view returns (uint256) {
        return participantList.length;
    }
    
    function getTotalRewardPool() external view returns (uint256) {
        return totalRewardPool;
    }
    
    function getRemainingRewardPool() external view returns (uint256) {
        return usdcToken.balanceOf(address(this));
    }
    
    function getParticipantList() external view returns (address[] memory) {
        return participantList;
    }
    
    function getApplicationCount() external view returns (uint256) {
        return applicationCount;
    }
    
    function getInteractionCount() external view returns (uint256) {
        return interactionCount;
    }
    
    function isParticipant(address user) external view returns (bool) {
        return participants[user].user != address(0);
    }
    
    function hasClaimedReward(address user) external view returns (bool) {
        return participants[user].hasClaimed;
    }
}
