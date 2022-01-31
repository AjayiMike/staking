const stakingPool = artifacts.require("stakingPool");

module.exports = function (deployer) {
  deployer.deploy(stakingPool);
};
