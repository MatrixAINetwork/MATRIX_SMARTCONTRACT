/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract SafetherStorage {
    struct Depositor {
        bytes8      _token;
        uint256     _limit;
        uint256     _deposit;
    }
    
    mapping (address=>Depositor) internal _depositor;
}

contract SafetherModifier is SafetherStorage {
    modifier isRegisterd {
        require(_depositor[msg.sender]._token != 0x0000000000000000);
        _;
    }
    
    modifier isNotRegisterd {
        require(_depositor[msg.sender]._token == 0x0000000000000000);
        _;
    }
    
    modifier isValidDepositor(address depositor, bytes8 token) {
        require(_depositor[depositor]._token != 0x0000000000000000);
        require(_depositor[depositor]._deposit > 0);
        require(_depositor[depositor]._token == token);
        require(block.number >= _depositor[depositor]._limit);
        _;
    }
}

contract SafetherAbstract {
    function getDepositor() public constant returns(bytes8, uint256, uint256);
    
    function register() public;
    function deposit(uint256 period) public payable;
    function withdraw(address depositor, bytes8 token) public payable;
    function cancel() public payable;
}

contract Safether is SafetherModifier, SafetherAbstract {
    function getDepositor() public constant returns(bytes8, uint256, uint256) {
        return (_depositor[msg.sender]._token, 
                _depositor[msg.sender]._limit,
                _depositor[msg.sender]._deposit);
    }
    
    function register() public isNotRegisterd {
        _depositor[msg.sender]._token = bytes8(keccak256(block.number, msg.sender));
    }
    
    function deposit(uint256 period) public payable isRegisterd {
        _depositor[msg.sender]._deposit += msg.value;
        _depositor[msg.sender]._limit = block.number + period;
    }
    
    function withdraw(address depositor, bytes8 token) public payable isValidDepositor(depositor, token) {
        uint256 tempDeposit = _depositor[depositor]._deposit;
         _depositor[depositor]._deposit = 0;
         msg.sender.transfer(tempDeposit + msg.value);
    }
    
    function cancel() public payable isRegisterd {
        uint256 tempDeposit = _depositor[msg.sender]._deposit;
        delete _depositor[msg.sender];
        msg.sender.transfer(tempDeposit + msg.value);
    }
}