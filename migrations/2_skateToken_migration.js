const SkateToken = artifacts.require("SkateToken");

module.exports = function (deployer) {
  deployer.deploy(SkateToken, 100000000000);
};
