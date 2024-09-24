// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    enum VoteStates {Absent, Yes, No}
    event ProposalCreated(uint);
    event VoteCast(uint,address);
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executed;
        mapping (address => VoteStates) voteStates;
    }
    mapping (address=>bool) members;
    constructor(address[] memory _members){
        for(uint i=0;i<_members.length;i++){
            members[_members[i]]=true;
        }
        members[msg.sender]=true;
    }
    
    Proposal[] public proposals;
    
    function newProposal(address _target, bytes calldata _data) external {
        require(members[msg.sender]);
        emit ProposalCreated(proposals.length);
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
        
    }

    function castVote(uint _proposalId, bool _supports) external {
         require(members[msg.sender]);
        Proposal storage proposal = proposals[_proposalId];
            if(proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
            }
            if(proposal.voteStates[msg.sender] == VoteStates.No) {
                proposal.noCount--;
            }
            
            if(_supports) {
                proposal.yesCount++;
            }
            else {
                proposal.noCount++;
            }
            emit VoteCast(_proposalId,msg.sender);
            proposal.voteStates[msg.sender] = _supports ? VoteStates.Yes : VoteStates.No;
        

        if(proposal.yesCount==10 && !proposal.executed){
           (bool success,)= proposal.target.call(proposal.data);
           require(success);
            proposal.executed=true;
        }
       
    }

   
}