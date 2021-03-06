const MemberRoles = artifacts.require('MemberRoles');
const GovBlocksMaster = artifacts.require('GovBlocksMaster');
const Master = artifacts.require('Master');
const GBTStandardToken = artifacts.require('GBTStandardToken');
const Governance = artifacts.require('Governance');
const GovernanceData = artifacts.require('GovernanceData');
const Pool = artifacts.require('Pool');
const catchRevert = require('../helpers/exceptions.js').catchRevert;
const ProposalCategory = artifacts.require('ProposalCategory');
const SimpleVoting = artifacts.require('SimpleVoting');
const EventCaller = artifacts.require('EventCaller');
const TokenProxy = artifacts.require('TokenProxy');
let gbts;
let gbm;
let ec;
let gd;
let mr;
let pc;
let sv;
let gv;
let pl;
let tp;
let add = [];
let ms;
const json = require('./../build/contracts/Master.json');
const bytecode = json.bytecode;

contract('Deploy new dApp', ([owner, notOwner]) => {
  it('should create a new dApp', async function() {
    this.timeout(100000);
    gbm = await GovBlocksMaster.new();
    gbts = await GBTStandardToken.new();
    ec = await EventCaller.new();
    tp = await TokenProxy.new(gbts.address);
    await gbm.govBlocksMasterInit(gbts.address, ec.address);
    await gbm.setMasterByteCode(bytecode);
    await gbm.addGovBlocksUser('0x42', gbts.address, tp.address, 'descHash');
    gd = await GovernanceData.new(false);
    mr = await MemberRoles.new();
    pc = await ProposalCategory.new();
    sv = await SimpleVoting.new();
    gv = await Governance.new();
    pl = await Pool.new();
    const owner = await gbm.owner();
    await mr.memberRolesInitiate('0x42', gbts.address, owner);
    await pc.proposalCategoryInitiate('0x42');
    add.push(gd.address);
    add.push(mr.address);
    add.push(pc.address);
    add.push(sv.address);
    add.push(gv.address);
    add.push(pl.address);
    const mad = await gbm.getDappMasterAddress('0x42');
    ms = await Master.at(mad);
    await catchRevert(ms.addNewVersion(add, { from: notOwner }));
    const receipt = await ms.addNewVersion(add);
    //console.log('GasUsed: ', receipt.receipt.gasUsed);
    const cv = await ms.getCurrentVersion();
    assert.equal(cv.toNumber(), 1, 'dApp version not created');
  });
});
