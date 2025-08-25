# Debug với Chisel

Chisel là một REPL (Read-Evaluate-Print Loop) cho Solidity, đi kèm với Foundry. Nó khá mạnh, cho phép tôi test nhanh các đoạn code Solidity, debug transaction, hay xem state của contract trên một mạng forked, tất cả ngay trên command line.

## Khởi động Chisel

Tôi có thể bắt đầu Chisel ở chế độ đơn giản, không state, hoặc load state từ dự án của mình.

```bash
# Bắt đầu một session Chisel đơn giản
chisel

# Bắt đầu Chisel với các contract của dự án có sẵn
forge chisel
```

## Sử dụng cơ bản

Có thể gõ code Solidity trực tiếp vào.

```solidity
>> uint256 a = 10;
>> uint256 b = 20;
>> a + b
"30"
>> address owner = address(0x123)
"0x0000000000000000000000000000000000000123"
```

## Tương tác với Contract

Khi chạy `forge chisel`, tôi có thể tạo instance của các contract trong dự án.

```solidity
// Giả sử đã chạy "forge chisel"
>> import {Notes} from "src/Note.sol";
>> Notes notes = new Notes();
"Contract deployed at address 0x..."
>> notes.createNote("Hello", "Chisel")
>> notes.getNote(address(this), 0)
// Lệnh này sẽ trả về struct Note vừa tạo
```

## Ví dụ Debug

Một trong những tính năng mạnh nhất của Chisel là debug. Tôi có thể load một transaction và đi qua từng bước thực thi của nó.

Giả sử tôi có một transaction hash `0x...` từ node Anvil local.

```bash
# Bắt đầu chisel trên một fork của instance Anvil đang chạy
chisel --fork-url http://localhost:8545

>> !tx 0x... debug
// Lệnh này sẽ bắt đầu một phiên debug cho transaction đó,
// cho phép tôi kiểm tra các biến, memory, và storage ở mỗi bước.
```

Chisel là một công cụ rất hay, và đây chỉ là giới thiệu sơ qua. Rất nên dùng nó để debug các tương tác contract phức tạp.
