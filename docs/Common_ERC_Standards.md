# Ghi chú về các chuẩn ERC thông dụng

Đây là ghi chú nhanh của tôi về các chuẩn token phổ biến nhất trên Ethereum. Việc hiểu rõ chúng là rất quan trọng để xây dựng các ứng dụng DeFi và NFT.

## ERC-20: Fungible Tokens (Token có thể thay thế)

Đây là tiêu chuẩn nổi tiếng nhất, dùng cho các loại token có thể thay thế cho nhau, ví dụ như các đồng tiền điện tử. Một token ERC-20 bất kỳ sẽ có giá trị tương đương với một token ERC-20 khác cùng loại.

### Các tính năng chính

-   **`balanceOf(address account)`**: Trả về số dư token của một địa chỉ.
-   **`transfer(address recipient, uint256 amount)`**: Chuyển một lượng token đến một địa chỉ.
-   **`approve(address spender, uint256 amount)`**: Cho phép một địa chỉ (`spender`) được quyền rút một lượng token tối đa (`amount`) từ tài khoản của người gọi. Đây là cơ chế cốt lõi cho các dApp tương tác với token của người dùng.
-   **`transferFrom(address sender, address recipient, uint256 amount)`**: Được `spender` gọi để chuyển token từ `sender` đến `recipient`.
-   **`allowance(address owner, address spender)`**: Kiểm tra xem `spender` còn được phép rút bao nhiêu token từ `owner`.

**Ví dụ:** USDT, USDC, SHIB, UNI.

## ERC-721: Non-Fungible Tokens (NFT)

Đây là tiêu chuẩn cho các token không thể thay thế, hay còn gọi là NFT. Mỗi token là duy nhất và không thể thay thế bằng một token khác, ngay cả khi chúng thuộc cùng một contract.

### Các tính năng chính

-   **Mỗi token có một `tokenId` duy nhất.**
-   **`ownerOf(uint256 tokenId)`**: Trả về địa chỉ chủ sở hữu của một token cụ thể.
-   **`safeTransferFrom(address from, address to, uint256 tokenId)`**: Chuyển quyền sở hữu một token từ `from` sang `to`. "Safe" ở đây có nghĩa là nó sẽ kiểm tra xem địa chỉ nhận có phải là một contract có khả năng xử lý NFT hay không, để tránh làm mất token.
-   **`approve(address to, uint256 tokenId)`**: Cho phép một địa chỉ khác được quyền chuyển token này.

**Ví dụ:** CryptoPunks, Bored Ape Yacht Club, các vật phẩm trong game, vé sự kiện.

## ERC-1155: Multi-Token Standard

Đây là một tiêu chuẩn linh hoạt hơn, cho phép một contract duy nhất quản lý nhiều loại token khác nhau. Nó có thể chứa cả fungible token (như tiền trong game) và non-fungible token (như vật phẩm quý hiếm) trong cùng một nơi.

### Các tính năng chính

-   **Giao dịch hàng loạt (Batch Operations):** Cho phép chuyển nhiều loại token khác nhau trong cùng một giao dịch, giúp tiết kiệm gas đáng kể.
    -   `safeBatchTransferFrom(...)`
-   **ID đại diện cho loại token:** Thay vì mỗi NFT có một ID duy nhất, trong ERC-1155, một `id` sẽ đại diện cho một *loại* token.
-   **`balanceOf(address account, uint256 id)`**: Trả về số dư của một loại token (`id`) mà một tài khoản (`account`) đang sở hữu.
    -   Nếu token là fungible, số dư có thể > 1.
    -   Nếu token là NFT, số dư sẽ là 0 hoặc 1.
-   **`balanceOfBatch(address[] accounts, uint256[] ids)`**: Kiểm tra số dư của nhiều loại token cho nhiều tài khoản cùng lúc.

**Ví dụ:** Các game blockchain (như Enjin) sử dụng ERC-1155 để quản lý hàng ngàn loại vật phẩm khác nhau trong một contract duy nhất.

## So sánh nhanh

| Tiêu chuẩn | Loại Token | Ví dụ | Điểm mạnh |
| :--- | :--- | :--- | :--- |
| **ERC-20** | Fungible | USDC, LINK | Đơn giản, phổ biến cho tiền tệ |
| **ERC-721** | Non-Fungible | CryptoPunks | Độc nhất, phù hợp cho tài sản số |
| **ERC-1155** | Cả hai | Vật phẩm game | Hiệu quả, linh hoạt, tiết kiệm gas |
