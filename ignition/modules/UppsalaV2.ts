import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import "@nomicfoundation/hardhat-ethers";
import { ethers } from "hardhat";

const UppsalaV2Module = buildModule("UppsalaV2Module",  (m) => {
  const deployer = m.getAccount(0)
  const upp = m.contract("UppsalaV2", [deployer]);
  return { upp };
});

export default UppsalaV2Module;
