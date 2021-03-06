/* Copyright (C) 2017 GovBlocks.io

  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ */

pragma solidity 0.4.24;

import "./ProposalCategory.sol";


contract ProposalCategoryAdder {

    /// @dev ads the default govBlocks sub categories to dApps
    function addSubC(address _to) public { //solhint-disable-line
        ProposalCategory proposalCategory = ProposalCategory(_to);
        uint[] memory stakeInecntive = new uint[](3); 
        uint8[] memory rewardPerc = new uint8[](3);
        rewardPerc[0] = 30;
        rewardPerc[1] = 30;
        rewardPerc[2] = 40;

        proposalCategory.addInitialSubC(
            "Configure parameters",
            "QmW9zZAfeaErTNPVcNhiDNEEo4xp4avqnVbS9zez9GV3Ar",
            3,
            address(0),
            "GD",
            stakeInecntive,
            rewardPerc
        );

        stakeInecntive[0] = 10 ** 5;
        stakeInecntive[1] = 604800;
        stakeInecntive[2] = 10 ** 5;

        proposalCategory.addInitialSubC(
            "Transfer Ether",
            "QmRUmxw4xmqTN6L2bSZEJfmRcU1yvVWoiMqehKtqCMAaTa",
            4,
            address(0),
            "PL",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Transfer Token",
            "QmbvmcW3zcAnng3FWgP5bHL4ba9kMMwV9G8Y8SASqrvHHB",
            4,
            address(0),
            "PL",
            stakeInecntive,
            rewardPerc
        );

        proposalCategory.addInitialSubC(
            "Add new version",
            "QmeMBNn9fs5xYVFVsN8HgupMTfgXdyz4vkLPXakWd2BY3w",
            5,
            address(0),
            "MS",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Add new contract",
            "QmWP3P58YcmveHeXqgsBCRmDewTYV1QqeQqBmRkDujrDLR",
            5,
            address(0),
            "MS",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Add new voting type",
            "QmeWbgsSkeHUL9PWwugnvbnuvSr711CDpmkksB5dEyMFWj",
            5,
            address(0),
            "SV",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Add new authorized address",
            "QmRczxM2yN11th3MB8159rm1qAnk4VSrYYmFQCEXXRUf9Z",
            5,
            address(0),
            "SV",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Upgrade a contract",
            "QmYQXdESKMXNnWDquvH88CckH6AepjtGSUxnkyJ8D7YKpq",
            5,
            address(0),
            "MS",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Resume Proposal",
            "QmSDojLprBLDrPqF7HAaDCdi2Hy129LBwzfRMKhkt2begC",
            5,
            address(0),
            "GD",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Pause Proposal",
            "QmPh5j3aAPhC6VZ8snjwLWPtR7Ps3os8zdYERTtp5W6RAp",
            6,
            address(0),
            "GD",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Change dApp Token Proxy",
            "QmWqSFWYbmQYS9wqs7cvHXdDDGXJ8wtUv9h2w3nxbjDKUb",
            3,
            address(0),
            "MS",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "dApp Token locking support",
            "QmWfqjytQ4Qx3p4BJMbAUUMC6yQHcMqc4eMj5RaY4MbJQe",
            3,
            address(0),
            "GD",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "External Proposal",
            "", 
            7, 
            address(0), 
            "EX",
            stakeInecntive,
            rewardPerc
        );
        proposalCategory.addInitialSubC(
            "Others, not specified",
            "", 
            8, 
            address(0), 
            "EX",
            stakeInecntive,
            rewardPerc
        );
        //21 sub cat len, 20 sub cat id
    }
}