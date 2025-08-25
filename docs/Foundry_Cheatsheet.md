# Foundry Cheatsheet: Ghi chú lệnh Forge & Cast

 Các lệnh Foundry hay dùng, giúp quản lý, test, deploy và tương tác với smart contract. Các ví dụ đều dựa trên dự án `Solidity_learning` này.

**Cần chuẩn bị:**
*   Cài đặt [Foundry](https://getfoundry.sh/).
*   Một private key để deploy và gửi transaction (có thể lấy từ Metamask).

---

## 1. Chạy local với Anvil

Anvil là một node testnet local đi kèm với Foundry. Nó rất tiện để phát triển và test nhanh mà không cần dùng đến testnet thật.

### Khởi động Anvil
Chỉ cần chạy lệnh này trong terminal. Nó sẽ khởi động một node blockchain local và cho mình 10 tài khoản có sẵn tiền cùng private key.

```bash
anvil
```
Cứ để cửa sổ terminal này chạy. RPC URL mặc định là `http://127.0.0.1:8545`.

### Dùng tài khoản Anvil
Khi khởi động Anvil, nó sẽ liệt kê các private key. Tôi có thể copy bất kỳ key nào để dùng với cờ `--private-key` hoặc đặt làm biến môi trường cho tiện.

```bash
# Copy một private key từ output của Anvil
export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

---

## 2. Quản lý dự án (lệnh `forge`)

### `forge init`
Khởi tạo một dự án Foundry mới. Lệnh này tạo ra cấu trúc thư mục cơ bản (`src`, `test`, `script`) và các file cấu hình.

```bash
# Tạo thư mục mới rồi cd vào đó
mkdir MyFoundryProject
cd MyFoundryProject

# Khởi tạo dự án
forge init
```

### `forge build`
Biên dịch các contract trong `src` và lưu artifact (ABI, bytecode) vào thư mục `out`.

```bash
forge build
```

### `forge clean`
Xóa các thư mục `out` và `cache` để dọn dẹp các file build cũ. Hữu ích khi muốn biên dịch lại toàn bộ dự án từ đầu.

```bash
forge clean
```

---

## 2. Testing (lệnh `forge test`)

Chạy tất cả các test trong thư mục `test`.

```bash
forge test
```

**Một số tùy chọn hay dùng:**
*   `-vvv`: In ra output chi tiết hơn (hiển thị log, gas đã dùng).
*   `--match-contract <TestContractName>`: Chỉ chạy test trong một contract cụ thể.
*   `--match-test <TestFunctionName>`: Chỉ chạy một hàm test cụ thể.

```bash
# Chạy test với output chi tiết
forge test -vvv

# Chỉ chạy test cho NotesFactoryTest
forge test --match-contract NotesFactoryTest

# Chỉ chạy hàm testCreateNoteContract
forge test --match-test testCreateNoteContract
```

---

## 3. Deploy & Tương tác (lệnh `forge script`)

Chạy các file script từ thư mục `script` để tự động hóa việc deploy và tương tác với contract.

**Ví dụ:**
Mình có file `script/Deploy.s.sol` để deploy `NotesFactory`. Nhớ là phải khởi động `anvil` ở một terminal khác.

```bash
# Chạy script trên node Anvil local
# Thay ANVIL_PRIVATE_KEY bằng một key từ output của `anvil`
forge script script/Deploy.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY --broadcast
```
*   `--rpc-url`: URL của node blockchain (mặc định của Anvil).
*   `--private-key`: Private key để ký transaction (lấy từ Anvil).
*   `--broadcast`: Gửi transaction lên mạng Anvil local.

(Lưu ý: Với testnet như Sepolia, tôi sẽ thêm `--verify` và dùng RPC URL và private key thật.)

**Ví dụ 2: Deploy NotesVault**
Script `DeployVault.s.sol` phức tạp hơn một chút vì nó cần một biến môi trường.

```bash
# Đầu tiên, đặt địa chỉ muốn cấp quyền MINTER_ROLE
export MINTER_ADDRESS=0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38

# Giờ thì chạy script
forge script script/DeployVault.s.sol:DeployVault --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY --broadcast
```

### Cách test một script deploy
Không dùng `forge test` cho script deploy. Thay vào đó, tôi chạy script trên một instance Anvil tạm thời để xem nó có deploy thành công không.

Lệnh `forge script ... --broadcast` sẽ trả về exit code khác 0 nếu có transaction nào bị revert, qua đó biết được test thất bại.

```bash
# Lệnh này test script deploy.
# Nó chạy trên một fork local tạm thời mà không lưu lại state.
forge script script/Deploy.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```
Nếu lệnh chạy xong mà không có lỗi, tức là script deploy của tôi đã hoạt động.

---

## 4. Tương tác thủ công (lệnh `cast`)

Các lệnh này rất tiện cho các tương tác nhanh, đơn lẻ mà không cần viết script. Nhớ là `anvil` phải đang chạy.

### `forge create`
Deploy một contract.

```bash
# Deploy NotesFactory lên node Anvil local
forge create src/NotesFactory.sol:NotesFactory --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```
Lệnh này sẽ trả về địa chỉ của contract đã deploy. **Nhớ lưu lại địa chỉ này cho các bước sau!**

### `cast send`
Gửi một transaction làm thay đổi state (không phải hàm `view` hay `pure`).

```bash
# Giả sử NotesFactory được deploy ở địa chỉ 0x...123
export FACTORY_ADDRESS=0x...123

# Gọi hàm createNoteContract() trên factory đã deploy
cast send $FACTORY_ADDRESS "createNoteContract()" --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY
```

### `cast call`
Gọi một hàm chỉ đọc (`view` hoặc `pure`) và trả về kết quả mà không tạo transaction.

```bash
# Gọi hàm getDeployedNotes() để xem danh sách các contract Notes đã được tạo
cast call $FACTORY_ADDRESS "getDeployedNotes()" --rpc-url http://127.0.0.1:8545
```

Lệnh này sẽ trả về một mảng địa chỉ, là các contract `Notes` được tạo bởi factory.
