const catchRevert = require('../helpers/exceptions.js').catchRevert;
const sampleAddress = '0x0000000000000000000000000000000000000001';
const MemberRoles = artifacts.require('MemberRoles');
const GovBlocksMaster = artifacts.require('GovBlocksMaster');
const Master = artifacts.require('Master');
const Governance = artifacts.require('Governance');
const GovernanceData = artifacts.require('GovernanceData');
const Pool = artifacts.require('Pool');
const ProposalCategory = artifacts.require('ProposalCategory');
const SimpleVoting = artifacts.require('SimpleVoting');
const EventCaller = artifacts.require('EventCaller');
const GBTStandardToken = artifacts.require('GBTStandardToken');
let gbt;
let gbm;
let ec;
let gd;
let mr;
let pc;
let sv;
let gv;
let pl;
let add = [];
let ms;

contract('Master', function([owner, notOwner]) {
  before(function() {
    Master.deployed()
      .then(function(instance) {
        ms = instance;
        return GovernanceData.deployed();
      })
      .then(function(instance) {
        gd = instance;
        return SimpleVoting.deployed();
      })
      .then(function(instance) {
        sv = instance;
        return MemberRoles.deployed();
      })
      .then(function(instance) {
        mr = instance;
        return Pool.deployed();
      })
      .then(function(instance) {
        pl = instance;
        return ProposalCategory.deployed();
      })
      .then(function(instance) {
        pc = instance;
        return Governance.deployed();
      })
      .then(function(instance) {
        gv = instance;
        return GovBlocksMaster.deployed();
      })
      .then(function(instance) {
        gbm = instance;
        return EventCaller.deployed();
      })
      .then(function(instance) {
        ec = instance;
        add.push(gd.address);
        add.push(mr.address);
        add.push(pc.address);
        add.push(sv.address);
        add.push(gv.address);
        add.push(pl.address);
        return GBTStandardToken.deployed();
      })
      .then(function(instance) {
        gbt = instance;
      });
  });

  it('Should check getters', async function() {
    this.timeout(100000);
    const g1 = await ms.versionDates(0);
    const g2 = await ms.dAppName();
    const g3 = await ms.gbmAddress();
    const g4 = await ms.getCurrentVersion();
    const g5 = await ms.getVersionData(1);
    const g8 = await ms.getGovernCheckerAddress(); // Varies based on the network
    assert.isAbove(g1.toNumber(), 1, 'Master version date not set');
    assert.equal(
      g2,
      '0x4100000000000000000000000000000000000000000000000000000000000000',
      'Master name not set'
    );
    assert.equal(g3, gbm.address, 'gbm address incorrect');
    assert.equal(g4, 1, 'Incorrect Master Version');
    assert.equal(g5[0].toNumber(), 1, 'Incorrect Master Version');
    assert.equal(
      await ms.isInternal(notOwner),
      false,
      'Internal check failing'
    );
  });

  it('Should set dAppTokenProxy', async function() {
    this.timeout(100000);
    await ms.setDAppTokenProxy(sampleAddress);
    const tp = await ms.dAppTokenProxy();
    assert.equal(tp, sampleAddress, 'Token Proxy not set');
    await catchRevert(ms.setDAppTokenProxy(sampleAddress, { from: notOwner }));
  });

  it('Should add new version', async function() {
    this.timeout(100000);
    await ms.addNewVersion(add);
    await catchRevert(ms.addNewVersion(add, { from: notOwner }));
    const g6 = await ms.getLatestAddress('MS');
    const g7 = await ms.getEventCallerAddress();
    await ms.changeMasterAddress(ms.address);
    assert.equal(g6, ms.address, 'Master address incorrect');
    assert.equal(g7, ec.address, 'EventCaller address incorrect');
    await ms.changeMasterAddress.call(owner);
    await catchRevert(ms.initMaster(owner, '0x41'));
    await catchRevert(ms.changeMasterAddress(owner, { from: notOwner }));
    await catchRevert(ms.changeGBMAddress(owner, { from: notOwner }));
  });

  it('Should not allow non-gbm address to change gbt address', async function() {
    this.timeout(100000);
    await catchRevert(ms.changeGBTSAddress(sampleAddress));
  });

  it('Should transfer assets to new pool', async function() {
    add.pop();
    const newPool = await Pool.new();
    add.push(newPool.address);
    const b = await gbt.balanceOf(pl.address);
    const b1 = await gbt.balanceOf(newPool.address);
    await ms.addNewVersion(add);
    await pl.transferAssets();
    await gbt.transfer(pl.address, 10);
    await pl.send(10);
    await pl.transferAssets();
    const b2 = await gbt.balanceOf(newPool.address);
    assert.equal(b.toNumber() + 10, b2.toNumber() - b1.toNumber());
  });

  it('Should upgrade contract', async function() {
    this.timeout(100000);
    const poo = await Pool.new();
    await ms.upgradeContract('PL', poo.address);
    assert(
      await ms.getLatestAddress('PL'),
      poo.address,
      'contract not upgraded'
    );
    await catchRevert(ms.upgradeContract('PL', owner, { from: notOwner }));
  });

  it('Should add new contract', async function() {
    this.timeout(100000);
    // Will throw once owner's permissions are removed. will need to create proposal then.
    await ms.addNewContract('QP', sampleAddress);
    assert(
      await ms.getLatestAddress('QP'),
      sampleAddress,
      'new contract not added'
    );
    await catchRevert(ms.addNewContract('yo', owner, { from: notOwner }));
  });
});
