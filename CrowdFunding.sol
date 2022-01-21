pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding {
   mapping (address=>uint) public contributors;
   address public manager;
   uint public target;
   uint public deadline;
   uint public raisedAmount;
   uint public minimumContribution;
   uint public noOfContributors;
   constructor (uint _target, uint _deadline) {
      manager = msg.sender;
      target = _target;
      deadline = block.timestamp + _deadline;
      minimumContribution = 100 wei;
   }

   struct Request{
      string description;
      address payable recipient;
      uint value;
      uint noOfVoters;
      bool complated;
      mapping(address => bool) voters;
   }
   mapping(uint => Request) requests;
   uint public numRequests;

   function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value >=minimumContribution,"Minimum Contribution is not met");
        
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }

   function getBalance() public view returns(uint){
      return address(this).balance;
   }

   function refund() public payable{
      require(block.timestamp > deadline && raisedAmount < target,"Refund is not availble rigth now");
      require(contributors[msg.sender] > 0,"already refund initiated");
      address payable user = payable(msg.sender);
      user.transfer(contributors[msg.sender]);
      contributors[msg.sender] =0;
   }

   function createRequest(string memory _description, uint _value, address payable _recipient ) public{
      require(msg.sender == manager,"Only manager can call this function");
      Request storage newRequest = requests[numRequests];
      numRequests++;
      newRequest.description = _description;
      newRequest.value = _value;
      newRequest.recipient = _recipient;
      newRequest.complated = false;
      newRequest.noOfVoters = 0;
   }

   function approveRequest(uint _requestNo) public {
      require(contributors[msg.sender] >= 0,"Only Contributors can approve request");
      Request storage thisRequest = requests[_requestNo];
      require(thisRequest.voters[msg.sender]==false,"You already approved this request");
      thisRequest.voters[msg.sender]=true;
      thisRequest.noOfVoters++;
   }

   function makePayment(uint _requestNo) public{
      require(msg.sender == manager,"only manager can call this Function");
      require(raisedAmount >= target,"Target not met");
      Request storage thisRequest = requests[_requestNo];
      require(thisRequest.complated==false,"Request already Complated");
     // require(thisRequest.value <= address(this).balance,"Not Enough balance");
      require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
      thisRequest.recipient.transfer(thisRequest.value);
      thisRequest.complated=true;

   }


}
