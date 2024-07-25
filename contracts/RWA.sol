// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

contract RWA is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155HolderUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    uint public nftId;

    /// @notice Contract initializer
    function initialize(address initialOwner) public initializer {
        __ERC1155_init("");
        __Ownable_init(initialOwner);
    }
    
    /**
     @dev minting of NFT's will takes place by calling this function
     nftId value will increment after every call
     NFT will be stored in smart contract only so it will be available for sale
     */
    
    function mint(
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        nftId++;
        _mint(address(this), nftId, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }
    
    /* 
     @dev function to call to buy the NFT's
     @param _toNFT buyer address where the NFT will go
     @param _toAmount Seller address where the money will go
     @param _cryptoaddress for now USDT address
     @param _nftId the token id of NFT
     @param _nftAmount the amount of given token id
     @param _USDTAmount how much USDT should buyer pay
    */
    function buy(
        address _toNFT,
        address _toAmount,
        address _cryptoAddress,
        uint256 _nftId,
        uint256 _nftAmount,
        uint256 _USDTAmount
    ) public {
        require(_USDTAmount != 0 && _nftAmount!= 0,"NFT Price and amount cannot be equal to zero");
        safeTransferFrom(address(this), _toNFT, _nftId, _nftAmount, "0x00");
        IERC20(_cryptoAddress).transferFrom(_toNFT, _toAmount, _USDTAmount);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, ERC1155HolderUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
