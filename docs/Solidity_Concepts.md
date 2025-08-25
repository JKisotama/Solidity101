# Ghi chú về các khái niệm Solidity quan trọng

Đây là ghi chú của tôi về các khái niệm và design pattern chính trong Solidity mà tôi đã áp dụng trong dự án này.

---

## 1. Kiểm soát truy cập với `Ownable` của OpenZeppelin

Việc kiểm soát ai được phép gọi hàm nào là cực kỳ quan trọng để bảo mật. Contract `Ownable` của OpenZeppelin cung cấp một cách đơn giản và tiết kiệm gas để triển khai cơ chế kiểm soát truy cập chỉ một chủ sở hữu (single-owner).

### Bước 1: Import và Kế thừa

Đầu tiên, import contract `Ownable.sol` và cho contract của mình kế thừa từ nó.

*Ví dụ trong `src/Note.sol`*
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Notes is Ownable {
    // ... phần còn lại của contract
}
```

### Bước 2: Thiết lập chủ sở hữu ban đầu trong constructor

Contract `Ownable` cần biết ai là chủ sở hữu ngay khi được triển khai. Ta làm điều này bằng cách gọi constructor của nó và truyền vào địa chỉ của chủ sở hữu. Thường thì đây sẽ là `msg.sender` (địa chỉ triển khai contract).

*Ví dụ trong `src/Note.sol`*
```solidity
contract Notes is Ownable {
    // ...
    constructor() Ownable(msg.sender) {}
    // ...
}
```

### Bước 3: Sử dụng modifier `onlyOwner`

Bây giờ, ta có thể bảo vệ các hàm bằng cách thêm modifier `onlyOwner`. Bất kỳ hàm nào có modifier này sẽ tự động `revert` nếu bị gọi bởi một địa chỉ không phải là chủ sở hữu hiện tại.

*Ví dụ trong `src/Note.sol`*
```solidity
contract Notes is Ownable {
    // ...
    function withdraw() external onlyOwner {
        // Code ở đây chỉ có thể được thực thi bởi owner
    }
    // ...
}
```
`Ownable` cũng cung cấp sẵn hàm `transferOwnership(address newOwner)`, và hàm này cũng được bảo vệ bởi `onlyOwner`.

### Bước 4: Test `onlyOwner` (với custom errors)

Các phiên bản mới của OpenZeppelin sử dụng custom error để tiết kiệm gas. Lỗi trả về khi một người gọi không có quyền là `OwnableUnauthorizedAccount(address account)`. Khi viết test, ta phải `expect` đúng lỗi này, chứ không phải một chuỗi string.

*Ví dụ trong `test/Note.t.sol`*
```solidity
function testWithdraw() public {
    // ...
    // Test trường hợp một non-owner không thể withdraw
    vm.startPrank(user1); // user1 không phải là owner
    
    // Expect đúng custom error, truyền vào địa chỉ của người gọi không có quyền
    vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
    
    // Thử gọi hàm được bảo vệ
    notes.withdraw();
    
    vm.stopPrank();
}
```

---

## 2. Tương tác giữa các contract qua ABI và Interface

Các contract có thể gọi hàm của nhau. Để làm điều này một cách an toàn, contract gọi cần biết **ABI** (Application Binary Interface) của contract đích. ABI định nghĩa các hàm, tham số và giá trị trả về.

Trong Solidity, cách dễ nhất để làm việc với ABI là dùng `interface`.

### Bước 1: Định nghĩa Interface

Interface giống như một bản thiết kế của contract. Nó chỉ khai báo các hàm mà ta muốn tương tác, không cần phần cài đặt logic.

*Ví dụ trong `src/NotesRegistry.sol`*
```solidity
// Interface này mô tả phần ABI của NotesFactory mà ta cần dùng.
interface INotesFactory {
    function getDeployedNotes() external view returns (address[] memory);
}
```

### Bước 2: Sử dụng Interface trong contract

Sau khi có interface, ta có thể dùng nó như một kiểu dữ liệu để tương tác với contract khác.

*Ví dụ trong `src/NotesRegistry.sol`*
```solidity
contract NotesRegistry {
    // Tạo một biến để lưu tham chiếu đến contract NotesFactory.
    INotesFactory public notesFactory;

    // Constructor nhận vào địa chỉ của một contract NotesFactory đã tồn tại.
    constructor(address _factoryAddress) {
        // Ta "ép kiểu" địa chỉ này sang kiểu interface.
        // Điều này báo cho Solidity: "Hãy xem contract ở địa chỉ này là một INotesFactory."
        notesFactory = INotesFactory(_factoryAddress);
    }

    function updateRegistry() public {
        // Giờ ta có thể gọi hàm đã định nghĩa trong interface.
        // Solidity sẽ dùng ABI để định dạng đúng lệnh gọi hàm đến contract kia.
        allNotesContracts = notesFactory.getDeployedNotes();
    }
}
```

Đây là một tính năng rất mạnh vì `NotesRegistry` không cần toàn bộ source code của `NotesFactory`, nó chỉ cần `interface` để biết *cách* giao tiếp.

---

## 3. Mẫu Contract Factory

Contract Factory là một smart contract dùng để triển khai các smart contract khác. Mẫu này hữu ích khi cần tạo nhiều phiên bản của một contract tương tự, giúp quản lý và theo dõi chúng tập trung.

### Bước 1: Tạo contract Factory

Contract factory cần biết về contract mà nó sẽ triển khai. Ta import contract cần tạo (ví dụ: `Notes`).

Phần cốt lõi của factory là hàm sử dụng từ khóa `new` để tạo một instance mới.

*Ví dụ trong `src/NotesFactory.sol`*
```solidity
import "./Note.sol";

contract NotesFactory {
    // Một mảng để theo dõi tất cả các contract được factory này triển khai
    address[] public deployedNotes;

    function createNoteContract() public {
        // Từ khóa "new" triển khai một instance mới của contract Notes.
        // Deployer của contract mới này chính là factory.
        Notes newNotesContract = new Notes();
        
        // ...
    }
}
```

### Bước 2: Chuyển quyền sở hữu (Cực kỳ quan trọng!)

Khi một contract (như `NotesFactory`) triển khai một contract khác (`Notes`), thì factory sẽ là owner của contract mới. Đây thường không phải là điều ta muốn. Người dùng *gọi* factory mới nên là owner.

Vì vậy, việc chuyển quyền sở hữu của contract mới tạo cho `msg.sender` (người dùng gọi hàm) là rất cần thiết.

*Ví dụ trong `src/NotesFactory.sol`*
```solidity
function createNoteContract() public {
    Notes newNotesContract = new Notes();

    // Chuyển quyền sở hữu từ factory cho người dùng đã gọi hàm này.
    newNotesContract.transferOwnership(msg.sender);

    // Lưu lại địa chỉ của contract mới để theo dõi.
    deployedNotes.push(address(newNotesContract));
    
    // ...
}
```

### Bước 3: Test Factory

Khi test factory, cần xác minh hai điều chính:
1.  Một contract mới đã thực sự được tạo và địa chỉ của nó được lưu lại.
2.  Quyền sở hữu của contract mới đã được chuyển đúng cho người dùng.

*Ví dụ trong `test/NotesFactory.t.sol`*
```solidity
function testCreateNoteContract() public {
    vm.startPrank(user1);
    notesFactory.createNoteContract();
    vm.stopPrank();

    // 1. Kiểm tra địa chỉ contract đã được lưu lại chưa
    address[] memory deployedNotes = notesFactory.getDeployedNotes();
    assertEq(deployedNotes.length, 1);

    // 2. Kiểm tra owner có đúng không
    // Tạo một instance của contract Notes vừa được triển khai để tương tác
    Notes notesContract = Notes(deployedNotes[0]);
    assertEq(notesContract.owner(), user1);
}
