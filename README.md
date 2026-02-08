# Solidity Smart Contract for Two-Party Betting

This project implements a **simple, time-bounded betting smart contract** between **two predefined participants**, managed by an **admin**. The contract is designed to be **deterministic, transparent, and resistant to common malicious behaviors** from either the bettors or the admin.

---

## Overview

* The contract supports **exactly two bettors**
* Each bettor must stake the **same fixed amount**
* The **winner receives the full pot**
* Time limits prevent funds from being locked indefinitely
* Fallback mechanisms protect bettors from admin inaction

Once the contract is deployed, **all parameters are immutable**, ensuring that both bettors fully agree on the rules before participating.

---

## Roles

### Admin

* Deploys the contract
* Declares the winner and pays out the bet
* Cannot change contract parameters after deployment

### Bettors

* Two predefined Ethereum addresses
* Can enter the bet once
* Can trigger refund mechanisms if time constraints are violated

---

## Contract Parameters (Constructor)

All parameters are set at deployment time and **cannot be modified later**:

| Parameter            | Description                                           |
| -------------------- | ----------------------------------------------------- |
| `bettor1`, `bettor2` | Addresses allowed to participate in the bet           |
| `minCoinsBet`        | **Exact amount** of ETH each bettor must send         |
| `bettingTimeLimit`   | Time window (seconds) to place bets after deployment  |
| `bettingTimeToPay`   | Time window (seconds) for the admin to pay the winner |

⚠️ `bettingTimeLimit` must be strictly smaller than `bettingTimeToPay`.

---

## Core Functions

### `enterBet()`

Allows a bettor to participate in the bet.

**Rules:**

* Only callable by one of the two bettors
* Must be called before `bettingTimeLimit`
* Must send **exactly `minCoinsBet`**
* Each bettor can only enter **once**

If both bettors enter successfully, the contract holds the full pot.

---

### `payToWinner(address winner)`

Pays the entire balance to the declared winner.

**Rules:**

* Only callable by the admin
* Must be called before `bettingTimeToPay`
* Both bettors must have entered
* Winner must be one of the two bettors
* Can only be executed **once**

After execution, the contract is permanently finalized.

---

## Safety & Anti-Malicious Mechanisms

### `cancelBetBecauseNoOtherBettorOnTime()`

Allows a bettor to recover their funds if the other bettor fails to enter in time.

**Conditions:**

* `bettingTimeLimit` has passed
* Exactly one bettor has entered

**Result:**

* The bettor who entered gets their full stake back
* Contract is finalized

---

### `cancelBetBecauseAdminNotPayedToWinnerOnTime()`

Protects bettors from admin inactivity.

**Conditions:**

* `bettingTimeToPay` has passed
* Both bettors have entered

**Result:**

* Contract balance is split evenly between both bettors
* Contract is finalized

---

## Security Features

* ✅ Exact bet amount enforced
* ✅ One-time participation per bettor
* ✅ Time-bounded actions
* ✅ Single final payout (no double withdrawals)
* ✅ Clear contract finalization state
* ✅ No reliance on mutable state after payout

---

## Limitations

* The admin is trusted to **correctly choose the winner**
* No oracle or on-chain dispute resolution
* Fixed bet amount (no variable stakes)
* Only supports two participants

---

## Possible Extensions

* Trustless winner selection via oracle
* Commit-reveal betting outcomes
* Support for variable bet sizes
* Event emission for frontend indexing
* Reentrancy-safe `call` payouts
* Multi-party betting
