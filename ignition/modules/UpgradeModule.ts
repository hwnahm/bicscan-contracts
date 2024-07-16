import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const proxyModule = buildModule("ProxyModule", (m) => {
  const proxyAdminOwner = m.getAccount(0);

  const upp = m.contract("UppsalaUpgradeable");

  const proxy = m.contract("TransparentUpgradeableProxy", [
    upp,
    proxyAdminOwner,
    "0x",
  ]);

  const proxyAdminAddress = m.readEventArgument(
    proxy,
    "AdminChanged",
    "newAdmin",
  );

  const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

  return { proxyAdmin, proxy };
});

const upgradeModule = buildModule("UpgradeModule", (m) => {
  const proxyAdminOwner = m.getAccount(0);

  const { proxyAdmin, proxy } = m.useModule(proxyModule);

  const uppV2 = m.contract("UppsalaUpgradeableV2");

  const encodedFunctionCall = m.encodeFunctionCall(uppV2, "initialize", [
    proxyAdminOwner,
  ]);

  m.call(proxyAdmin, "upgradeAndCall", [proxy, uppV2, encodedFunctionCall], {
    from: proxyAdminOwner,
  });

  return { proxyAdmin, proxy };
});

const uppV2Module = buildModule("UppV2Module", (m) => {
  const { proxy } = m.useModule(upgradeModule);

  const uppV2 = m.contractAt("UppsalaUpgradeableV2", proxy);

  return { uppV2 };
});

export default uppV2Module;
