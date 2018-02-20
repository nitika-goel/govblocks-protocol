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

/**
 * @title votingType interface for All Types of voting.
 */

pragma solidity ^0.4.8;
import "./SimpleVoting.sol";
import "./RankBasedVoting.sol";
import "./FeatureWeighted.sol";
import "./GovernanceData.sol";
import "./VotingType.sol";
import "./Pool.sol";
import "./Master.sol";
import "./Governance.sol";


contract StandardVotingType
{
    address SVAddress;
    address RBAddress;
    address FWAddress;
    address GDAddress;
    address MRAddress;
    address PCAddress;
    address VTAddress;
    address G1Address;
    address P1Address;
    address public masterAddress;
    Master MS;
    Pool P1;
    Governance G1;
    MemberRoles MR;
    ProposalCategory PC;
    GovernanceData  GD;
    BasicToken BT;
    StandardVotingType SVT;
    SimpleVoting SV;
    RankBasedVoting RB;
    FeatureWeighted FW;
    VotingType VT;

    modifier onlyInternal {
        MS=Master(masterAddress);
        require(MS.isInternal(msg.sender) == 1);
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
    
    function changeOtherContractAddress(address _SVaddress,address _RBaddress,address _FWaddress) 
    {
        SVAddress = _SVaddress;
        RBAddress = _RBaddress;
        FWAddress = _FWaddress;
    }

    function changeOtherContractAddress1(address _governanceContractAddress,address _poolContractAddress)
    {
        G1Address = _governanceContractAddress;
        P1Address = _poolContractAddress;
    }
    
    function changeAllContractsAddress(address _GDcontractAddress, address _MRcontractAddress, address _PCcontractAddress) 
    {
        GDAddress = _GDcontractAddress;
        MRAddress = _MRcontractAddress;
        PCAddress = _PCcontractAddress;
    }

    function setOptionValue_givenByMemberSVT(address _memberAddress,uint _proposalId,uint _memberStake) internal returns (uint finalOptionValue)
    {
        GD=GovernanceData(GDAddress);
        uint reputation = GD.getMemberReputation(_memberAddress);
        if(reputation==0)
            reputation=1;

        uint memberLevel = Math.max256(reputation,1);
        uint tokensHeld = SafeMath.div((SafeMath.mul(SafeMath.mul(GD.getBalanceOfMember(_memberAddress),100),100)),GD.getTotalTokenInSupply());
        uint maxValue= Math.max256(tokensHeld,GD.membershipScalingFactor());

        finalOptionValue = SafeMath.mul(SafeMath.mul(GD.globalRiskFactor(),memberLevel),SafeMath.mul(_memberStake,maxValue));
    }

    function setVoteValue_givenByMember(address _memberAddress,uint _proposalId,uint _memberStake) onlyInternal returns (uint finalVoteValue)
    {
        GD=GovernanceData(GDAddress);
        uint reputation = GD.getMemberReputation(_memberAddress);
        if(reputation==0)
            reputation=1;
            
        uint tokensHeld = SafeMath.div((SafeMath.mul(SafeMath.mul(GD.getBalanceOfMember(_memberAddress),100),100)),GD.getTotalTokenInSupply());
        uint value= SafeMath.mul(Math.max256(_memberStake,GD.scalingWeight()),Math.max256(tokensHeld,GD.membershipScalingFactor()));
        finalVoteValue = SafeMath.mul(reputation,value);
    }  
    
    function addVerdictOptionSVT(uint _proposalId,address _memberAddress,uint[] _paramInt,bytes32[] _paramBytes32,address[] _paramAddress,uint _GBTPayableTokenAmount,string _optionDescHash) onlyInternal
    {
        GD=GovernanceData(GDAddress);
        MR=MemberRoles(MRAddress);
        PC=ProposalCategory(PCAddress);

        address votingTypeAddress;
        (,,,,,votingTypeAddress) = GD.getProposalDetailsById2(_proposalId);
        
        VT=VotingType(votingTypeAddress);

        uint currentVotingId;
        (,,currentVotingId,,,) = GD.getProposalDetailsById2(_proposalId);

        require(currentVotingId == 0 && GD.getProposalStatus(_proposalId) == 2 && GD.getBalanceOfMember(_memberAddress) != 0);
        require(VT.getVoteId_againstMember(_memberAddress,_proposalId) == 0 && _GBTPayableTokenAmount > 0);
        
        uint8 paramInt; uint8 paramBytes32; uint8 paramAddress;
        (,,,,paramInt,paramBytes32,paramAddress,,) = PC.getCategoryDetails(GD.getProposalCategory(_proposalId));

        if(paramInt == _paramInt.length && paramBytes32 == _paramBytes32.length && paramAddress == _paramAddress.length)
        {
            addVerdictOptionSVT1(_proposalId,_memberAddress,_GBTPayableTokenAmount,_optionDescHash);
            addVerdictOptionSVT2(_proposalId,GD.getProposalCategory(_proposalId),_paramInt,_paramBytes32,_paramAddress);
        } 
    }

    function addVerdictOptionSVT1(uint _proposalId,address _memberAddress,uint _GBTPayableTokenAmount,string _optionDescHash) internal
    {
        GD.setOptionAddressAndStake(_proposalId,_memberAddress,_GBTPayableTokenAmount,setOptionValue_givenByMemberSVT(_memberAddress,_proposalId,_GBTPayableTokenAmount),_optionDescHash);
    }
    function addVerdictOptionSVT2(uint _proposalId,uint _categoryId,uint[] _paramInt,bytes32[] _paramBytes32,address[] _paramAddress) internal
    {
        G1=Governance(G1Address);
        G1.setProposalCategoryParams(_categoryId,_proposalId,_paramInt,_paramBytes32,_paramAddress,GD.getTotalVerdictOptions(_proposalId)+1); // MAKE +1 IN go
    }
    
    uint public testValue;
   
    function closeProposalVoteSVT(uint _proposalId) 
    {   
        GD=GovernanceData(GDAddress);
        MR=MemberRoles(MRAddress);
        PC=ProposalCategory(PCAddress);
        G1=Governance(G1Address);
        address votingTypeAddress;
        (,,,,,votingTypeAddress) = GD.getProposalDetailsById2(_proposalId);
        
        VT=VotingType(votingTypeAddress);
        
        uint8 currentVotingId; uint8 category;
        uint8 max; uint totalVotes;
        uint verdictVal; uint majorityVote;
    
        (,category,currentVotingId,,,) = GD.getProposalDetailsById2(_proposalId);
        uint8 verdictOptions = GD.getTotalVerdictOptions(_proposalId);

    
        require(G1.checkProposalVoteClosing(_proposalId)==1); //1

        uint roleId = PC.getRoleSequencAtIndex(category,currentVotingId);
        

        max=0;  
        for(uint8 i = 0; i < verdictOptions; i++)
        {
            totalVotes = SafeMath.add(totalVotes,VT.getVoteValuebyOption_againstProposal(_proposalId,roleId,i)); 
            if(VT.getVoteValuebyOption_againstProposal(_proposalId,roleId,max) < VT.getVoteValuebyOption_againstProposal(_proposalId,roleId,i))
            {  
                max = i; 
            }
        }
        
        verdictVal = VT.getVoteValuebyOption_againstProposal(_proposalId,roleId,max);
        majorityVote= PC.getRoleMajorityVote(category,currentVotingId);
       
        if(totalVotes != 0)
        {
            if(SafeMath.div(SafeMath.mul(verdictVal,100),totalVotes)>=majorityVote)
                {   
                    currentVotingId = currentVotingId+1;
                    if(max > 0 )
                    {
                        if(currentVotingId < PC.getRoleSequencLength(category))
                        {
                            GD.updateProposalDetails(_proposalId,currentVotingId,max,0);
                            P1=Pool(P1Address);
                            P1.closeProposalOraclise(_proposalId,PC.getClosingTimeByIndex(category,currentVotingId));
                        } 
                        else
                        {
                            GD.updateProposalDetails(_proposalId,currentVotingId,max,max);
                            GD.changeProposalStatus(_proposalId,3);
                            // PC.actionAfterProposalPass(_proposalId ,category);
                            VT.giveReward_afterFinalDecision(_proposalId);
                        }
                    }
                    else
                    {
                        GD.updateProposalDetails(_proposalId,currentVotingId,max,max);
                        GD.changeProposalStatus(_proposalId,4);
                        GD.changePendingProposalStart();
                    }      
                } 
                else
                {
                    GD.updateProposalDetails(_proposalId,currentVotingId,max,max);
                    GD.changeProposalStatus(_proposalId,5);
                    GD.changePendingProposalStart();
                } 
        }
        else
        {
            GD.updateProposalDetails(_proposalId,currentVotingId,max,max);
            GD.changeProposalStatus(_proposalId,5);
            GD.changePendingProposalStart();
        }
    }
}







