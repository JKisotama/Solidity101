# Debugging with Chisel

Chisel is a powerful Solidity REPL (Read-Evaluate-Print Loop) that comes with Foundry. It allows you to quickly test snippets of Solidity code, debug transactions, or explore the state of a contract on a forked network, all from your command line.

## Starting Chisel

You can start Chisel in a simple, stateless mode or by loading the state from your project.

```bash
# Start a simple Chisel session
chisel

# Start Chisel with your project's contracts available
forge chisel
```

## Basic Usage

You can type Solidity code directly into the prompt.

```solidity
>> uint256 a = 10;
>> uint256 b = 20;
>> a + b
"30"
>> address owner = address(0x123)
"0x0000000000000000000000000000000000000123"
```

## Interacting with Contracts

When you run `forge chisel`, you can instantiate your project's contracts.

```solidity
// Assumes you have run "forge chisel"
>> import {Notes} from "src/Note.sol";
>> Notes notes = new Notes();
"Contract deployed at address 0x..."
>> notes.createNote("Hello", "Chisel")
>> notes.getNote(address(this), 0)
// This will return the Note struct you just created
```

## Debugging Example

One of Chisel's most powerful features is debugging. You can load a transaction and step through its execution.

Let's say you have a transaction hash `0x...` from a local Anvil node.

```bash
# Start chisel on a fork of your running Anvil instance
chisel --fork-url http://localhost:8545

>> !tx 0x... debug
// This will start a debugging session for that transaction,
// allowing you to inspect variables, memory, and storage at each step.
```

Chisel is a deep tool, and this is just a brief introduction. It's highly recommended for debugging complex contract interactions.
