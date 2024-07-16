// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

enum X_SECURITY_CATEGORY {
  NONE,
  BLACK_LIST,
  GRAY_LIST,
  WHITE_LIST
}

enum CRYPTO_ADDR_SUBTYPE {
  NONE,
  ETH,
  ETC,
  EOS,
  BTC,
  BCH,
  ALGO,
  LTC,
  DASH,
  ZEC,
  XMR,
  NEO,
  XRP,
  NA,
  KLAY,
  TRON,
  XLM,
  BNB,
  ADA,
  DOGE,
  BSC,
  SOL,
  POL,
  FTM,
  LUNC,
  AVAX,
  ARB,
  OP
}

enum ADDR_SUBTYPE {
  NONE,
  URL,
  EMAIL,
  DOMAIN,
  HOSTNAME,
  IPV4,
  OTHER
}

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

contract Uppsala {
  address public admin;

  mapping(address => STIX_CRYPTO_ADDR) private dataAddr;
  mapping(string => STIX_ADDR) private dataUrl;

  modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can execute");
    _;
  }

  event SetAdmin(address);
  event SetAddrData(address);
  event SetUrlData(string);

  constructor(address _admin) {
    require(_admin != address(0), "admin should be provided");
    admin = _admin;
  }

  function setAdmin(address _newAdmin) public onlyAdmin {
    admin = _newAdmin;

    emit SetAdmin(admin);
  }

  function checCryptokAddr(address _cryptoAddr) public view returns (STIX_CRYPTO_ADDR memory) {
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
