// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BattleOrganizer is Ownable {
    enum BattleStatus {
        closed,
        openForVoting,
        complete
    }

    struct Battle {
        address player1;
        address player2;
        BattleStatus status;
        mapping(address => bool) voterToBool;
        uint256 player1Total;
        uint256 player2Total;
    }

    Battle[] public battles;

    function createNewBattle(address _player1, address _player2) external onlyOwner returns (uint256 _battleId) {
        _battleId = battles.length;
        Battle storage newBattle = battles[_battleId];
        newBattle.player1 = _player1;
        newBattle.player2 = _player2;
    }

    function openBattleForVoting(uint256 _battleId) external onlyOwner {
        Battle storage currentBattle = battles[_battleId];
        require(currentBattle.status == BattleStatus.closed, "Battle must be in closed state to open for voting");
        currentBattle.status = BattleStatus.openForVoting;
    }

    function vote(uint256 _battleId, address _winner) external onlyOwner {
        Battle storage currentBattle = battles[_battleId];
        require(currentBattle.voterToBool[msg.sender] == false, "You can only vote once");
        require(
            _winner == currentBattle.player1 || _winner == currentBattle.player2,
            "You can only vote for players in current battle"
        );
        require(currentBattle.status == BattleStatus.openForVoting, "Battle is not open for voting");
        currentBattle.voterToBool[msg.sender] = true;
        if (_winner == currentBattle.player1) {
            currentBattle.player1Total++;
        } else {
            currentBattle.player2Total++;
        }
    }

    function closeBattleForVoting(uint256 _battleId) external onlyOwner {
        Battle storage currentBattle = battles[_battleId];
        require(currentBattle.status == BattleStatus.openForVoting, "Battle must be in openForVoting state to close");
        currentBattle.status = BattleStatus.complete;
    }
  
    // TIEBREAKERS!!!
    function seeWinner(uint _battleId) external view returns (address) {
        Battle storage currentBattle = battles[_battleId];
        require(currentBattle.status == BattleStatus.complete,  "Battle is not yet over");
        if (currentBattle.player1Total > currentBattle.player2Total) {
          return currentBattle.player1;
        } else {
          return currentBattle.player2;
        }
    }
}
