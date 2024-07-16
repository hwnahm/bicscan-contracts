// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

enum X_SECURITY_CATEGORY {
    NONE,
    BLACK_LIST,
    GRAY_LIST,
    WHITE_LIST
}

enum X_SECURITY_SUBTYPE {
    NONE,
    ETH,
    KLAY,
    POL,
    BNB,
    BSC
}

struct STIX_ADDR {
    address x_pattern_value;
    string[] labels;
    string category;
    string subType;
}

struct STIX_URL {
    string x_pattern_value;
    string[] labels;
    string category;
}

contract Uppsala {
    address public admin;

    mapping(address => STIX_ADDR) private dataAddr;
    mapping(string => STIX_URL) private dataUrl;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute");
        _;
    }

    event SetAdmin(address admin);

    constructor(address _admin){
        require(_admin != address(0), "admin should be provided");
        admin = _admin;
    }

    function setAdmin(address _newAdmin) public onlyAdmin {
        admin = _newAdmin;

        emit SetAdmin(admin);
    }

    function checkAddress(address _addr) public view returns (STIX_ADDR memory) {
        return dataAddr[_addr];
    }

    function checkUrl(string memory _url) public view returns  (STIX_URL memory) {
        return dataUrl[_url];
    }

    function setAddrData(address _addr, string[] memory _labels, string memory _category, string memory _subType) public onlyAdmin {
        require(_addr != address(0), "address should be provided");
        require(_labels.length != 0, "labels should be provided");
        require(bytes(_category).length != 0, "category should be provided");
        require(bytes(_subType).length != 0, "subType should be provided");

        dataAddr[_addr] = STIX_ADDR({x_pattern_value: _addr, labels: _labels, category: _category, subType: _subType});
    }

    function setUrlData(string memory _url, string[] memory _labels, string memory _category) public onlyAdmin {
        require(bytes(_url).length != 0, "url should be provided");
        require(_labels.length != 0, "labels should be provided");
        require(bytes(_category).length != 0, "category should be provided");

        dataUrl[_url] = STIX_URL({x_pattern_value: _url, labels: _labels, category: _category});
    }
}
