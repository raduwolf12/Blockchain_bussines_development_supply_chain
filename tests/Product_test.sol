// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/4_Product.sol";
contract ProductTest {

    bytes32[] proposalNames;

    ProductSC productToTest;
    function beforeAll () public {
        productToTest = new ProductSC("Token","<><>");
        productToTest.orderProduct( 12345, 12, "SUPERSTAR SKO", "adidas", "23", "800 g", "24 cm", "10 cm", "10 cm");
        // productToTest.orderProduct( 12345, 12, "SUPERSTAR SKO", "adidas", "45", "800 g", "24 cm", "10 cm", "10 cm");
    }

    function checkWinningProposal () public {
        console.log("Running check product details");

    
        string memory productName = productToTest.getProductDetails(uint256(0))[4];
        
        Assert.equal(productName , "SUPERSTAR SKO", "proposal at index 0 should be the winning proposal");
        // Assert.equal(productToTest.winnerName(), bytes32("candidate1"), "candidate1 should be the winner name");
    }

    // function checkWinninProposalWithReturnValue () public view returns (bool) {
    //     return productToTest.winningProposal() == 0;
    // }
}