const DBlogger = artifacts.require("DBlogger.sol");

module.exports = function (deployer) {
    deployer.deploy(DBlogger);
};