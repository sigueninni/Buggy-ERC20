// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity ^0.8.20;

contract MyTKN {
    string public name;
    string public symbol;
    uint8 public decimals;

    address public owner;

    mapping(address => uint256) public balanceOf;

    uint256 public totalSupply;

    mapping(address => mapping(address => uint256)) public allowances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        owner = msg.sender;
    }

    function mint(uint256 amount) public {
        require(msg.sender == owner, "only owner can create tokens");
        totalSupply += amount;
        balanceOf[owner] += amount;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        return HelperTransfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        if (from != msg.sender) {
            require(
                allowances[from][msg.sender] >= amount,
                "you don't have enough allowances"
            );
            allowances[from][msg.sender] -= amount;
        }

        return HelperTransfer(from, to, amount);
    }

    function HelperTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(balanceOf[from] >= amount, "you don't have enough tokens");

        require(to != address(0), "canno't transfer to zero address"); //considered as a burn

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        return true;
    }
}
