// SPDX-License-Identifier: MIT

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

struct SignatureExpanded {
  uint8 v;
  bytes32 r;
  bytes32 s;
}

// Returns the decimal string representation of value
function itoa(uint value) pure returns (string memory) {
  // Count the length of the decimal string representation
  uint length = 1;
  uint v = value;
  while ((v /= 10) != 0) {
    length++;
  }

  // Allocated enough bytes
  bytes memory result = new bytes(length);

  // Place each ASCII string character in the string,
  // right to left
  while (true) {
    length--;

    // The ASCII value of the modulo 10 value
    result[length] = bytes1(uint8(0x30 + (value % 10)));

    value /= 10;

    if (length == 0) {
      break;
    }
  }

  return string(result);
}

contract Uppsala {
  address public admin; // recommended a multi-sig address

  mapping(address => STIX_CRYPTO_ADDR) private dataAddr;
  mapping(string => STIX_ADDR) private dataUrl;
  mapping(address => bool) private users;

  modifier onlyAdmin() {
    require(msg.sender == admin, "Only admin can execute");
    _;
  }

  modifier onlyUsers(string calldata message, SignatureExpanded calldata sig) {
    address sender = _ecrecover(message, sig.v, sig.r, sig.s);
    require(users[sender] == true, "Only registered users can call");
    _;
  }

  event SetAdmin(address);
  event SetAddrData(address);
  event SetUrlData(string);
  event AddUser(address);

  constructor(address _admin) {
    require(_admin != address(0), "admin should be provided");
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

  function checkCryptoAddr(
    address _cryptoAddr,
    string calldata message,
    SignatureExpanded calldata sig
  ) public view onlyUsers(message, sig) returns (STIX_CRYPTO_ADDR memory) {
    return dataAddr[_cryptoAddr];
  }

  function checkAddr(
    string memory _addr,
    string calldata message,
    SignatureExpanded calldata sig
  ) public view onlyUsers(message, sig) returns (STIX_ADDR memory) {
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

  function _ecrecover(
    string memory message,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    bytes memory prefixedMessage = abi.encodePacked(
      "\x19Ethereum Signed Message:\n",
      itoa(bytes(message).length),
      message
    );

    bytes32 digest = keccak256(prefixedMessage);

    return ecrecover(digest, v, r, s);
  }

  function splitSignature(
    bytes memory sig
  ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(sig.length == 65, "invalid signature length");

    assembly {
      /*
    First 32 bytes stores the length of the signature

    add(sig, 32) = pointer of sig + 32
    effectively, skips first 32 bytes of signature

    mload(p) loads next 32 bytes starting at the memory address p into memory
    */

      // first 32 bytes, after the length prefix
      r := mload(add(sig, 32))
      // second 32 bytes
      s := mload(add(sig, 64))
      // final byte (first byte of the next 32 bytes)
      v := byte(0, mload(add(sig, 96)))
    }

    // implicitly return (r, s, v)
  }
}
