# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts

npx hardhat deploy --network bsc_testnet --tags ProxyAdmin
npx hardhat deploy --network bsc_testnet --tags MyContract
npx hardhat verify --network bsc_testnet 0x5f8f6b1f05cACb72a2e4F579D9DF92c498670FB3
// 上边的ProxyAdmin合约和逻辑合约验证通过之后, 进入区块浏览器Proxy合约, 点击Contract选项的Is this a proxy进行保存
npx hardhat verify --network bsc_testnet 0x6Ae1Ad723ad31B31E3fF6f74052801BA55C90A80
```
