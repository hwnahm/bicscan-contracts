import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const proxyModule = buildModule("ProxyModule", (m) => {
  const proxyAdminOwner = m.getAccount(0);

  const upp = m.contract("UppsalaUpgradeable");

  const encodedFunctionCall = m.encodeFunctionCall(upp, "initialize", [
    proxyAdminOwner,
  ]);

  const proxy = m.contract("TransparentUpgradeableProxy", [
    upp,
    proxyAdminOwner,
    encodedFunctionCall,
  ]);

  const proxyAdminAddress = m.readEventArgument(
    proxy,
    "AdminChanged",
    "newAdmin",
  );

  const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

  return { proxyAdmin, proxy };
});

const uppModule = buildModule("UppModule", (m) => {
  const { proxy, proxyAdmin } = m.useModule(proxyModule);

  const upp = m.contractAt("UppsalaUpgradeable", proxy);

  return { upp, proxy, proxyAdmin };
});

export default uppModule;
