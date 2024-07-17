// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

pragma solidity ^0.8.0;

    struct STIX_CRYPTO_ADDR {
        address x_pattern_value;
        string[] labels;
        string category;
        string subType;
    }

    struct STIX_ADDR {
        string x_pattern_value;
        string[] labels;
        string category;
        string subType;
    }

contract UppsalaUpgradeableV2 is Initializable, OwnableUpgradeable {
    address public admin; // recommended a multi-sig address

    mapping(address => STIX_CRYPTO_ADDR) private dataAddr;
    mapping(string => STIX_ADDR) private dataUrl;
    mapping(address => bool) private users;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute");
        _;
    }

    modifier onlyUsers() {
        require(users[msg.sender] == true, "Only registered users can call");
        _;
    }

    event SetAdmin(address);
    event SetAddrData(address);
    event SetUrlData(string);
    event AddUser(address);

    constructor() {}

    function initialize(address _admin) initializer public {
        require(_admin != address(0), "admin should be provided");
        __Ownable_init();
        admin = _admin;
    }

    function setAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;

        emit SetAdmin(admin);
    }

    function addUser(address _user) public onlyAdmin {
        users[_user] = true;

        emit AddUser(_user);
    }


    function checkCryptoAddr(address _cryptoAddr) public view returns (STIX_CRYPTO_ADDR memory) {
        return dataAddr[_cryptoAddr];
    }

    function checkAddr(string memory _addr) public view returns (STIX_ADDR memory) {
        return dataUrl[_addr];
    }

    function setCryptoAddrData(
        address _cryptoAddr,
        string[] memory _labels,
        string memory _category,
        string memory _subType
    ) public onlyAdmin {
        require(_cryptoAddr != address(0), "address should be provided");
        require(_labels.length != 0, "labels should be provided");
        require(bytes(_category).length != 0, "category should be provided");
        require(bytes(_subType).length != 0, "subType should be provided");

        dataAddr[_cryptoAddr] = STIX_CRYPTO_ADDR({
            x_pattern_value: _cryptoAddr,
            labels: _labels,
            category: _category,
            subType: _subType
        });

        emit SetAddrData(_cryptoAddr);
    }

    function setAddrData(
        string memory _addr,
        string[] memory _labels,
        string memory _category,
        string memory _subType
    ) public onlyAdmin {
        require(bytes(_addr).length != 0, "url should be provided");
        require(_labels.length != 0, "labels should be provided");
        require(bytes(_category).length != 0, "category should be provided");

        dataUrl[_addr] = STIX_ADDR({
            x_pattern_value: _addr,
            labels: _labels,
            category: _category,
            subType: _subType
        });

        emit SetUrlData(_addr);
    }
}
