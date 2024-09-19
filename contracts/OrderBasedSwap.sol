// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBasedSwap {

  uint256 counter;

  struct Orders {
    uint256 depId;
    uint256 amountDeposited;
    IERC20 tokenDeposited;
    IERC20 tokenWanted;
    uint256 amountWanted;
    bool tokenSwapped;
  }

  mapping(address => Orders) usersOrders;
  mapping(uint256 => Orders) allOrders;

  error AddressZeroDetected();
  error YouCantDepositZeroAmount();
  error InsufficientBalance();

  event OrderOpenedSuccessfully(uint256 counter, uint256 _amountDeposited);
  event OrderDisplayedSuccessfully(uint256 orderId);

  function openOrder(uint256 _amountDeposited, IERC20 _tokenToBeDeposited, uint256 _amountOfTokenToBeReceived,
  IERC20 _tokenToBeReceived ) external{
    if(msg.sender == address(0)){
      revert AddressZeroDetected();
    }
    
    if(_amountDeposited <= 0){
      revert YouCantDepositZeroAmount();
    }

    if(_amountOfTokenToBeReceived <= 0){
      revert YouCantDepositZeroAmount();
    }

    if(_tokenToBeDeposited.balanceOf(msg.sender) < _amountDeposited){
      revert InsufficientBalance();
    }

    _tokenToBeDeposited.transferFrom(msg.sender, address(this), _amountDeposited);
    Orders storage order = usersOrders[msg.sender];
    counter++;

    order.depId = counter;
    order.amountDeposited = _amountDeposited;
    order.tokenDeposited = _tokenToBeDeposited;
    order.tokenWanted = _tokenToBeReceived;
    order.amountWanted = _amountOfTokenToBeReceived;
    order.tokenSwapped = false;

    Orders storage orderr = allOrders[counter];
    orderr.amountDeposited = _amountDeposited;
    orderr.tokenDeposited = _tokenToBeDeposited;
    orderr.tokenWanted = _tokenToBeReceived;
    orderr.amountWanted = _amountOfTokenToBeReceived;
    orderr.tokenSwapped = false;

    emit OrderOpenedSuccessfully(counter, _amountDeposited);

  }

  function displayOrderInfo(uint256 orderId) external view returns(Orders memory) {
    return allOrders[orderId];
  }

  function swapOrder(uint256 orderId) external {

  }

}