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

    enum StackingTime {
        months_3,
        months_6,
        months_12,
        months_24
    }

    enum WithdrawOptions {
        AllWithdraw,
        NotAllWithdraw
    }

    struct BuyInfo {
        address _seller;
        address _payoutCurrency;
        uint256 _nftId;
        uint256 _nftAmount;
        uint256 _payoutAmount;
        StackingTime _stackOptions;
    }

    struct StackInfo {
        uint256 _stackId;
        uint256 _nftAmount;
        uint256 rewardAmount;
        address rewardCurrency;
        WithdrawOptions _withdrawOptions;
        StackingTime stackOptions;
    }

    struct UserInfo {
        uint256 _nftId;
        uint256 _nftAmount;
        uint256 _stackingTime;
        uint256 _stackCompleteTime;
        StackingTime stackOptions;
        bool _complete;
    }
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;
    mapping(address => uint256[]) public sellerAllNFTId;
    mapping(address => uint256[]) public buyerAllStackId;

    uint256 private nftId;
    uint256 private stakeId;

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

    function mint(address _seller, uint256 amount) public onlyOwner {
        nftId++;
        _mint(_seller, nftId, amount, "0x00");
        _safeTransferFrom(_seller, address(this), nftId, amount, "0x00");
        sellerAllNFTId[_seller].push(nftId);
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

    // struct BuyInfo{
    //     address _seller;
    //     address _payoutCurrency;
    //     uint _nftId;
    //     uint _nftAmount;
    //     uint _payoutAmount;
    //     StackingTime _stackOptions;
    // }
    function buy(BuyInfo memory _buy) public payable {
        require(
            _buy._payoutAmount != 0 && _buy._nftAmount != 0,
            "NFT Price and amount cannot be equal to zero"
        );

        if (_buy._payoutCurrency == address(0)) {
            payable(_buy._seller).transfer(_buy._payoutAmount);
        } else {
            IERC20(_buy._payoutCurrency).transferFrom(
                msg.sender,
                _buy._seller,
                _buy._payoutAmount
            );
        }

        _safeTransferFrom(
            address(this),
            msg.sender,
            _buy._nftId,
            _buy._nftAmount,
            "0x00"
        );
        _safeTransferFrom(
            msg.sender,
            address(this),
            _buy._nftId,
            _buy._nftAmount,
            "0x00"
        );
    }

    // struct StackInfo{
    //     uint _stackId;
    //     uint _nftAmount;
    //     uint rewardAmount;
    //     address rewardCurrency;
    //     WithdrawOptions _withdrawOptions;
    //     StackingTime stackOptions;
    // }

    function unstack(StackInfo memory _stackInfo) public {
        UserInfo storage user = userInfo[msg.sender][_stackInfo._stackId];
        require(
            user._nftAmount != 0 && user._nftId != 0,
            "Nft is showing zero for this user, Check again"
        );
        require(
            _stackInfo.rewardAmount != 0,
            "Reward Amount is zero, Check Again"
        );
        require(
            user._stackCompleteTime <= block.timestamp,
            "Stacking time is not complete yet"
        );
        require(user._complete == false, "This unstacking is already complete");

        _safeTransferFrom(
            address(this),
            msg.sender,
            user._nftId,
            user._nftAmount,
            "0x00"
        );

        if (_stackInfo._withdrawOptions == WithdrawOptions.AllWithdraw) {
            require(
                _stackInfo._nftAmount == 0,
                "All withdraw option selected, so NFT amount should be zero"
            );
        } else {
            _stacking(
                user._nftId,
                _stackInfo._nftAmount,
                _stackInfo.stackOptions
            );
           
        }
    }

    //mapping(address => mapping(uint256 => UserInfo)) public userInfo;

    // struct UserInfo {
    //     uint256 _nftId;
    //     uint256 _nftAmount;
    //     uint256 _stackingTime;
    //     uint256 _stackCompleteTime;
    //     StackingTime stackOptions;
    //     bool _complete;
    // }

    function _stacking(
        uint256 _nftId,
        uint256 _nftAmount,
        StackingTime _stackingOption
    ) private {
        stakeId++;
        uint256 stackCompTime;
        if (_stackingOption == StackingTime.months_3) {
            stackCompTime = block.timestamp + (3 * 2629743);
        } else if (_stackingOption == StackingTime.months_6) {
            stackCompTime = block.timestamp + (6 * 2629743);
        } else if (_stackingOption == StackingTime.months_12) {
            stackCompTime = block.timestamp + (12 * 2629743);
        } else {
            stackCompTime = block.timestamp + (24 * 2629743);
        }
        userInfo[msg.sender][stakeId] = UserInfo(
            _nftId,
            _nftAmount,
            block.timestamp,
            stackCompTime,
            _stackingOption,
            false
        );

        _safeTransferFrom(
            msg.sender,
            address(this),
            _nftId,
            _nftAmount,
            "0x00"
        );
        buyerAllStackId[msg.sender].push(stakeId);
    }

    function transferStuckNFT(
        address _seller,
        uint256 _nftId,
        uint256 _nftAmount
    ) public onlyOwner {
        _safeTransferFrom(address(this), _seller, _nftId, _nftAmount, "0x00");
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
