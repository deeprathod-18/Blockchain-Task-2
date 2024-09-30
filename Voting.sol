pragma solidity >=0.5.0 <0.6.0;

contract Voting {
    struct Candidate {
        string name;
        uint VoteCount;
        bool active;
    }

    struct Voter {
        bool hasVoted;
        bool hasDelegated;
        uint VotedToIndex;
        address DelegatedTo;
    }

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    address public admin;

    event CandidateAdded(string name);
    event Voted(address indexed voter, uint CandidateIndex);
    event VoteDelegated(address indexed from, address indexed to);
    event VoteWithdrawn(address indexed voter);
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted);
        _;
    }

    constructor(string[] memory candidateNames) public {
        admin = msg.sender;
        for(uint i = 0; i < candidateNames.length; i++){
            candidates.push(Candidate(candidateNames[i], 0, true));
        }
    }

    function addCandidate(string memory _name) public onlyAdmin {
        candidates.push(Candidate(_name, 0, true));
        emit CandidateAdded(_name);
    }

    function Vote(uint _CandidateIndex) public hasNotVoted {
        require(_CandidateIndex < candidates.length);
        require(candidates[_CandidateIndex]).active);
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].VotedToIndex = _CandidateIndex;
        candidates[_CandidateIndex].VoteCount++;
        emit Voted(msg.sender, _CandidateIndex);
    }

    function DelegateVote(address _DelegateTo) public hasNotVoted {
        require(_DelegateTo == msg.sender);
        require(!voters[_DelegateTo].hasVoted);
        voters[msg.sender].hasDelegated = true;
        voters[msg.sender].DelegatedTo = _DelegateTo;
        emit VoteDelegated(msg.sender, _DelegateTo);
    }

    function WithdrawVote() public {
        require(voters[msg.sender].hasVoted);
        uint VotedFor = voters[msg.sender].VotedToIndex;
        candidates[VotedFor].VoteCount--;
        voters[msg.sender].hasVoted = false;
        emit VoteWithdrawn(msg.sender);
    }

    function getCandidateDetails(uint _index) public view returns (string memory name, uint VoteCount, bool active) {
        require(_index < candidates.length);
        Candidate memory candidate = candidates[index];
        return (candidate.name, candidate.VoteCount, candidate.active);
    }
}