// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC20 {
    
    //账户余额
    mapping(address => uint256) balances;
    //授权信息
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //查询账户余额
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        address sender = msg.sender;
        _transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool){
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;

    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool){
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "transfer amount exceeds allowance");

        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal  {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");

        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "transfer amount exceeds balance");

        balances[from] = fromBalance - amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function mint(address to, uint256 amount) public {
        require(to != address(0), "mint to the zero address");
        balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }
}