// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface YogaLabs is IERC721A {
    function burnNft(uint256 tokenid) external;

    function claimedNft(uint256 holdid) external;
}

interface ThatsInSaint is IERC721A {
    function balanceOf(address owner)
        external
        view
        override
        returns (uint256 balance);
}

contract ProjectReincarnation is ERC721A, Ownable, ReentrancyGuard {
    string public baseURI;
    string public baseExtension = "";
    uint256 public cost = 0.0048 ether;
    uint256 public maxSupply = 4200;
    uint256 public maxMint = 3;
    bool public paused = false;
    address public YogaLabsContract =
        0x11862B3362600E99666599dce8913064feBC722C;
    address public TISContract = 0x11862B3362600E99666599dce8913064feBC722C;
    mapping(uint256 => bool) public tisFusioned;

    constructor(string memory _initBaseURI) ERC721A("ATO: Yoga Labs", "YOGA") {
        setBaseURI(_initBaseURI);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    /// @dev presale mint for whitelisted
    function mintForBurn(
        uint256 tokenId,
        uint256 holdId,
        uint256 tisToken
    ) public nonReentrant {
        require(!paused, "Contract is paused.");
        require(
            ThatsInSaint(TISContract).balanceOf(msg.sender) > 0,
            "You dont have any ThatsInSaint NFT"
        );
        require(totalSupply() + 1 <= maxSupply, "NFT sold out");
        require(
            YogaLabs(YogaLabsContract).ownerOf(tokenId) == _msgSenderERC721A(),
            "You are not the owner of token id"
        );
        require(
            YogaLabs(YogaLabsContract).ownerOf(holdId) == _msgSenderERC721A(),
            "You are not the owner of token id"
        );
        require(
            YogaLabs(YogaLabsContract).balanceOf(_msgSenderERC721A()) >= 2,
            "You need to hold at least have 2 YogaLabs NFT"
        );
        require(
            !tisFusioned[tisToken],
            "The ThatsInSaint NFT is already used for fusion"
        );

        YogaLabs(YogaLabsContract).claimedNft(holdId);
        YogaLabs(YogaLabsContract).burnNft(tokenId);
        // Mark ato that used for fusion
        tisFusioned[tisToken] = true;
        _safeMint(_msgSenderERC721A(), 1);
    }

    /// @dev use it for giveaway and team mint
    function airdrop(uint256 _mintAmount, address destination)
        public
        onlyOwner
        nonReentrant
    {
        require(
            totalSupply() + _mintAmount <= maxSupply,
            "max NFT limit exceeded"
        );

        _safeMint(destination, _mintAmount);
    }

    /// @notice returns metadata link of tokenid
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721AMetadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _toString(tokenId),
                        baseExtension
                    )
                )
                : "";
    }

    /// @notice return the number minted by an address
    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    /// @notice return the tokens owned by an address
    function tokensOfOwner(address owner)
        public
        view
        returns (uint256[] memory)
    {
        unchecked {
            uint256 tokenIdsIdx;
            address currOwnershipAddr;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            TokenOwnership memory ownership;
            for (
                uint256 i = _startTokenId();
                tokenIdsIdx != tokenIdsLength;
                ++i
            ) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
            return tokenIds;
        }
    }

    //only owner
    /// @dev change the public max per wallet
    function setMaxMint(uint256 _limit) public onlyOwner {
        maxMint = _limit;
    }

    /// @dev change the public price(amount need to be in wei)
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    /// @dev cut the supply if we dont sold out
    function setMaxsupply(uint256 _newsupply) public onlyOwner {
        maxSupply = _newsupply;
    }

    /// @dev set your baseuri
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /// @dev set baseuri extension
    function setBaseExtension(string memory _baseExtension) public onlyOwner {
        baseExtension = _baseExtension;
    }

    /// @dev set ato smart contract address
    function setATOContractAddress(address _ATOContract) public onlyOwner {
        YogaLabsContract = _ATOContract;
    }

    /// @dev to pause and unpause your contract(use booleans true or false)
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    /// @dev withdraw funds from contract
    function withdraw() public payable onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(_msgSenderERC721A()).transfer(balance);
    }
}
