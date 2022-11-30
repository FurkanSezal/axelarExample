//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';

contract DistributionExecutable is AxelarExecutable {
    IAxelarGasService public immutable gasReceiver;
    mapping(address => string) public addressToMessage;
    mapping(address => uint256) public addressToAmount;
    address public immutable owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) {
        gasReceiver = IAxelarGasService(gasReceiver_);
        owner = msg.sender;
    }

    function sendTokenWithMessage(
        string memory destinationChain,
        string memory destinationAddress,
        string calldata message,
        string memory symbol,
        uint256 amount
    ) external payable {
        address tokenAddress = gateway.tokenAddresses(symbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).approve(address(gateway), amount);
        bytes memory payload = abi.encode(message, msg.sender);
        if (msg.value > 0) {
            gasReceiver.payNativeGasForContractCallWithToken{ value: msg.value }(
                address(this),
                destinationChain,
                destinationAddress,
                payload,
                symbol,
                amount,
                msg.sender
            );
        }
        gateway.callContractWithToken(destinationChain, destinationAddress, payload, symbol, amount);
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata payload,
        string calldata /* tokenSymbol*/,
        uint256 amount
    ) internal override {
        (string memory _message, address messageSender) = abi.decode(payload, (string, address));
        addressToMessage[messageSender] = _message;
        addressToAmount[messageSender] = amount;
    }

    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{ value: address(this).balance }('');
        require(callSuccess, 'Call failed');
    }

    function seeMessage(address _sender) public view returns (string memory, uint256) {
        return (addressToMessage[_sender], addressToAmount[_sender]);
    }
}
