// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDex {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    mapping(address => uint256) public liquidity;
    uint256 public totalLiquidity;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // AMM Math
    function _calculateAmountOut(
        uint256 rIn,
        uint256 rOut,
        uint256 amountIn
    ) private pure returns (uint256) {
        // x * y = k  →  amountOut = rOut - k / (rIn + amountIn)
        return rOut - (rIn * rOut) / (rIn + amountIn);

        /*
        Penjelasan
        1. Keadaan Awal (Sebelum Swap)
            Kita punya dua reserve di pool:

                rIn × rOut = k

            Ini adalah invariant, nilai k harus tetap sama sebelum dan sesudah swap.

        2. Setelah Swap
            Ketika seseorang memasukkan amountIn token, maka:

                Reserve In bertambah: rIn + amountIn
                Reserve Out berkurang: rOut - amountOut
                Karena k harus tetap konstan:

                (rIn + amountIn) × (rOut - amountOut) = k
        
        3. Mencari amountOut
            Kita ubah persamaan untuk mendapatkan amountOut:

                amountOut = rOut - k / (rIn + amountIn)
        
        4. Contoh Matematis
            Misal: rIn = 100, rOut = 200, amountIn = 10

            k = 100 × 200 = 20,000
            amountOut = 200 - 20,000 / (100 + 10)
                      = 200 - 20,000 / 110
                      = 200 - 181.81
                      = 18.19
        */
    }

    // Fungsi untuk mensupply likuiditas token
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 minted = amountA + amountB;
        liquidity[msg.sender] += minted;
        totalLiquidity += minted;

        reserveA += amountA;
        reserveB += amountB;
    }

    function swap(address tokenIn, uint256 amountIn) external {
        require(
            tokenIn == address(tokenA) || tokenIn == address(tokenB),
            "invalid token"
        );

        bool isAtoB = tokenIn == address(tokenA);

        (uint256 rIn, uint256 rOut) = isAtoB
            ? (reserveA, reserveB)
            : (reserveB, reserveA);

        uint256 amountOut = _calculateAmountOut(rIn, rOut, amountIn);

        if (isAtoB) {
            tokenA.transferFrom(msg.sender, address(this), amountIn);
            tokenB.transfer(msg.sender, amountOut);
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            tokenB.transferFrom(msg.sender, address(this), amountIn);
            tokenA.transfer(msg.sender, amountOut);
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }
}
