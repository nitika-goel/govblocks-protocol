/* Copyright (C) 2017 GovBlocks.io

  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ */


pragma solidity ^0.4.8;
import "./SafeMath.sol";
import "./Master.sol";
import "./GBTStandardToken.sol";

contract governanceData {
  
    event Reputation(address indexed from,uint256 indexed proposalId, string description, uint reputationPoints,bytes4 typeOf);
    event Vote(address indexed from,address indexed votingTypeAddress,uint256 voteId);
    event Reward(address indexed to,uint256 indexed proposalId,string description,uint256 amount);
    event Penalty(address indexed to,uint256 indexed proposalId,string description,uint256 amount);
    event OraclizeCall(address indexed proposalOwner,uint256 indexed proposalId,uint256 dateAdd,uint256 closingTime);    

    function callReputationEvent(address _from,uint256 _proposalId,string _description,uint _reputationPoints,bytes4 _typeOf) onlyInternal
    {
        Reputation(_from, _proposalId, _description,_reputationPoints,_typeOf);
    }
    
    function callVoteEvent(address _from,address _votingTypeAddress,uint256 _voteId) onlyInternal
    {
        Vote(_from, _votingTypeAddress, _voteId);
    }
    
    function callRewardEvent(address _to,uint256 _proposalId,string _description,uint256 _amount) onlyInternal
    {
        Reward(_to, _proposalId, _description,_amount);
    }

    function callPenaltyEvent(address _to,uint256 _proposalId,string _description,uint256 _amount) onlyInternal
    {
        Penalty(_to, _proposalId, _description,_amount);
    }

    function callOraclizeCallEvent(uint256 _proposalId,uint256 _dateAdd,uint256 _closingTime) onlyInternal
    {
        OraclizeCall(allProposal[_proposalId].owner, _proposalId, _dateAdd,_closingTime);
    }
    
    using SafeMath for uint;
    struct proposal
    {
        address owner;
        string proposalDescHash;
        uint date_add;
        uint date_upd;
        uint8 versionNum;
        uint8 currVotingStatus;
        uint8 propStatus;  
        uint8 category;
        uint8 finalVerdict;
        uint8 currentVerdict;
        address votingTypeAddress;
        uint proposalValue;
        uint proposalStake;
        uint proposalReward;
        uint totalreward;
        uint blocknumber;
        uint8 complexityLevel;
        uint commonIncentive;
    }

    struct proposalCategory{
        address categorizedBy;
        uint8 verdictOptions;
        address[] optionAddedByAddress;
        uint[] valueOfOption;
        uint[] stakeOnOption;
        string[] optionHash;
        uint[] optionDateAdd;
        mapping(uint=>uint) rewardOption;
    }

    struct proposalVersionData{
        uint versionNum;
        string proposalDescHash;
        uint date_add;
    }

    struct Status{
        uint statusId;
        uint date;
    }
    
    struct votingTypeDetails
    {
        bytes32 votingTypeName;
        address votingTypeAddress;
    }

    struct proposalVote {
        address voter;
        uint proposalId;
        uint[] optionChosen;
        uint dateSubmit;
        uint voterTokens;
        uint voteStakeGBT;
        uint voteValue;
        uint reward;
    }

    struct proposalVoteAndTokenCount 
    {
        mapping(uint=>mapping(uint=>uint)) totalVoteCountValue; // PROPOSAL ROLE OPTION VOTEVALUE
        mapping(uint=>uint) totalTokenCount;  // PROPOSAL ROLE TOKEN
    }
    
    mapping(uint => proposalVoteAndTokenCount) allProposalVoteAndToken;
    mapping(uint=>mapping(uint=>uint[])) ProposalRoleVote;
    mapping(address=>mapping(uint=>uint)) AddressProposalVote; 
    mapping(uint=>proposalCategory) allProposalCategory;
    mapping(uint=>proposalVersionData[]) proposalVersions;
    mapping(uint=>Status[]) proposalStatus;
    mapping(address=>uint) allMemberReputationByAddress;
    mapping(uint=>uint[]) allProposalVotes; // CAN OPTIMIZE THIS
    mapping(address=>uint[]) allProposalMember; // Proposal Against Member
    mapping(address=>uint[]) allProposalOption; // Total Proposals against Member, array contains proposalIds to which solution being provided
    mapping(address=>uint[]) allMemberVotes; // Total Votes given by member till now..
    mapping(uint=>uint8) initialOptionsAdded;
    mapping(address=>mapping(uint=>uint)) allOptionDataAgainstMember; // AddressProposalOptionId
    

    mapping(address=>mapping(uint=>mapping(bytes4=>uint))) allMemberDepositTokens;

    struct lastReward
    {
        uint proposalCreate;
        uint optionCreate;
        uint proposalVote;
    }

    mapping(address=>lastReward);

    function setProposalCreate(address _memberAddress,uint _proposalId)
    {
        lastReward[_memberAddress].proposalCreate =_proposalId;
    }

    function setOptionCreate(address _memberAddress, uint _proposalId)
    {
        lastReward[_memberAddress].optionCreate = _proposalId;
    }

    function setProposalVote(address _memberAddress,uint _voteId)
    {
        lastReward[_memberAddress].proposalVote = _voteId;
    }

    function setDepositTokens(address _memberAddress,uint _proposalId,uint _depositAmount)
    {
        allMemberDepositTokens[_memberAddress][_proposalId] = _depositAmount;
    }

    function getDepositTokensByAddress(address _memberAddress,uint _proposalId)constant returns(uint _depositAmount)
    {
        _depositAmount = allMemberDepositTokens[_memberAddress][_proposalId];
    }

    function calculateReward(uint _proposalId)
    {
        uint reward = allProposal[_proposalId].totalreward;
        allMemberDepositTokens[msg.sender][_proposalId]
    }

    function undepositTokens(uint _proposalId)
    {

    }



    uint public quorumPercentage;
    uint public pendingProposalStart;
    uint public GBTStakeValue; 
    uint public globalRiskFactor; 
    uint public membershipScalingFactor;
    uint public scalingWeight;
    uint public allVotesTotal;
    uint public constructorCheck;
    uint public burnPercProposal;
    uint public burnPercOption;
    uint public burnPercVote;
    uint addProposalOwnerPoints;
    uint addOptionOwnerPoints;
    uint addMemberPoints;
    uint subProposalOwnerPoints;
    uint subOptionOwnerPoints;
    uint subMemberPoints;

    string[]  status;
    proposal[] allProposal;
    proposalVote[] allVotes;
    votingTypeDetails[] allVotingTypeDetails;

    Master MS;
    GBTStandardToken GBTS;
    address masterAddress;
    address GBMAddress;
    address GBTSAddress;
    address constant null_address = 0x00;

    modifier onlyInternal {
        MS=Master(masterAddress);
        require(MS.isInternal(msg.sender) == 1);
        _; 
    }
    
     modifier onlyOwner 
    {
        MS=Master(masterAddress);
        require(MS.isOwner(msg.sender) == 1);
        _; 
    }

    modifier onlyMaster 
    {
        require(msg.sender == masterAddress);
        _; 
    }

    modifier onlyGBM
    {
        require(msg.sender == GBMAddress);
        _;
    }

    /// @dev Change master's contract address
    function changeMasterAddress(address _masterContractAddress) 
    {
        if(masterAddress == 0x000)
            masterAddress = _masterContractAddress;
        else
        {
            MS=Master(masterAddress);
            require(MS.isInternal(msg.sender) == 1);
                masterAddress = _masterContractAddress;
        }
    }

    function changeGBMAddress(address _GBMAddress) onlyGBM
    {
        GBMAddress = _GBMAddress;
    }
    
    function changeGBTtokenAddress(address _GBTAddress) onlyMaster
    {
        GBTSAddress = _GBTAddress;
    }   
    
    function GovernanceDataInitiate(address _GBMAddress) 
    {
        require(constructorCheck == 0);
            GBMAddress = _GBMAddress;
            setGlobalParameters();
            addStatus();
            addMemberReputationPoints();
            setVotingTypeDetails("Simple Voting",null_address);
            setVotingTypeDetails("Rank Based Voting",null_address);
            setVotingTypeDetails("Feature Weighted Voting",null_address);
            allVotes.push(proposalVote(0X00,0,new uint[](0),0,0,0,0,0));
            uint _totalVotes = SafeMath.add(allVotesTotal,1);  
            allVotesTotal=_totalVotes;
            constructorCheck=1;
    }

    function addInVote(address _memberAddress,uint _proposalId,uint[] _optionChosen,uint _GBTPayableTokenAmount,uint _finalVoteValue) onlyInternal
    {
        GBTS=GBTStandardToken(GBTSAddress);
        allVotes.push(proposalVote(_memberAddress,_proposalId,_optionChosen,now,GBTS.balanceOf(_memberAddress),_GBTPayableTokenAmount,_finalVoteValue,0));
        increaseTotalVotes();
    }

    function increaseTotalVotes() internal returns (uint _totalVotes) 
    {
        _totalVotes = SafeMath.add(allVotesTotal,1);  
        allVotesTotal=_totalVotes;
    } 

    function setVoteId_againstMember(address _memberAddress,uint _proposalId,uint _voteId) onlyInternal
    {
        AddressProposalVote[_memberAddress][_proposalId] = _voteId;
    }

    function setVoteIdAgainstProposalRole(uint _proposalId,uint _roleId,uint _voteId) onlyInternal
    {
        ProposalRoleVote[_proposalId][_roleId].push(_voteId);
    }

    function getVoteDetailByid(uint _voteid) public constant returns(address voter,uint proposalId,uint[] optionChosen,uint dateSubmit,uint voterTokens,uint voteStakeGBT,uint voteValue)
    {
        return(allVotes[_voteid].voter,allVotes[_voteid].proposalId,allVotes[_voteid].optionChosen,allVotes[_voteid].dateSubmit,allVotes[_voteid].voterTokens,allVotes[_voteid].voteStakeGBT,allVotes[_voteid].voteValue);
    }

    function setProposalVoteCount(uint _proposalId,uint _roleId,uint _option,uint _finalVoteValue) onlyInternal
    {
        allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_option] = SafeMath.add(allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_option],_finalVoteValue);
    }

    function setProposalTokenCount(uint _proposalId,uint _roleId,address _memberAddress) onlyInternal
    {
        GBTS=GBTStandardToken(GBTSAddress);
        allProposalVoteAndToken[_proposalId].totalTokenCount[_roleId] = SafeMath.add(allProposalVoteAndToken[_proposalId].totalTokenCount[_roleId],GBTS.balanceOf(_memberAddress));
    }
 
    function editProposalVoteCount(uint _proposalId,uint _roleId,uint _option,uint _VoteValue) onlyInternal
    {
        allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_option] = SafeMath.sub(allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_option],_VoteValue);
    }

    function editProposalTokenCount(uint _proposalId,uint _roleId,address _memberAddress) onlyInternal
    {
        GBTS=GBTStandardToken(GBTSAddress);
        allProposalVoteAndToken[_proposalId].totalTokenCount[_roleId] = SafeMath.sub(allProposalVoteAndToken[_proposalId].totalTokenCount[_roleId],GBTS.balanceOf(_memberAddress));
    }

    /// @dev Get the vote count for options of proposal when giving Proposal id and Option index.
    function getProposalVoteAndTokenCountByRoleId(uint _proposalId,uint _roleId,uint _optionIndex) public constant returns(uint totalVoteValue,uint totalToken)
    {
        totalVoteValue = allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_optionIndex];
        totalToken = allProposalVoteAndToken[_proposalId].totalTokenCount[_roleId];
    }

    function getVoteId_againstMember(address _memberAddress,uint _proposalId) constant returns(uint voteId)
    {
        voteId = AddressProposalVote[_memberAddress][_proposalId];
    }

    function getVoteValuebyOption_againstProposal(uint _proposalId,uint _roleId,uint _optionIndex) constant returns(uint totalVoteValue)
    {
        totalVoteValue = allProposalVoteAndToken[_proposalId].totalVoteCountValue[_roleId][_optionIndex];
    }
    
    function getOptionChosenById(uint _voteId) constant returns(uint[] optionChosen)
    {
        return (allVotes[_voteId].optionChosen);
    }
    
    function setOptionChosen(uint _voteId,uint _value) onlyInternal
    {
        allVotes[_voteId].optionChosen.push(_value);
    }

    function getOptionById(uint _voteId,uint _optionChosenId)constant returns(uint option)
    {
        return (allVotes[_voteId].optionChosen[_optionChosenId]);
    }
    
    function getVoterAddress(uint _voteId) constant returns(address _voterAddress)
    {
        return (allVotes[_voteId].voter);
    }
    
    function getVoteArrayAgainstRole(uint _proposalId,uint _roleId) constant returns(uint[] totalVotes)
    {
        return ProposalRoleVote[_proposalId][_roleId];
    }

    function getVoteLength(uint _proposalId,uint _roleId)constant returns(uint length)
    {
        return ProposalRoleVote[_proposalId][_roleId].length;
    }
    
    function getVoteIdAgainstRole(uint _proposalId,uint _roleId,uint _index)constant returns(uint)
    {
        return (ProposalRoleVote[_proposalId][_roleId][_index]);
    }

    function setVoteReward(uint _voteId,uint _reward) onlyInternal
    {
        allVotes[_voteId].reward = _reward ;
    }

    function getVoteReward(uint _voteId)constant returns(uint reward)
    {
        return (allVotes[_voteId].reward);
    }

    function getVoteValue(uint _voteId)constant returns(uint)
    {
        return (allVotes[_voteId].voteValue);
    }

    function setVoteStake(uint _voteId,uint _voteStake) onlyInternal
    {
        allVotes[_voteId].voteStakeGBT = _voteStake;
    }

    function setVoteValue(uint _voteId,uint _voteValue) onlyInternal
    {
        allVotes[_voteId].voteValue = _voteValue;
    }

    function getVoteStake(uint _voteId)constant returns(uint)
    {
        return (allVotes[_voteId].voteStakeGBT);
    }
    
    /// @dev Add points to add or subtract in memberReputation when proposal/option/vote gets denied or accepted.
    function addMemberReputationPoints() internal
    {
        addProposalOwnerPoints = 5;
        addOptionOwnerPoints = 5;
        addMemberPoints = 1;
        subProposalOwnerPoints = 1;
        subOptionOwnerPoints = 1;
        subMemberPoints = 1;
    }

    /// @dev Change points to add or subtract in memberReputation when proposal/option/vote gets denied or accepted.
    function changeMemberReputationPoints(uint _addProposalOwnerPoints,uint  _addOptionOwnerPoints, uint _addMemberPoints,uint _subProposalOwnerPoints,uint  _subOptionOwnerPoints, uint _subMemberPoints) onlyOwner
    {
        addProposalOwnerPoints = _addProposalOwnerPoints;
        addOptionOwnerPoints= _addOptionOwnerPoints;
        addMemberPoints = _addMemberPoints;
        subProposalOwnerPoints = _subProposalOwnerPoints;
        subOptionOwnerPoints= _subOptionOwnerPoints;
        subMemberPoints = _subMemberPoints;
    }

    /// @dev add status.
    function addStatus() internal
    {
        status.push("Draft for discussion"); 
        status.push("Draft Ready for submission");
        status.push("Voting started"); 
        status.push("Proposal Decision - Accepted by Majority Voting"); 
        status.push("Proposal Decision - Rejected by Majority voting"); 
        status.push("Proposal Denied, Threshold not reached"); 
    }

    /// @dev Set Parameters value that will help in Distributing reward.
    function setGlobalParameters() internal
    {
        pendingProposalStart=0;
        quorumPercentage=25;
        GBTStakeValue=0;
        globalRiskFactor=5;
        membershipScalingFactor=1;
        scalingWeight=1;
        depositPercProposal=30;
        depositPercOption=30;
        depositPercVote=40;
    }

    /// @dev Set Vote Id against given proposal.
    function setVoteIdAgainstProposal(uint _proposalId,uint _voteId) onlyInternal
    {
        allProposalVotes[_proposalId].push(_voteId);
    }

    /// @dev Get Total votes against a proposal when given proposal id.
    function getVoteLengthById(uint _proposalId) constant returns(uint totalVotesLength)
    {
        return (allProposalVotes[_proposalId].length);
    }

    /// @dev Get Array of All vote id's against a given proposal when given _proposalId.
    function getVoteArrayById(uint _proposalId) constant returns(uint id,uint[] totalVotes)
    {
        return (_proposalId,allProposalVotes[_proposalId]);
    }

    /// @dev Get Vote id one by one against a proposal when given proposal Id and Index to traverse vote array.
    function getVoteIdById(uint _proposalId,uint _voteArrayIndex) constant returns (uint voteId)
    {
        return (allProposalVotes[_proposalId][_voteArrayIndex]);
    }

    /// @dev Set all the voting type names and thier addresses.
    function setVotingTypeDetails(bytes32 _votingTypeName,address _votingTypeAddress) onlyOwner
    {
        allVotingTypeDetails.push(votingTypeDetails(_votingTypeName,_votingTypeAddress)); 
    }

    function editVotingType(uint _votingTypeId,address _votingTypeAddress) onlyInternal
    {
        allVotingTypeDetails[_votingTypeId].votingTypeAddress = _votingTypeAddress;
    }

    function getVotingTypeLength() public constant returns(uint) 
    {
        return allVotingTypeDetails.length;
    }

    function getVotingTypeDetailsById(uint _votingTypeId) public constant returns(uint votingTypeId,bytes32 VTName,address VTAddress)
    {
        return (_votingTypeId,allVotingTypeDetails[_votingTypeId].votingTypeName,allVotingTypeDetails[_votingTypeId].votingTypeAddress);
    }

    function getVotingTypeAddress(uint _votingTypeId)constant returns (address votingAddress)
    {
        return (allVotingTypeDetails[_votingTypeId].votingTypeAddress);
    }

    function setProposalAnsByAddress(uint _proposalId,address _memberAddress) onlyInternal
    {
        allProposalOption[_memberAddress].push(_proposalId); 
    }

    function getProposalAnsByAddress(address _memberAddress)constant returns(uint[]) // ProposalIds to which solutions being provided
    {
        return (allProposalOption[_memberAddress]);
    }

    function getProposalAnsLength(address _memberAddress)constant returns(uint)
    {
        return (allProposalOption[_memberAddress].length);
    }

    function getProposalAnsId(address _memberAddress, uint _index)constant returns (uint) // return proposId to which option added.
    {
        return (allProposalOption[_memberAddress][_index]);
    }

    /// @dev Set the Deatils of added verdict i.e. Verdict Stake, Verdict value and Address of the member whoever added the verdict.
    function setOptionIdByAddress(uint _proposalId,address _memberAddress) onlyInternal
    {
        allOptionDataAgainstMember[_memberAddress][_proposalId] = getTotalVerdictOptions(_proposalId);
    }

    function getOptionIdByAddress(uint _proposalId,address _memberAddress) constant returns(uint optionIndex)
    {
        return (allOptionDataAgainstMember[_memberAddress][_proposalId]);
    }

    function setOptionAddress(uint _proposalId,address _memberAddress) onlyInternal
    {
        allProposalCategory[_proposalId].optionAddedByAddress.push(_memberAddress);
    }

    function setOptionStake(uint _proposalId,uint _stakeValue) onlyInternal
    {
        allProposalCategory[_proposalId].stakeOnOption.push(_stakeValue);
    }

    function setOptionValue(uint _proposalId,uint _optionValue) onlyInternal
    {
        allProposalCategory[_proposalId].valueOfOption.push(_optionValue);
    }

    function setOptionHash(uint _proposalId,string _optionHash) onlyInternal
    {
        allProposalCategory[_proposalId].optionHash.push(_optionHash);
    }

    function setOptionDateAdded(uint _proposalId,uint _dateAdd) onlyInternal
    {
        allProposalCategory[_proposalId].optionDateAdd.push(_dateAdd);
    }

    function getOptionDateAdded(uint _proposalId,uint _optionIndex)constant returns(uint)
    {
        return (allProposalCategory[_proposalId].optionDateAdd[_optionIndex]);
    }

    function setProposalCategory(uint _proposalId,uint8 _categoryId) onlyInternal
    {
        allProposal[_proposalId].category = _categoryId;
    }

    function setProposalStake(uint _proposalId,uint _memberStake) onlyInternal
    {
        allProposal[_proposalId].proposalStake = _memberStake;
    }

    function setProposalValue(uint _proposalId,uint _proposalValue) onlyInternal
    {
        allProposal[_proposalId].proposalValue = _proposalValue;
    }

    /// @dev Updates  status of an existing proposal.
    function updateProposalStatus(uint _id ,uint8 _status)  onlyInternal
    {
        allProposal[_id].propStatus = _status;
        allProposal[_id].date_upd = now;
    }

    /// @dev Stores the status information of a given proposal.
    function pushInProposalStatus(uint _proposalId , uint8 _status) onlyInternal
    {
        proposalStatus[_proposalId].push(Status(_status,now));
    }

    function setInitialOptionsAdded(uint _proposalId) onlyInternal
    {
        require (initialOptionsAdded[_proposalId] == 0);
            initialOptionsAdded[_proposalId] = 1;
    }

    function getInitialOptionsAdded(uint _proposalId) constant returns (uint)
    {
        if(initialOptionsAdded[_proposalId] == 1)
            return 1;
    }

    function setTotalOptions(uint _proposalId) onlyInternal
    {
        allProposalCategory[_proposalId].verdictOptions = allProposalCategory[_proposalId].verdictOptions +1;
    }

    function setProposalIncentive(uint _proposalId,uint _reward) onlyInternal
    {
        allProposal[_proposalId].commonIncentive = _reward;  
    }

    function setCategorizedBy(uint _proposalId,address _memberAddress) onlyInternal
    {
        allProposalCategory[_proposalId].categorizedBy = _memberAddress;
    }

    function setProposalLevel(uint _proposalId,uint8 _proposalComplexityLevel) onlyInternal
    {
         allProposal[_proposalId].complexityLevel = _proposalComplexityLevel;
    }

  
    /// @dev Changes the status of a given proposal.
    function changeProposalStatus(uint _id,uint8 _status) onlyInternal
    {
        require(allProposal[_id].category != 0);
        pushInProposalStatus(_id,_status);
        updateProposalStatus(_id,_status);
    }

    /// @dev Change Variables that helps in Calculation of reward distribution. Risk Factor, GBT Stak Value, Scaling Factor,Scaling weight.
    function changeGlobalRiskFactor(uint _riskFactor) onlyGBM
    {
        globalRiskFactor = _riskFactor;
    }

    function changeGBTStakeValue(uint _GBTStakeValue) onlyGBM
    {
        GBTStakeValue = _GBTStakeValue;
    }

    function changeMembershipScalingFator(uint _membershipScalingFactor) onlyGBM
    {
        membershipScalingFactor = _membershipScalingFactor;
    }

    function changeScalingWeight(uint _scalingWeight)  onlyGBM
    {
        scalingWeight = _scalingWeight;
    }

    /// @dev Change quoram percentage. Value required to proposal pass.
    function changeQuorumPercentage(uint _quorumPercentage) onlyGBM
    {
        quorumPercentage = _quorumPercentage;
    }

    function setProposalCurrentVotingId(uint _proposalId,uint8 _currVotingStatus) onlyInternal
    {
        allProposal[_proposalId].currVotingStatus = _currVotingStatus;
    }

    /// @dev Updating proposal's Major details (Called from close proposal Vote).
    function setProposalIntermediateVerdict(uint _proposalId,uint8 _intermediateVerdict) onlyInternal 
    {
        allProposal[_proposalId].currentVerdict = _intermediateVerdict;
    }

    function setProposalFinalVerdict(uint _proposalId,uint8 _finalVerdict) onlyInternal
    {
        allProposal[_proposalId].finalVerdict = _finalVerdict;
    }

    function setMemberReputation(string _description,uint _proposalId,address _memberAddress,uint _repPoints,uint _repPointsEventLog,bytes4 _typeOf) onlyInternal
    {
        allMemberReputationByAddress[_memberAddress] = _repPoints;
        Reputation(_memberAddress, _proposalId, _description,_repPointsEventLog,_typeOf);
    }

    /// @dev Stores the information of a given version number of a given proposal. Maintains the record of all the versions of a proposal.
    function storeProposalVersion(uint _proposalId) onlyInternal 
    {
        proposalVersions[_proposalId].push(proposalVersionData(allProposal[_proposalId].versionNum,allProposal[_proposalId].proposalDescHash,allProposal[_proposalId].date_add));            
    }

    function setProposalDesc(uint _proposalId,string _hash) onlyInternal
    {
        allProposal[_proposalId].proposalDescHash = _hash;
    }

    function setProposalDateUpd(uint _proposalId) onlyInternal
    {
        allProposal[_proposalId].date_upd = now;
    }

    function setProposalVersion(uint _proposalId) onlyInternal
    {
        allProposal[_proposalId].versionNum = allProposal[_proposalId].versionNum+1;

    }
    
    /// @dev Fetch user balance when giving member address.
    // function getBalanceOfMember(address _memberAddress) public constant returns (uint totalBalance)
    // {
    //     GBTS=GBTStandardToken(GBTSAddress);
    //     totalBalance = GBTS.balanceOf(_memberAddress);
    // }

    /// @dev Fetch details of proposal by giving proposal Id
    function getProposalDetailsById1(uint _proposalId) public constant returns (uint id,address owner,string proposalDescHash,uint date_add,uint date_upd,uint versionNum,uint propStatus)
    {
        return (_proposalId,allProposal[_proposalId].owner,allProposal[_proposalId].proposalDescHash,allProposal[_proposalId].date_add,allProposal[_proposalId].date_upd,allProposal[_proposalId].versionNum,allProposal[_proposalId].propStatus);
    }

    /// @dev Get the category, of given proposal. 
    function getProposalDetailsById2(uint _proposalId) public constant returns(uint id,uint8 category,uint8 currentVotingId,uint8 intermediateVerdict,uint8 finalVerdict,address votingTypeAddress) 
    {
        return (_proposalId,allProposal[_proposalId].category,allProposal[_proposalId].currVotingStatus,allProposal[_proposalId].currentVerdict,allProposal[_proposalId].finalVerdict,allProposal[_proposalId].votingTypeAddress); 
    }

    function getProposalDetailsById3(uint _proposalId) constant returns(uint proposalIndex,string proposalDescHash,uint dateAdded,string propStatus,uint propCategory,uint totalVotes,uint8 totalOption)
    {
        return (_proposalId,allProposal[_proposalId].proposalDescHash,allProposal[_proposalId].date_add,status[allProposal[_proposalId].propStatus],allProposal[_proposalId].category,allProposalVotes[_proposalId].length,allProposalCategory[_proposalId].verdictOptions);
    }

    function getProposalDetailsById4(uint _proposalId)constant returns(uint totalTokenToDistribute,uint numberBlock,uint propReward)
    {
        return(allProposal[_proposalId].totalreward,allProposal[_proposalId].blocknumber,allProposal[_proposalId].proposalReward);
    }

    /// @dev Get proposal Reward and complexity level Against proposal
    function getProposalDetails(uint _proposalId) public constant returns (uint id,uint proposalValue,uint proposalStake,uint incentive,uint complexity)
    {
        return (_proposalId,allProposal[_proposalId].proposalValue,allProposal[_proposalId].proposalStake,allProposal[_proposalId].commonIncentive,allProposal[_proposalId].complexityLevel);
    }

    /// @dev Gets version details of a given proposal id.
    function getProposalDetailsByIdAndVersion(uint _proposalId,uint _versionNum) public constant returns(uint id,uint versionNum,string proposalDescHash,uint date_add)
    {
        return (_proposalId,proposalVersions[_proposalId][_versionNum].versionNum,proposalVersions[_proposalId][_versionNum].proposalDescHash,proposalVersions[_proposalId][_versionNum].date_add);
    }
   
    function getProposalDateAdd(uint _proposalId)constant returns(uint)
    {
        return allProposal[_proposalId].date_add;
    }

    function getProposalDateUpd(uint _proposalId)constant returns(uint)
    {
        return allProposal[_proposalId].date_upd;
    }

    /// @dev Get member address who created the proposal.
    function getProposalOwner(uint _proposalId) public constant returns(address)
    {
        return allProposal[_proposalId].owner;
    }

    function getProposalIncentive(uint _proposalId)constant returns(uint reward)
    {
        reward = allProposal[_proposalId].commonIncentive;
    }

    function getProposalComplexity(uint _proposalId)constant returns(uint level)
    {
        level =  allProposal[_proposalId].complexityLevel;
    }

    function getProposalCurrentVotingId(uint _proposalId)constant returns(uint8 _currVotingStatus)
    {
        return (allProposal[_proposalId].currVotingStatus);
    }

    /// @dev Get Total number of verdict options against proposal.
    function getTotalVerdictOptions(uint _proposalId) constant returns(uint8 verdictOptions)
    {
        verdictOptions = allProposalCategory[_proposalId].verdictOptions;
    }

    /// @dev Get Current Status of proposal when given proposal Id
    function getProposalStatus(uint _proposalId) constant returns (uint propStatus)
    {
        propStatus = allProposal[_proposalId].propStatus;
    }

    function getProposalVotingType(uint _proposalId)constant returns(address)
    {
        return (allProposal[_proposalId].votingTypeAddress);
    }

    function getProposalCategory(uint _proposalId) constant returns(uint8 categoryId)
    {
        return allProposal[_proposalId].category;
    }

    /// @dev Get the number of tokens already distributed among members.
    // function getTotalTokenInSupply() constant returns(uint _totalSupplyToken)
    // {
    //     GBTS=GBTStandardToken(GBTSAddress);
    //     _totalSupplyToken = GBTS.totalSupply();
    // }

    /// @dev Member Reputation is set according to if Member's Decision is Final decision.
    function getMemberReputation(address _memberAddress) constant returns(uint memberPoints)
    {
        if(allMemberReputationByAddress[_memberAddress] == 0)
            memberPoints = 1;
        else
            memberPoints = allMemberReputationByAddress[_memberAddress];
    }

    /// @dev Get proposal Value when given proposal Id.
    function getProposalValue(uint _proposalId) constant  returns(uint proposalValue) 
    {
        proposalValue = allProposal[_proposalId].proposalValue;
    }

    /// @dev Get proposal Stake by member when given proposal Id.
    function getProposalStake(uint _proposalId) constant returns(uint proposalStake)
    {
        proposalStake = allProposal[_proposalId].proposalStake;
    }

    function getProposalReward(uint _proposalId) constant returns(uint proposalReward)
    {
        proposalReward = allProposal[_proposalId].proposalReward;
    }

    /// @dev Fetch Total length of Member address array That added number of verdicts against proposal.
    function getOptionAddedAddressLength(uint _proposalId) constant returns(uint length)
    {
        return  allProposalCategory[_proposalId].optionAddedByAddress.length;
    }

    function getOptionHashByProposalId(uint _proposalId,uint _optionIndex) constant returns(string)
    {
        return allProposalCategory[_proposalId].optionHash[_optionIndex];
    }

    /// @dev Get the Stake of verdict when given Proposal Id and Verdict index.
    function getOptionStakeById(uint _proposalId,uint _optionIndex) constant returns(uint optionStake)
    {
        optionStake = allProposalCategory[_proposalId].stakeOnOption[_optionIndex];
    }

    /// @dev Get the value of verdict when given Proposal Id and Verdict Index.
    function getOptionValueByProposalId(uint _proposalId,uint _optionIndex) constant returns(uint optionValue)
    {
        optionValue = allProposalCategory[_proposalId].valueOfOption[_optionIndex];
    }

    /// @dev Get the Address of member whosoever added the verdict when given Proposal Id and Verdict Index.
    function getOptionAddressByProposalId(uint _proposalId,uint _optionIndex) constant returns(address memberAddress)
    {
        memberAddress = allProposalCategory[_proposalId].optionAddedByAddress[_optionIndex];
    }
    function getProposalLength()constant returns(uint)
    {  
        return (allProposal.length);
    }  

    function addInTotalVotes(address _memberAddress,uint _voteId)
    {
        allMemberVotes[_memberAddress].push(_voteId);
    }

    function getVoteArrayByAddress(address _memberAddress) constant returns(uint[] totalVoteArray)
    {
        return (allMemberVotes[_memberAddress]);
    }

    function getTotalVotesByAddress(address _memberAddress)constant returns(uint)
    {
        return (allMemberVotes[_memberAddress].length);
    }

    function addTotalProposal(uint _proposalId,address _memberAddress) onlyInternal
    {
        allProposalMember[_memberAddress].push(_proposalId);
    }

    function getTotalProposal(address _memberAddress) constant returns(uint)
    {
        return allProposalMember[_memberAddress].length;
    }

    function getProposalsbyAddress(address _memberAddress) constant returns(uint[] proposalid)
    {
       return  allProposalMember[_memberAddress];
    }

    function getProposalIdByAddress(address _memberAddress,uint _index)constant returns(uint)
    {
        return (allProposalMember[_memberAddress][_index]);
    }

    function setProposalTotalToken(uint _proposalId,uint _totalTokenToDistribute) onlyInternal
    {
        allProposal[_proposalId].totalreward = _totalTokenToDistribute;
    }

    function setProposalBlockNo(uint _proposalId,uint _blockNumber) onlyInternal
    {
        allProposal[_proposalId].blocknumber = _blockNumber;
    }

    function setProposalReward(uint _proposalId,uint _reward) onlyInternal
    {
        allProposal[_proposalId].proposalReward = _reward;
    }

    function setOptionReward(uint _proposalId,uint _reward,uint _optionIndex) onlyInternal
    {
        allProposalCategory[_proposalId].rewardOption[_optionIndex] = _reward;
    }

    function getOptionReward(uint _proposalId,uint _optionIndex)constant returns(uint)
    {
        return (allProposalCategory[_proposalId].rewardOption[_optionIndex]);
    }

    function getProposalFinalOption(uint _proposalId) constant returns(uint finalOptionIndex)
    {
        finalOptionIndex = allProposal[_proposalId].finalVerdict;
    }

    function getProposalRewardById(uint _proposalId) constant returns(uint propStake,uint propReward)
    {
        return(allProposal[_proposalId].proposalStake,allProposal[_proposalId].proposalReward);
    }

    function getProposalDescHash(uint _proposalId)constant returns(string)
    {
        return (allProposal[_proposalId].proposalDescHash);
    }  
    
    /// @dev Get points to proceed with updating the member reputation level.
    function getMemberReputationPoints() constant returns(uint addProposalOwnPoints,uint addOptionOwnPoints,uint addMemPoints,uint subProposalOwnPoints,uint subOptionOwnPoints,uint subMemPoints)
    {
        return (addProposalOwnerPoints,addOptionOwnerPoints,addMemberPoints,subProposalOwnerPoints,subOptionOwnerPoints,subMemberPoints);
    } 

    function changeProposalOwnerAdd(uint _repPoints) onlyGBM
    {
        addProposalOwnerPoints = _repPoints;
    }

    function changeOptionOwnerAdd(uint _repPoints) onlyGBM
    {
        addOptionOwnerPoints = _repPoints;
    }

    function changeProposalOwnerSub(uint _repPoints) onlyGBM
    {
        subProposalOwnerPoints = _repPoints;
    }

    function changeOptionOwnerSub(uint _repPoints) onlyGBM
    {
        subOptionOwnerPoints = _repPoints;
    }  

    function changeMemberAdd(uint _repPoints) onlyGBM
    {
        addMemberPoints = _repPoints;
    }  

    function changeMemberSub(uint _repPoints) onlyGBM
    {
        subMemberPoints = _repPoints;
    }  

    function addNewProposal(address _memberAddress,string _proposalDescHash,uint8 _categoryId,address _votingTypeAddress,uint _date) onlyInternal
    {
        allProposal.push(proposal(_memberAddress,_proposalDescHash,_date,now,0,0,0,_categoryId,0,0,_votingTypeAddress,0,0,0,0,0,0,0));               
    }  
    
    function changePendingProposalStart(uint _value) onlyInternal
    {
        pendingProposalStart = _value;
    }
}  

 

