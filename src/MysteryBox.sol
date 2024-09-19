// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MysteryBox {
    address public owner;
    uint256 public boxPrice;
    mapping(address => uint256) public boxesOwned;
    mapping(address => Reward[]) public rewardsOwned;
    Reward[] public rewardPool;

    struct Reward {
        string name;
        uint256 value;
    }

    constructor() {
        owner = msg.sender;
        boxPrice = 0.1 ether;
        // Initialize with some default rewards
        rewardPool.push(Reward("Gold Coin", 1 ether));
        rewardPool.push(Reward("Silver Coin", 0.5 ether));
        rewardPool.push(Reward("Bronze Coin", 0.1 ether));
        rewardPool.push(Reward("Coal", 0 ether));
    }

    function setBoxPrice(uint256 _price) public {
        require(msg.sender == owner, "Only owner can set price");
        boxPrice = _price;
    }

    function addReward(string memory _name, uint256 _value) public {
        require(msg.sender == owner, "Only owner can add rewards");
        rewardPool.push(Reward(_name, _value));
    }

    function buyBox() public payable {
        require(msg.value == boxPrice, "Incorrect ETH sent");
        boxesOwned[msg.sender] += 1;
    }

    function openBox() public {
        require(boxesOwned[msg.sender] > 0, "No boxes to open");
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % rewardPool.length;
        rewardsOwned[msg.sender].push(rewardPool[randomIndex]);
        boxesOwned[msg.sender] -= 1;
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    function transferReward(address _to, uint256 _index) public {
        require(_index < rewardsOwned[msg.sender].length, "Invalid index");
        rewardsOwned[_to].push(rewardsOwned[msg.sender][_index]);
        delete rewardsOwned[msg.sender][_index];
    }

    function getRewards() public view returns (Reward[] memory) {
        return rewardsOwned[msg.sender];
    }

    function getRewardPool() public view returns (Reward[] memory) {
        return rewardPool;
    }

    function changeOwner(address _newOwner) public {
        owner = _newOwner;
    }
}
