# Tổng quan các Proxy Pattern cho Hợp đồng Nâng cấp

## Vấn đề: Tính bất biến của Smart Contract

Một khi đã deploy lên blockchain, code của smart contract sẽ không thể thay đổi. Điều này đảm bảo tính tin cậy, nhưng cũng tạo ra thách thức lớn: làm sao để sửa lỗi hay thêm tính năng mới? Các Hợp đồng có thể nâng cấp (Upgradable Contracts) ra đời để giải quyết vấn đề này.

Cơ chế nâng cấp phổ biến nhất là sử dụng **Proxy Pattern**. Ý tưởng cốt lõi là tách biệt state (dữ liệu) và logic (code) của contract.

-   **Proxy Contract:** Là contract mà người dùng tương tác trực tiếp. Nó chỉ chứa state của ứng dụng và địa chỉ của logic contract hiện tại.
-   **Logic/Implementation Contract:** Là contract chứa toàn bộ logic nghiệp vụ.

Khi người dùng gọi một hàm trên Proxy, Proxy sẽ ủy quyền (delegate) cuộc gọi đó đến Logic contract bằng `delegatecall`. Lệnh này cho phép code từ Logic contract được thực thi trong ngữ cảnh của Proxy, tức là nó sẽ thay đổi state của Proxy.

Để nâng cấp, admin chỉ cần deploy một phiên bản Logic contract mới và cập nhật địa chỉ của nó trong Proxy.

## So sánh các Proxy Pattern phổ biến

Có nhiều proxy pattern khác nhau, mỗi loại có ưu và nhược điểm riêng.

### 1. Transparent Proxy Pattern (TPP)

Đây là một trong những pattern đầu tiên và phổ biến nhất, do OpenZeppelin phát triển.

-   **Cách hoạt động:**
    -   Proxy contract chứa logic để phân biệt cuộc gọi từ admin và từ người dùng.
    -   Cuộc gọi từ admin sẽ được xử lý bởi chính Proxy (ví dụ: `upgradeTo(...)`).
    -   Cuộc gọi từ người dùng sẽ được ủy quyền đến Logic contract.
    -   Logic này nằm trong `fallback` function của Proxy.
-   **Ưu điểm:**
    -   **An toàn:** Tách biệt rõ ràng quyền quản trị và logic nghiệp vụ, ngăn chặn xung đột hàm (function clashing).
-   **Nhược điểm:**
    -   **Tốn gas:** Mỗi cuộc gọi của người dùng đều phải qua một bước kiểm tra logic trong Proxy.
    -   **Triển khai phức tạp:** Thường cần deploy thêm một contract `ProxyAdmin` riêng.

### 2. UUPS (Universal Upgradeable Proxy Standard)

UUPS là một tiêu chuẩn mới hơn (EIP-1822) nhằm tối ưu hóa chi phí và đơn giản hóa kiến trúc.

-   **Cách hoạt động:**
    -   Logic nâng cấp nằm trong chính **Logic contract**, không nằm trong Proxy.
    -   Proxy contract trở nên rất đơn giản, chỉ có nhiệm vụ ủy quyền tất cả các cuộc gọi.
-   **Ưu điểm:**
    -   **Tiết kiệm gas:** Các cuộc gọi thông thường không cần qua bước kiểm tra logic trong Proxy.
    -   **Proxy đơn giản:** Giảm thiểu bề mặt tấn công của chính Proxy.
-   **Nhược điểm:**
    -   **Rủi ro:** Nếu phiên bản Logic mới không kế thừa logic nâng cấp, contract sẽ bị "đóng băng", không thể nâng cấp được nữa.

### 3. Beacon Proxy Pattern

Pattern này được thiết kế để quản lý việc nâng cấp cho nhiều proxy contract cùng một lúc.

-   **Cách hoạt động:**
    -   Thay vì mỗi Proxy lưu địa chỉ của Logic contract, tất cả các Proxy sẽ trỏ đến một contract trung gian gọi là **Beacon**.
    -   Beacon contract sẽ lưu địa chỉ của Logic contract hiện tại.
    -   Để nâng cấp tất cả các Proxy, admin chỉ cần cập nhật địa chỉ Logic trong Beacon một lần duy nhất.
-   **Ưu điểm:**
    -   **Nâng cấp hàng loạt:** Rất hiệu quả khi có nhiều proxy contract cần dùng chung một logic.
-   **Nhược điểm:**
    -   **Thêm một lớp phức tạp:** Kiến trúc có thêm một thành phần (Beacon).

## Kết luận sơ bộ

Việc lựa chọn proxy pattern phụ thuộc vào yêu cầu cụ thể của dự án.
-   **Transparent Proxy:** An toàn, đã được kiểm chứng, nhưng tốn kém hơn.
-   **UUPS:** Hiệu quả về gas, linh hoạt, đang dần trở thành lựa chọn phổ biến cho các dApp mới.
-   **Beacon Proxy:** Lý tưởng cho các hệ thống cần nâng cấp hàng loạt.

Mỗi pattern đều có sự đánh đổi riêng, cần cân nhắc kỹ lưỡng dựa trên kiến trúc và ưu tiên của dự án.
