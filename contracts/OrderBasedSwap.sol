// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderBasedSwap {

  uint256 counter;

  struct Orders {
    uint256 depId;
    address whoInitiatesOrder;
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
  error NoAmountDeposited();
  error InvalidOrderId();
  error TokenNotAccepted();
  error  OrderDoesNotExist();
  error NotAuthorizedToInteractWithThis();

  event OrderOpenedSuccessfully(uint256 counter, uint256 _amountDeposited);
  event OrderDisplayedSuccessfully(uint256 orderId);
  event SwapSuccessful(uint256 orderId);
  
  event TokenOrderFullyCompleted(address user, uint256 orderId);

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
    order.whoInitiatesOrder = msg.sender;
    order.tokenWanted = _tokenToBeReceived;
    order.amountWanted = _amountOfTokenToBeReceived;
    order.tokenSwapped = false;

    Orders storage orderr = allOrders[counter];
    orderr.amountDeposited = _amountDeposited;
    orderr.tokenDeposited = _tokenToBeDeposited;
    orderr.whoInitiatesOrder = msg.sender;
    orderr.tokenWanted = _tokenToBeReceived;
    orderr.amountWanted = _amountOfTokenToBeReceived;
    orderr.tokenSwapped = false;

    emit OrderOpenedSuccessfully(counter, _amountDeposited);

  }

  function displayOrderInfo(uint256 orderId) external view returns(Orders memory) {
    return allOrders[orderId];
  }

  function swapOrder(uint256 orderId) external {
    // Orders storage userOrd = usersOrders[msg.sender];
    // if(userOrd.amountDeposited == 0){
    //   revert NoAmountDeposited();
    // }
    if(msg.sender == address(0)){
      revert AddressZeroDetected();
    }
    Orders storage allOrd = allOrders[orderId];

    if(allOrd.depId != orderId){
      revert OrderDoesNotExist();
    }

    if(allOrd.amountDeposited == 0){
      revert InvalidOrderId();
    } 

    if(IERC20(msg.sender) != allOrd.tokenWanted){
      revert TokenNotAccepted();
    }
    
    if(allOrd.tokenWanted.balanceOf(msg.sender) < allOrd.amountWanted){
      revert InsufficientBalance();
    }

    allOrd.tokenWanted.transferFrom(msg.sender, address(this), allOrd.amountWanted);
    allOrd.tokenSwapped = true;

    emit SwapSuccessful(orderId);
  }

  function confirmOrderSuccess(uint256 orderId) external {
    Orders storage orderCreator = usersOrders[msg.sender];

    if(orderCreator.depId != orderId){
      revert NotAuthorizedToInteractWithThis();
    }

    if(orderCreator.amountDeposited == 0){
      revert NotAuthorizedToInteractWithThis();
    }

    orderCreator.tokenSwapped = true;

    emit TokenOrderFullyCompleted(msg.sender, orderId);
  }

  // function cancelOrder(uint256 orderId){
  //   if(allOrders[orderId]){}
  // }

}