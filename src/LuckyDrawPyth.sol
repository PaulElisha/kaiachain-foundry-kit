// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IFeedProxy } from "lib/orakl/contracts/v0.2/src/interfaces/IFeedProxy.sol";
import { VRFConsumerBase } from "lib/orakl/contracts/v0.1/src/VRFConsumerBase.sol";
import { IVRFCoordinator } from "lib/orakl/contracts/v0.1/src/interfaces/IVRFCoordinator.sol";
import { PriceConverter } from "src/PriceConverterPyth.sol";
import { TokenERC20 } from "src/TokenERC20.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";


/// @title LuckyDraw
/// @author BlockCMD
/// @notice A Lucky Draw contract that mints a random amount of ERC20 token to the caller using Orakl Network
contract LuckyDraw is VRFConsumerBase {
    /// -----------------------------------------------------------------------
    /// Oracle variables
    /// -----------------------------------------------------------------------
    // VRF Coordinator
    IVRFCoordinator COORDINATOR;
    // Account ID to use for VRF requests
    uint64 private accountId;
    // Key Hash to use for VRF requests
    bytes32 public keyHash;
    // Gas limit to use for VRF requests
    uint32 public callbackGasLimit = 2_000_000;
    // Data feed contract for KLAY-USDT
    IPyth private pyth;
    // Number of words to request
    uint256 private numWords = 1;

    /// -----------------------------------------------------------------------
    /// State variables
    /// -----------------------------------------------------------------------
    uint256 private requestId;
    TokenERC20 public tokenERC20;
    uint256 public lastRandomValue;
    bytes32 feedId;
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------
    using PriceConverter for uint256;

    /// -----------------------------------------------------------------------
    /// Constant variables
    /// -----------------------------------------------------------------------
    uint256 public constant MINIMUM_USD = 1 * 10 ** 18;

    /// -----------------------------------------------------------------------
    /// Immutable variables
    /// -----------------------------------------------------------------------
    address private immutable i_owner;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------
    error LuckyDraw__InsufficientAmount();
    error LuckyDraw__OnlyOwnerCanWithdraw();
    error LuckyDraw__OnlyOwnerCanSetERC20Token();
    error LuckyDraw_RequestNotFound();

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------
    constructor(
        address _dataFeed,
        address _coordinator,
        bytes32 _keyHash,
        uint64 _accountId,
        bytes32 _feedId
    )
        VRFConsumerBase(_coordinator)
    {
        pyth = IPyth(_dataFeed);
        feedId = _feedId;
        COORDINATOR = IVRFCoordinator(_coordinator);
        accountId = _accountId;
        keyHash = _keyHash;
        i_owner = msg.sender;
    }

    /// -----------------------------------------------------------------------
    /// Owner actions
    /// -----------------------------------------------------------------------
    function setERC20Token(address newERC20TokenAddress) public {
        /// -------------------------------------------------------------------
        /// Validation
        /// -------------------------------------------------------------------
        if (msg.sender != i_owner) {
            revert LuckyDraw__OnlyOwnerCanSetERC20Token();
        }

        /// -------------------------------------------------------------------
        /// State updates
        /// -------------------------------------------------------------------
        tokenERC20 = TokenERC20(newERC20TokenAddress);
    }

    function withdraw() public {
        /// -------------------------------------------------------------------
        /// Validation
        /// -------------------------------------------------------------------
        if (msg.sender != i_owner) {
            revert LuckyDraw__OnlyOwnerCanWithdraw();
        }
        /// -------------------------------------------------------------------
        /// Transfer
        /// -------------------------------------------------------------------
        (bool success,) = i_owner.call{ value: address(this).balance }("");
        /// -------------------------------------------------------------------
        /// Transfer validation
        /// -------------------------------------------------------------------
        require(success);
    }

    function requestRandomWords() public returns (uint256) {
        return COORDINATOR.requestRandomWords(keyHash, accountId, callbackGasLimit, 1);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        // requestId should be checked if it matches the expected request.
        // Generate random value between 1 and 50.
        requestId = _requestId;
        lastRandomValue = (_randomWords[0] % 50) + 1;
        tokenERC20.mint(0x6FaFF29226219756aa40CE648dbc65FB41DE5F72, lastRandomValue * 10 ** 18);
    }

    /// -----------------------------------------------------------------------
    /// Getters
    /// -----------------------------------------------------------------------
    function suggestedAmount(bytes[] calldata priceUpdate) public returns (uint256) {
        uint256 currentPrice = PriceConverter.getPrice(feedId, address(pyth), priceUpdate);
        return MINIMUM_USD / currentPrice;
    }
}
