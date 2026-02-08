// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract BettingContract {
    address public admin;
    address payable public bettor1;
    address payable public bettor2;

    bool public bettor1Paid;
    bool public bettor2Paid;
    bool public finished;

    uint256 public minCoinsBet;
    uint256 public creationOfContract;
    uint256 public bettingTimeLimit;
    uint256 public bettingTimeToPay;

    constructor(
        address _bettor1,
        address _bettor2,
        uint256 _minCoinsBet,
        uint256 _bettingTimeLimit,
        uint256 _bettingTimeToPay
    ) {
        require(_bettingTimeLimit < _bettingTimeToPay, "Invalid time limits");

        admin = msg.sender;
        bettor1 = payable(_bettor1);
        bettor2 = payable(_bettor2);

        minCoinsBet = _minCoinsBet;
        creationOfContract = block.timestamp;
        bettingTimeLimit = _bettingTimeLimit;
        bettingTimeToPay = _bettingTimeToPay;
    }

    modifier isAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier isBettor() {
        require(msg.sender == bettor1 || msg.sender == bettor2, "Only bettors");
        _;
    }

    modifier notFinished() {
        require(!finished, "Bet already finished");
        _;
    }

    function enterBet() external payable isBettor notFinished {
        require(
            block.timestamp <= creationOfContract + bettingTimeLimit,
            "Betting time over"
        );
        require(msg.value == minCoinsBet, "Incorrect bet amount");

        if (msg.sender == bettor1) {
            require(!bettor1Paid, "Bettor1 already paid");
            bettor1Paid = true;
        } else {
            require(!bettor2Paid, "Bettor2 already paid");
            bettor2Paid = true;
        }
    }

    function payToWinner(address payable winner)
        external
        isAdmin
        notFinished
    {
        require(
            block.timestamp <= creationOfContract + bettingTimeToPay,
            "Payment time expired"
        );
        require(bettor1Paid && bettor2Paid, "Both must have paid");
        require(
            winner == bettor1 || winner == bettor2,
            "Invalid winner"
        );

        finished = true;
        uint256 amount = address(this).balance;
        winner.transfer(amount);
    }

    function cancelBetBecauseNoOtherBettorOnTime()
        external
        isBettor
        notFinished
    {
        require(
            block.timestamp > creationOfContract + bettingTimeLimit,
            "Too early"
        );
        require(bettor1Paid != bettor2Paid, "Invalid cancel state");

        finished = true;
        uint256 amount = address(this).balance;

        if (bettor1Paid) bettor1.transfer(amount);
        if (bettor2Paid) bettor2.transfer(amount);
    }

    function cancelBetBecauseAdminNotPayedToWinnerOnTime()
        external
        isBettor
        notFinished
    {
        require(
            block.timestamp > creationOfContract + bettingTimeToPay,
            "Too early"
        );
        require(bettor1Paid && bettor2Paid, "Both must have paid");

        finished = true;
        uint256 half = address(this).balance / 2;

        bettor1.transfer(half);
        bettor2.transfer(address(this).balance);
    }
}
