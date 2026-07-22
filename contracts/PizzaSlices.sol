/*
                     /\
                    /  \
                   /++++\
                  /++++++\
                 /++++++++\
                /++++++++++\
               /++++++++++++\
              /++++++++++++++\
             /++++++++++++++++\
            /++++++++++++++++++\
           /++++++++++++++++++++\
          /______________________\
          \######################/
           \####################/
            \##################/
             \################/
              \##############/
               \############/
                \##########/
                 \########/
                  \######/
                   \####/
                    \##/
                     \/

        PIZZA SLICES v1.0.0
        10,000 SLICES • 200 RESERVED
        UPGRADE WITH PIZZA
        satopizza.xyz
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ILpRewardDistributor.sol";

contract PizzaSlices is ERC721A, Ownable {

    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant RESERVED_AIRDROPS = 200;
    uint256 public constant PUBLIC_SUPPLY = 9800;
    uint256 public constant MINT_PRICE = 0.005 ether;

    // SATO token
    IERC20 public constant SATO =
        IERC20(0x829f4B62EEBE12Af653b4dD4fFc480966F7d7f09);

    ILpRewardDistributor public constant lpRewards =
        ILpRewardDistributor(0x281672e42351961D80A12dEEfDC98EA0be51466A);

    uint256 public publicMinted;
    uint256 public reservedMinted;

    string public baseMetadataURI = "https://satopizza.xyz/metadata/";

    mapping(uint256 => uint8) public sliceLevel;

uint256[8] public upgradeCost = [
    uint256(10),
    50,
    150,
    500,
    1500,
    3000,
    6000,
    10000
];

event Upgrade(
    uint256 indexed tokenId,
    address indexed owner,
    uint8 newLevel,
    uint256 cost
);

event LevelUp(
    uint256 indexed tokenId,
    uint8 fromLevel,
    uint8 toLevel
);

    constructor(address initialOwner)
        ERC721A("Pizza Slices", "SLICE")
        Ownable(initialOwner)
    {}

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function mint(uint256 quantity) external payable {
        require(quantity > 0, "Invalid quantity");
        require(publicMinted + quantity <= PUBLIC_SUPPLY, "Public supply sold out");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Max supply exceeded");
        require(msg.value == quantity * MINT_PRICE, "Incorrect ETH");

        publicMinted += quantity;
        _mint(msg.sender, quantity);
    }

    function airdrop(address recipient, uint256 quantity) external onlyOwner {
        require(recipient != address(0), "Invalid recipient");
        require(quantity > 0, "Invalid quantity");
        require(reservedMinted + quantity <= RESERVED_AIRDROPS, "Reserved supply exceeded");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Max supply exceeded");

        reservedMinted += quantity;
        _mint(recipient, quantity);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");
        return string.concat(baseMetadataURI, tokenId.toString());
    }

    function upgrade(uint256 tokenId) external {
    require(ownerOf(tokenId) == msg.sender, "Not owner");

    uint8 level = sliceLevel[tokenId];
    require(level < 8, "Already GOLDEN");

    uint256 cost = upgradeCost[level];

    require(
        SATO.transferFrom(
            msg.sender,
            address(lpRewards),
            cost
        ),
        "SATO transfer failed"
    );

    lpRewards.notifyRewardAmount(cost);

    sliceLevel[tokenId] = level + 1;

    emit Upgrade(tokenId, msg.sender, level + 1, cost);
    emit LevelUp(tokenId, level, level + 1);
}

    function setBaseMetadataURI(string calldata newBaseMetadataURI)
        external
        onlyOwner
    {
        baseMetadataURI = newBaseMetadataURI;
    }
}