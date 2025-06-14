# pll (module)

### Author : Foez Ahmed (foez.official@gmail.com)

## TOP IO
<img src="./pll_top.svg">

## Description
 This module implements a Phase-Locked Loop (PLL).
<br>**This file is part of squared-studio : hardware**
<br>**Copyright (c) 2025 squared-studio**
<br>**Licensed under the MIT License**
<br>**See LICENSE file in the repository root for full license information**

## Parameters
|Name|Type|Dimension|Default Value|Description|
|-|-|-|-|-|
|REF_DEV_WIDTH|int||4|Width of the reference divider register|
|FB_DIV_WIDTH|int||8|Width of the feedback divider register|

## Ports
|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|arst_ni|input|logic||Asynchronous reset, active low|
|clk_ref_i|input|logic||Reference clock input|
|refdiv_i|input|logic [REF_DEV_WIDTH-1:0]||Reference divider value|
|fbdiv_i|input|logic [ FB_DIV_WIDTH-1:0]||Feedback divider value|
|clk_o|output|logic||PLL output clock|
|locked_o|output|logic||Lock indicator output|
