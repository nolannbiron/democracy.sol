const Elections = artifacts.require("./ElectionsHelper.sol");

module.exports = function(deployer) {
    deployer.deploy(Elections);
};