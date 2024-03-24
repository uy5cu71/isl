// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @custom:security-contact contact@metailsland.gg
contract Metaisland is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant BLOCK_ROLE = keccak256("BLOCK_ROLE");

    uint256 public MAX_SUPPLY = 1000000000 ether;

    mapping(address => bool) _blacklist;

    event Blacklist(
        address indexed user,
        bool value
    );

    constructor() ERC20("Metaisland", "ISL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(BLOCK_ROLE, msg.sender);
        _mint(msg.sender, MAX_SUPPLY);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function blacklist(address user, bool value) public virtual onlyRole(BLOCK_ROLE) {
        _blacklist[user] = value;
        emit Blacklist(user, value);
    }

    function isBlackListed(address user) public view returns (bool) {
        return _blacklist[user];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        require(!isBlackListed(from), "Token transfer prohibited. You are on blacklist");
        require(!isBlackListed(to), "Token transfer prohibited. Receiver is on blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }
}
