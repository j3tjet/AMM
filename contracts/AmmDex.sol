// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleDEX is ERC20, ReentrancyGuard  {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 shares);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 shares);
    event SwapAforB(address indexed user,uint256 amountAIn,uint256 amountBOut);
    event SwapBforA(address indexed user,uint256 amountBIn,uint256 amountAOut);


    constructor(string memory _name,string memory _simbol, address _tokenA, address _tokenB) ERC20(_name,_simbol){
        tokenA=IERC20(_tokenA);
        tokenB=IERC20(_tokenB);
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant returns (uint256 shares){
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 auxA = amountA;
        uint256 auxB = amountB;

        if (totalSupply() == 0) {
            shares = _sqrt(amountA * amountB);
        } else {
            

            
            uint256 optimalAmountB= (amountA*reserveB)/reserveA;
            // if user send much tokenB
            if(amountB>=optimalAmountB){
                uint256 excessB=amountB-optimalAmountB;
                
                if (excessB > 0) tokenB.transfer(msg.sender, excessB); // Devolver exceso
                auxB=optimalAmountB;


            }else{
                uint256 optimalAmountA=(amountB*reserveA)/reserveB;
                uint256 excessA=amountA-optimalAmountA;
                if (excessA > 0) tokenA.transfer(msg.sender, excessA); // Devolver exceso
                auxA=optimalAmountA;
            }


            shares = _min(
                (auxA * totalSupply()) / reserveA,
                (auxB * totalSupply()) / reserveB
            );
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(
            tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this))
        );
        emit LiquidityAdded(msg.sender, auxA, auxB, shares);


    }
    function swapAforB(uint256 amountAIn)external nonReentrant 
        returns (uint256 amountOut){
        require(amountAIn > 0,"El monto debe ser mayor a 0");

        tokenA.transferFrom(msg.sender,address(this),amountAIn);
        
        uint256 amountInWithFee = (amountAIn * 997) / 1000;
        amountOut =(reserveB * amountInWithFee) / (reserveA + amountInWithFee);
        require(amountOut <= reserveB);

        tokenB.transfer(msg.sender, amountOut);

        _update(
            tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this))
        );
        emit SwapAforB(msg.sender, amountAIn, amountOut);

    }
    function swapBforA(uint256 amountBIn)external nonReentrant 
        returns (uint256 amountOut){
        require(amountBIn > 0,"El monto debe ser mayor a 0");

        tokenB.transferFrom(msg.sender,address(this),amountBIn);
        
        uint256 amountInWithFee = (amountBIn * 997) / 1000;
        amountOut =(reserveA * amountInWithFee) / (reserveB + amountInWithFee);
        require(amountOut <= reserveA);

        tokenA.transfer(msg.sender, amountOut);

        _update(
            tokenA.balanceOf(address(this)), tokenB.balanceOf(address(this))
        );
        emit SwapBforA(msg.sender, amountBIn, amountOut);


    }
    function removeLiquidity(uint256 _shares) external  nonReentrant returns (uint256 amountA,uint256 amountB){
        uint256 bal0 = tokenA.balanceOf(address(this));
        uint256 bal1 = tokenB.balanceOf(address(this));

        amountA = (_shares * bal0) / totalSupply();
        amountB = (_shares * bal1) / totalSupply();
        require(amountA > 0 && amountB > 0, "amountA or amountB = 0");        

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        _burn(msg.sender, _shares);
        _update(bal0 - amountA, bal1 - amountB);
        
        emit LiquidityRemoved(msg.sender, amountA, amountB, _shares);
    }
    function getPrice(address _token)external view returns (uint256 price){
        require(
            _token == address(tokenA) || _token == address(tokenB),
            "invalid token"
        );
        require(reserveA>0 && reserveB>0, "pool without tokens");

        if (_token == address(tokenA)) {
            return (reserveB * 1e18) / reserveA;
        } else{
               
            return (reserveA * 1e18) / reserveB;
        }


    }

    function _update(uint256 _reserveA, uint256 _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}