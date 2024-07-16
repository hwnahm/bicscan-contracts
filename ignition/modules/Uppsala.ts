import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import "@nomicfoundation/hardhat-ethers";
import { ethers } from "hardhat";

const UppsalaModule = buildModule("UppsalaModule",  (m) => {
    const deployer = m.getAccount(0)
    const upp = m.contract("Uppsala", [deployer]);
    return { upp };
});

export default UppsalaModule;
