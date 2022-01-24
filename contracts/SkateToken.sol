// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract SkateToken is ERC20 {
  address private _owner;
  constructor(uint256 totalSupply) ERC20("SkateToken", "SKT") {
    _owner = msg.sender;
    _mint(msg.sender, totalSupply * 1e18);
  }

  function owner() public view returns(address) {
    return _owner;
  }

  function mint(address _to,  uint256 _amount) public {
    _mint(_to, _amount);
  }
}
