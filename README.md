# JetSwap DEX

Este proyecto implementa un **exchange descentralizado simple (AMM tipo Uniswap)** en Solidity, desplegable en cualquier red compatible con EVM.  
Incluye contratos para dos tokens ERC-20 y un contrato principal de DEX con manejo de liquidez y swaps.

---

## ✅ Funcionalidades implementadas

- **Pool de liquidez** para dos tokens ERC-20 (`TokenA` y `TokenB`).
- **Agregar y retirar liquidez**, con lógica de devolución de exceso si las proporciones no coinciden.
- **Intercambio (swap)** de tokens mediante fórmula de producto constante \(k = x \times y\) y comisión de 0.3%.
- **Token de liquidez LP (ERC-20)** emitido a los proveedores según su participación.
- **Cálculo de precio en tiempo real** para ambos tokens en la pool.
- **Eventos** para seguimiento de swaps y operaciones de liquidez.
- **Protección contra reentradas** usando OpenZeppelin `ReentrancyGuard`.
- **Mint libre** de tokens para pruebas, sin costo real.

---

## 📄 Contratos

- `AmmDex.sol`: Contrato principal del DEX (JetSwap), administra la pool, swaps, y emite LP tokens.
[deploy en sepolia](https://repo.sourcify.dev/11155111/0x60Ca8465677a398de526ecB651dc31b156954099)
- `TokenA.sol`: Token ERC-20 simple y mintable para pruebas (nombre "TokenA", símbolo "TKA").
[deploy en sepolia](https://repo.sourcify.dev/11155111/0x24def52eD41c042bac88f9cAe029F80FCe9db61D)
- `TokenB.sol`: Token ERC-20 simple y mintable para pruebas (nombre "TokenB", símbolo "TKB").
[pdeploy en sepolia](https://repo.sourcify.dev/11155111/0x5AB6079a5F885830163ecEe8f5096705748429D5)

---

## ✨ Principales funciones y eventos

### Funciones
- `addLiquidity(uint256 amountA, uint256 amountB)`: Añadir tokens a la pool.
- `removeLiquidity(uint256 shares)`: Retirar tokens y tu participación de la pool.
- `swapAforB(uint256 amountAIn)`: Intercambiar TokenA por TokenB.
- `swapBforA(uint256 amountBIn)`: Intercambiar TokenB por TokenA.
- `getPrice(address token)`: Consultar el precio actual de uno de los tokens.

### Eventos
- `LiquidityAdded(address provider, uint256 amountA, uint256 amountB, uint256 shares)`
- `LiquidityRemoved(address provider, uint256 amountA, uint256 amountB, uint256 shares)`
- `SwapAforB(address user, uint256 amountAIn, uint256 amountBOut)`
- `SwapBforA(address user, uint256 amountBIn, uint256 amountAOut)`

---

## 🔄 Lógica de funcionamiento

- **Precio y swaps:** El precio se determina con la fórmula \(k = x \times y\). Los swaps cobran una comisión del 0.3% y ajustan las reservas automáticamente.
- **LP tokens:** Al agregar liquidez, el usuario recibe tokens ERC-20 que representan su parte proporcional de la pool.
- **Mint de tokens:** Para facilitar las pruebas, cualquier usuario puede mintar tokens desde `TokenA` o `TokenB` sin restricciones.


