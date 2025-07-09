const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("voting", function () {
  let voting, owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    const Voting = await ethers.getContractFactory("voting");
    voting = await Voting.deploy();
  });

  it("Should only allow owner to start the vote", async() =>{
      const names = ["Alice", "Bob"];
      await voting.startVote(names, 60);

      await expect(
        voting.connect(addr1).startVote(names, 60)
      ).to.be.revertedWith("Only the owner can start the voting");

    });

  it("Should initialize candidates and allow voting", async() => {
    await voting.startVote(["Alice", "Bob"], 60);

    const count = await voting.getCandidateCount();
    expect(count).to.equal(2);

    await voting.connect(addr1).vote(0);
    const [name, votes] = await voting.getCandidate(0);
    expect(name).to.equal("Alice");
    expect(votes).to.equal(1);
  });

  it("Should prevent double voting", async() =>{
    await voting.startVote(["Alice", "Bob"], 60);

    await voting.connect(addr1).vote(0);
    expect(voting.connect(addr1).vote(0)).to.be.revertedWith("You have already voted!");
  });

  it("Should prevent voting after time ends", async() => {
    await voting.startVote(["Alice", "Bob"], 60);

    await voting.connect(addr1).vote(0);

    await ethers.provider.send("evm_increaseTime",[61]);
    await ethers.provider.send("evm_mine",[]);

    await expect(voting.connect(addr2).vote(0)).to.be.revertedWith("Voting is over!");
  });

  it("Should return the correct winner", async() => {
    await voting.startVote(["Alice", "Bob"], 5);

    await voting.connect(addr1).vote(1);
    await voting.connect(addr2).vote(1);

    await ethers.provider.send("evm_increaseTime", [6]);
    await ethers.provider.send("evm_mine", []);

    const winner = await voting.getWinner();
    expect(winner).to.equal("Bob");

  });

});