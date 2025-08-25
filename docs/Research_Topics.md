# Ghi chú tìm hiểu: Hợp đồng nâng cấp & Events

Đây là ghi chú của tôi về hai chủ đề cần phải hiểu rõ hơn: Hợp đồng có thể nâng cấp và cách sử dụng Events.

---

## 1. Các mẫu Hợp đồng có thể nâng cấp

Code trên blockchain là bất biến, tức là không thể thay đổi. Đây là một vấn đề khi tôi cần sửa lỗi hoặc thêm tính năng mới. Giải pháp là sử dụng các pattern giúp tách biệt dữ liệu và logic.

Cách phổ biến nhất là dùng **Proxy Pattern**.

### Proxy hoạt động như thế nào

Ý tưởng là có hai contract:

1.  **Proxy Contract:** Đây là contract có địa chỉ cố định mà người dùng sẽ tương tác. Nó giữ toàn bộ dữ liệu (state), nhưng gần như không có logic. Nhiệm vụ duy nhất của nó là chuyển tiếp (forward) tất cả các lệnh gọi hàm đến một contract khác.
2.  **Logic (Implementation) Contract:** Contract này chứa tất cả các hàm và logic nghiệp vụ. Nó không tự giữ dữ liệu và có thể được thay thế bằng một phiên bản mới bất cứ lúc nào.

Proxy sử dụng một lệnh đặc biệt là `delegatecall`. Lệnh này thực thi code từ Logic contract, nhưng trong ngữ cảnh của Proxy, tức là nó sẽ thay đổi dữ liệu của Proxy.

### Các loại Proxy thường gặp

*   **Transparent Proxy Pattern (TPP):**
    *   **Cách hoạt động:** Proxy này khá "thông minh". Nó biết được một lệnh gọi là từ admin (để nâng cấp) hay từ người dùng thông thường (để chuyển tiếp).
    *   **Ưu điểm:** Rất an toàn và đã được kiểm chứng qua thời gian.
    *   **Nhược điểm:** Tốn gas hơn khi triển khai và hơi phức tạp một chút.

*   **UUPS (Universal Upgradeable Proxy Standard):**
    *   **Cách hoạt động:** Logic nâng cấp nằm ngay bên trong Logic contract. Proxy thì rất đơn giản, chỉ chuyển tiếp mọi thứ. Để nâng cấp, admin sẽ gọi một hàm nâng cấp trên Logic contract (thông qua proxy).
    *   **Ưu điểm:** Rẻ hơn, proxy đơn giản hơn. **Đây là pattern mà OpenZeppelin khuyến khích sử dụng hiện nay.**
    *   **Nhược điểm:** Phải cẩn thận để không quên đưa logic nâng cấp vào các phiên bản mới của logic contract.

**Kết luận:** Có lẽ tôi nên dùng **UUPS pattern** cho các dự án mới.

---

## 2. Events & Lập chỉ mục Off-chain

### Events là gì?

Events là một cách để contract của tôi ghi lại các hành động quan trọng lên blockchain. Nó là một cách lưu trữ thông tin giá rẻ để các ứng dụng bên ngoài blockchain có thể dễ dàng tìm thấy.

Dữ liệu của event được lưu ở một nơi đặc biệt gọi là "transaction logs," rẻ hơn rất nhiều so với lưu trữ trong state của contract.

*Ví dụ từ file `src/Note.sol` của tôi*
```solidity
// Tôi khai báo một event như thế này
event NoteCreated(address indexed user, uint128 indexed id, string title);

function createNote(...) public {
    // ...
    // Và tôi "phát" (emit) nó ra như thế này
    emit NoteCreated(msg.sender, id, _title);
}
```
Từ khóa `indexed` rất quan trọng. Nó giúp các ứng dụng bên ngoài tìm kiếm các event này rất nhanh.

### Tại sao tôi cần dùng Events?

Đọc dữ liệu trực tiếp từ smart contract rất chậm và không phù hợp để xây dựng một giao diện người dùng (UI) nhanh nhạy.

Cách làm tiêu chuẩn để xây dựng một dApp là:

1.  **Smart Contract:** Phát ra event cho mỗi thay đổi quan trọng.
2.  **Backend Service (Indexer):** Một ứng dụng chạy bên ngoài blockchain, chuyên lắng nghe các event từ contract.
3.  **Database:** Khi backend nhận được một event, nó sẽ lưu dữ liệu vào một database thông thường, tốc độ cao.
4.  **API:** Backend cung cấp một API nhanh để frontend có thể lấy dữ liệu từ database này.
5.  **Frontend (UI):** Ứng dụng web sẽ gọi API nhanh này để hiển thị thông tin, thay vì hỏi trực tiếp blockchain.
