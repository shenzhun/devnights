pragma solidity ^0.4.21;

import './SafeMath.sol';

contract BettingGame {
    
    address public owner;
    
    struct Bet {
        uint256 choice;
        uint256 amount;
        bool paid;
        bool initialized;
    }
    mapping(address => Bet) bets;

    using SafeMath for uint256;
    
    uint256 total_bet_amount;
    mapping(uint256 => uint256) choice_bet_amounts;
    
    uint256 correct_choice;

    uint256 game_status; // 0 not started; 1 running; 2 ended
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
    constructor () public {
        owner = msg.sender;
        game_status = 0;
    }
    
    function startGame() external onlyOwner {    
        total_bet_amount = 0;
        game_status = 1;
    }
    
    function placeBet (uint256 _choice) public payable {
        require (game_status == 1); // game is running
        require (_choice > 0);
        require (_choice <= 12);
        require (msg.value > 0); // Must have bet amount
        require (bets[msg.sender].initialized == false); // Cannot bet twice
        
        Bet memory newBet = Bet(_choice, msg.value, false, true);
        bets[msg.sender] = newBet;
        
        choice_bet_amounts[_choice] = choice_bet_amounts[_choice] + msg.value;
        total_bet_amount = total_bet_amount + msg.value;
    }
    
    function endGame(uint256 _correct_choice) external onlyOwner {
        correct_choice = _correct_choice;
        game_status = 2;
    }
    
    function payMe () public {
        require (game_status == 2); // game is done
        require (bets[msg.sender].initialized); // Must have a bet
        require (bets[msg.sender].amount > 0); // More than zero
        require (bets[msg.sender].choice == correct_choice); // chose correctly
        require (bets[msg.sender].paid == false); // chose correctly
        
        uint256 payout = bets[msg.sender].amount * total_bet_amount / choice_bet_amounts[correct_choice];
        if (payout > 0) {
            msg.sender.transfer(uint256(payout));
            bets[msg.sender].paid == true; // cannot claim twice
        }
    }

    function getAnswer() public view returns (uint256) {
        return (correct_choice);
    }
  
    function terminate() external onlyOwner {
        selfdestruct(owner);
    }
}