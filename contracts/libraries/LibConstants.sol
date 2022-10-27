// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title LibConfig
 * @author Will Hoo
 */
library LibConstants {

    bytes32 public constant RECEIVER = keccak256("RECEIVER");

    bytes32 public constant ERC20_OPERATOR = keccak256("Receiver: ERC20_OPERATOR_ROLE");

    bytes32 public constant ERC721_OPERATOR = keccak256("Receiver: ERC721_OPERATOR_ROLE");

    bytes32 public constant USDT = keccak256("USDT");

    bytes32 public constant KKT = keccak256("KKT");



}
