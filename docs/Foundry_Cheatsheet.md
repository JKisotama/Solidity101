# Foundry Cheatsheet: A Guide to Forge & Cast

This is a quick reference guide for common Foundry commands, helping you manage, test, deploy, and interact with smart contracts. The examples are based on this `Solidity_learning` project.

**Prerequisites:**
*   [Foundry](https://getfoundry.sh/) installed.
*   A private key for deploying and sending transactions (you can get one from Metamask).

---

## 1. Local Development with Anvil

Anvil is a local testnet node included with Foundry. It's perfect for quick development and testing without needing a real testnet.

### Starting Anvil
Simply run this command in your terminal. It will start a local blockchain node and provide you with 10 pre-funded accounts and their private keys.

```bash
anvil
```
Keep this terminal window open. The default RPC URL is `http://127.0.0.1:8545`.

### Using Anvil Accounts
When you start Anvil, it will list private keys. You can copy any of these to use for `--private-key` flags or set it as an environment variable.

```bash
# Copy a private key from the Anvil startup output
export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

---

## 2. Project Management (forge)

### `forge init`
Initializes a new Foundry project. This command creates the basic directory structure (`src`, `test`, `script`) and configuration files.

```bash
# Create a new directory and navigate into it
mkdir MyFoundryProject
cd MyFoundryProject

# Initialize the project
forge init
```

### `forge build`
Compiles the contracts in the `src` directory and saves the artifacts (ABI, bytecode) to the `out` directory.

```bash
forge build
```

### `forge clean`
Removes the `out` and `cache` directories to clean up old build files. Useful when you want to recompile the entire project from scratch.

```bash
forge clean
```

---

## 2. Testing (forge test)

Runs all tests in the `test` directory.

```bash
forge test
```

**Useful Options:**
*   `-vvv`: Increases the verbosity of the output (shows logs, gas used).
*   `--match-contract <TestContractName>`: Only runs tests in a specific contract.
*   `--match-test <TestFunctionName>`: Only runs a specific test function.

```bash
# Run tests with detailed output
forge test -vvv

# Only run tests for NotesFactoryTest
forge test --match-contract NotesFactoryTest

# Only run the testCreateNoteContract function
forge test --match-test testCreateNoteContract
```

---

## 3. Deployment & Interaction (forge script)

Runs script files from the `script` directory to automate deployment and contract interactions.

**Example:**
We have a `script/Deploy.s.sol` file to deploy `NotesFactory`. Make sure you have started `anvil` in another terminal.

```bash
# Run the script on your local Anvil node
# Replace ANVIL_PRIVATE_KEY with one from the `anvil` output
forge script script/Deploy.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY --broadcast
```
*   `--rpc-url`: The URL of the blockchain node (Anvil's default).
*   `--private-key`: Your private key for signing transactions (from Anvil).
*   `--broadcast`: Broadcasts the transactions to the local Anvil network.

(Note: For testnets like Sepolia, you would add `--verify` and use a real RPC URL and private key.)

**Example 2: Deploying the NotesVault**
The `DeployVault.s.sol` script is slightly more complex as it requires an environment variable.

```bash
# First, set the address you want to grant the MINTER_ROLE to
export MINTER_ADDRESS=0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

# Now, run the script
forge script script/DeployVault.s.sol:DeployVault --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY --broadcast
```

### How to Test a Deployment Script
You don't use `forge test` for deployment scripts. Instead, you run the script against a temporary Anvil instance to see if it deploys successfully. The `--fork-url` flag is used to launch a temporary, in-memory fork.

The command `forge script ... --broadcast` will return a non-zero exit code if any transaction reverts, which is how you know the test failed.

```bash
# This command tests the deployment script.
# It runs it against a temporary local fork without saving the state.
forge script script/Deploy.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```
If the command completes without errors, your deployment script works.

---

## 4. Manual Interaction (forge create & cast)

These commands are great for quick, one-off interactions without writing a full script. Make sure `anvil` is running.

### `forge create`
Deploys a contract.

```bash
# Deploy NotesFactory to your local Anvil node
forge create src/NotesFactory.sol:NotesFactory --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```
This command will output the deployed contract's address. **Save this address for the next steps!**

### `cast send`
Sends a transaction that changes the state of the blockchain (i.e., not a `view` or `pure` function).

```bash
# Let's assume our NotesFactory was deployed to 0x...123
export FACTORY_ADDRESS=0x...123

# Call the createNoteContract() function on our deployed factory
cast send $FACTORY_ADDRESS "createNoteContract()" --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```

### `cast call`
Calls a read-only function (`view` or `pure`) and returns the result without creating a transaction.

```bash
# Call the getDeployedNotes() function to see the list of created Notes contracts
cast call $FACTORY_ADDRESS "getDeployedNotes()" --rpc-url http://127.0.0.1:8545
```

This will return an array of addresses, which are the `Notes` contracts created by the factory.
