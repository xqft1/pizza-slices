// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CrustOven is ReentrancyGuard {

    IERC20 public immutable pizza;
    IERC721 public immutable pizzaSlices;

    address public constant DEAD =
        0x000000000000000000000000000000000000dEaD;

    mapping(uint256 => uint8) public crustLevel;

    uint256[8] public crustCost = [
        100 ether,
        250 ether,
        500 ether,
        1000 ether,
        2500 ether,
        5000 ether,
        10000 ether,
        25000 ether
    ];

    event CrustBaked(
        address indexed user,
        uint256 indexed tokenId,
        uint8 newCrustLevel,
        uint256 burned
    );

    constructor(
        address _pizza,
        address _pizzaSlices
    ) {
        pizza = IERC20(_pizza);
        pizzaSlices = IERC721(_pizzaSlices);
    }

    function bakeCrust(
        uint256 tokenId
    ) external nonReentrant {

        require(
            pizzaSlices.ownerOf(tokenId) == msg.sender,
            "Not NFT owner"
        );

        uint8 level = crustLevel[tokenId];
        require(level < 8, "Maximum crust reached");

        uint256 cost = crustCost[level];

        require(
            pizza.transferFrom(
                msg.sender,
                DEAD,
                cost
            ),
            "PIZZA transfer failed"
        );

        crustLevel[tokenId] = level + 1;

        emit CrustBaked(
            msg.sender,
            tokenId,
            level + 1,
            cost
        );
    }
}
