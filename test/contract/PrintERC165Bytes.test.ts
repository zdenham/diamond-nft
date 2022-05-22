import '@nomiclabs/hardhat-waffle';

import { ethers } from 'hardhat';

describe('Printer', async function () {
  it('Should print the stuff on deploy', async function () {
    const PrintContract = await ethers.getContractFactory('PrintERC165Bytes');

    const instance = await PrintContract.deploy();
  });
});
