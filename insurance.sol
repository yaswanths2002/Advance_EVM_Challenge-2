// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "./wallet.sol";
import "./collate.sol";


// Here we have created the contract named as Insurance factory 
contract InsuranceFactory {
    //Here we are mapping to store the relation b/w user address and thier wallet insurance contracts
    mapping(address => address) public userWalletInsurance;
    //Here we are mapping to store the relation b/w user address and thier collateral insurance contracts

    mapping(address => address) public userCollateralInsurance;
// Here we have declared a function to create a new wallet insurance 
    function createWalletInsurance(
        address owner,
        uint256 premiumAmt,
        uint256 payout,
        uint256 timePeried
    ) public returns (address) {
        require(
            // Check the condition that user doesn't have the wallet insurance already 
            userWalletInsurance[owner] == address(0),
            "Insurance already exists, to renew use renewWallet()"
        );
        WalletInsurance newWI = new WalletInsurance(
            owner,
            premiumAmt,
            timePeried,
            payout
        );
        userWalletInsurance[owner] = address(newWI);
        return (address(newWI));
    }

    // Here I have created a function to renew the wallet 
    function renewWallet(
        uint256 premiumAmt,
        uint256 timePeried,
        uint256 payout
    ) public returns (address) {
        WalletInsurance renewedWI = new WalletInsurance(
            msg.sender,
            premiumAmt,
            timePeried,
            payout
        );
        userWalletInsurance[msg.sender] = address(renewedWI);
        return (address(renewedWI));
    }

    // Function for claim a wallet insurance payout
    function claimWallet() public returns (bool) {
        address walletIns = userWalletInsurance[msg.sender];
        require(walletIns != address(0), "No insurance created.");
        WalletInsurance w = WalletInsurance(walletIns);
        uint256 payout = w.claim();
        require(address(this).balance >= payout, "Insufficient funds.");
        payable(msg.sender).transfer(payout);
        return true;
    }
    // Function to create a new collateral insurance contract 
    function createCollateralInsurance(
        address owner,
        uint256 premiumAmt,
        uint256 loanAmt,
        uint256 collatVal,
        uint256 insPercentage,
        uint256 collatThreshold
    ) public returns (address) {
        address collatIns = userCollateralInsurance[msg.sender];
        // Make sure that user doesn't have a colletral insurance contract before
        require(collatIns == address(0), "Insurance already created.");
        CollateralInsurance newCI = new CollateralInsurance(
            owner,
            premiumAmt,
            loanAmt,
            collatVal,
            insPercentage,
            collatThreshold
        );
        userCollateralInsurance[owner] = address(newCI);
        return (address(newCI));
    }

    // Function to claim colletaral funds from a colletaral insurance contract 
    function claimColletral(uint256 CollatValue) public returns (bool) {
        address collatIns = userCollateralInsurance[msg.sender];
        // Checks the user have a  colletaral insurrance or not 
        require(collatIns != address(0), "No insurance created.");

        CollateralInsurance c = CollateralInsurance(collatIns);
        uint256 payout = c.claimCollateralInsurance(CollatValue);
        // If the amount is not sufficient to payback it shows the error message stating insuffucient funds
        require(address(this).balance >= payout, "Insufficient funds.");
        payable(msg.sender).transfer(payout);
        return true;
    }
    // Function to get the address of the user collateral and wallet insurance contracts
    function getUserInsurance() public view returns (address, address) {
        return (
            userCollateralInsurance[msg.sender],
            userWalletInsurance[msg.sender]
        );
    }

    // Function used to fill the contract with funds
    function fillFunds() public payable returns (uint256) {
        return (address(this).balance);
    }
}
