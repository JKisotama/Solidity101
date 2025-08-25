# Tìm hiểu sâu về UUPS Proxy Pattern

File này là ghi chú chi tiết của tôi về UUPS (Universal Upgradeable Proxy Standard), cách nó hoạt động và các chuẩn liên quan.

## UUPS là gì? (EIP-1822)

UUPS là một proxy pattern được chuẩn hóa trong **EIP-1822**. Điểm khác biệt cốt lõi của nó so với Transparent Proxy là **logic nâng cấp nằm ở implementation contract, chứ không phải ở proxy contract**.

Điều này làm cho proxy contract trở nên cực kỳ đơn giản, nhẹ và rẻ. Proxy chỉ có một nhiệm vụ duy nhất: ủy quyền (delegate) mọi cuộc gọi đến implementation contract hiện tại.

### Luồng hoạt động

1.  **Người dùng/Admin gọi Proxy:** Mọi tương tác đều bắt đầu bằng việc gọi đến địa chỉ của Proxy.
2.  **Proxy ủy quyền:** Proxy sử dụng `delegatecall` để thực thi hàm được gọi trong ngữ cảnh của chính nó, nhưng bằng code của Implementation contract.
3.  **Nâng cấp:**
    *   Admin gọi một hàm nâng cấp (ví dụ: `upgradeTo(address newImplementation)`) trên Proxy.
    *   Proxy ủy quyền cuộc gọi này đến Logic contract hiện tại.
    *   Hàm `upgradeTo` bên trong Logic contract sẽ thực hiện việc thay đổi địa chỉ implementation được lưu trong storage của Proxy.

## Vấn đề Storage và EIP-1967

Một câu hỏi quan trọng là: Proxy lưu địa chỉ của Logic contract ở đâu? Nếu lưu ở một biến state thông thường, nó có thể bị xung đột với các biến state của Logic contract (storage collision).

**EIP-1967** ra đời để giải quyết vấn đề này.

> **Ghi chú: EIP và ERC khác nhau như thế nào?**
> *   **EIP (Ethereum Improvement Proposal):** Là tên gọi chung cho *tất cả* các đề xuất cải tiến cho Ethereum, bao gồm cả những thay đổi ở tầng core protocol.
> *   **ERC (Ethereum Request for Comments):** Là một *loại* EIP cụ thể, tập trung vào các tiêu chuẩn ở tầng ứng dụng (ví dụ: ERC-20, ERC-721).
>
> Về mặt kỹ thuật, 1967 là một EIP. Tuy nhiên, vì nó định nghĩa một tiêu chuẩn cho các contract ở tầng ứng dụng, cộng đồng và các thư viện lớn như OpenZeppelin thường gọi nó là **ERC-1967** (ví dụ: file `ERC1967Proxy.sol`) cho gần gũi và dễ nhận biết. Cả hai cách gọi đều chỉ cùng một tiêu chuẩn.

EIP-1967 đề xuất các slot lưu trữ (storage slot) cụ thể, được chọn để gần như không bao giờ bị xung đột, dùng để lưu các thông tin quan trọng của proxy. Các slot quan trọng nhất là:

-   **Logic Storage Slot:** `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
    -   Đây là nơi Proxy lưu địa chỉ của Logic contract hiện tại. Hàm `upgradeTo` sẽ cập nhật giá trị ở slot này.
-   **Beacon Storage Slot:** `0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50`
    -   Dùng cho Beacon Proxy. Proxy sẽ lưu địa chỉ của Beacon contract ở slot này.
-   **Admin Storage Slot:** `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
    -   Dùng cho Transparent Proxy. Proxy lưu địa chỉ của Admin (thường là `ProxyAdmin` contract) ở slot này.

Bằng cách tuân theo EIP-1967, các công cụ như plugin của OpenZeppelin có thể tương tác với bất kỳ proxy nào tuân thủ chuẩn này một cách an toàn.

## Rủi ro lớn nhất: Mất khả năng nâng cấp

Vì logic nâng cấp nằm ở Logic contract, nếu tôi deploy một phiên bản Logic contract mới mà **quên không kế thừa các hàm nâng cấp**, contract sẽ bị "đóng băng". Sẽ không có cách nào để gọi hàm `upgradeTo` được nữa.

### Cách phòng tránh

-   **Sử dụng thư viện uy tín:** Luôn dùng các contract cơ sở từ OpenZeppelin (`UUPSUpgradeable`).
-   **Kiểm tra kỹ lưỡng:** Các công cụ như OpenZeppelin Upgrades Plugins có các bước kiểm tra an toàn. Khi deploy, nó sẽ tự động kiểm tra xem phiên bản mới có tương thích và vẫn giữ được khả năng nâng cấp hay không.
-   **Viết test cẩn thận:** Luôn có một bộ test case cho quy trình nâng cấp, đảm bảo sau khi nâng cấp, mọi thứ vẫn hoạt động và có thể tiếp tục nâng cấp trong tương lai.

## Kết luận

UUPS là một pattern mạnh mẽ và hiệu quả, giúp tiết kiệm gas và đơn giản hóa kiến trúc proxy. Tuy nhiên, nó đòi hỏi sự cẩn thận từ phía developer để tránh rủi ro mất khả năng nâng cấp. Việc hiểu rõ EIP-1822 và EIP-1967 là rất quan trọng để làm việc hiệu quả và an toàn với pattern này.
