// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondCloneCutFacet} from "./DiamondCloneCutFacet.sol";
import {DiamondCloneLoupeFacet} from "./DiamondCloneLoupeFacet.sol";

contract BaseDiamondCloneFacet is
    DiamondCloneCutFacet,
    DiamondCloneLoupeFacet
{}
