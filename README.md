# la-api-contracts

Protobuf contracts dùng chung cho các microservice của ITLACOM. Repo này là **nguồn sự thật duy nhất** cho định nghĩa gRPC API; code binding cho từng ngôn ngữ được gen ra và commit thẳng vào repo dưới `gen/<lang>/`.

## Cấu trúc

```
proto/<service>/v1/*.proto    # nguồn sự thật
gen/go/                       # Go module độc lập (đã commit)
  ├── go.mod                  # module github.com/itlacomvn/la-api-contracts/gen/go
  └── <service>/v1/*.pb.go
```

Root repo **không phải** Go module — mỗi ngôn ngữ là một module/package riêng dưới `gen/`, để sau này thêm Python/TS không ảnh hưởng lẫn nhau.

## Dùng trong service Go

```bash
go get github.com/itlacomvn/la-api-contracts/gen/go@latest
```

```go
import (
    accountv1 "github.com/itlacomvn/la-api-contracts/gen/go/account/v1"
    commonv1  "github.com/itlacomvn/la-api-contracts/gen/go/common/v1"
)

client := accountv1.NewAccountServiceClient(conn)
acc, err := client.GetAccount(ctx, &accountv1.GetAccountRequest{
    Lookup: &accountv1.GetAccountRequest_Email{Email: "a@itlacom.vn"},
})
```

Yêu cầu **Go >= 1.25** (sàn do `grpc v1.82` quy định, không phải lựa chọn của repo này).

## Services

| Package | Service |
|---|---|
| `account/v1` | `AccountService`, `OdooMappingService` |
| `employee/v1` | `EmployeeService` |
| `identity/v1` | `IdentityService` |
| `meta/v1` | `MetaService`, `AddressService` |
| `project/v1` | `ProjectService`, `PolicyService` |
| `common/v1` | types dùng chung (`UUIDList`, `PageRequest`, ...) — không có service |

## Phát triển

Cần [buf](https://buf.build/docs/installation).

```bash
make gen        # gen code tất cả ngôn ngữ + go mod tidy
make lint       # lint proto
make build      # compile thử code Go đã gen
make breaking   # kiểm tra breaking change so với main
make clean      # xoá code gen (giữ go.mod/go.sum)
```

Sửa `.proto` xong **phải chạy `make gen` và commit cả code gen** trong cùng một commit.

## Release

> [!IMPORTANT]
> Go module nằm ở thư mục con `gen/go`, nên **git tag bắt buộc có tiền tố đường dẫn**.
> Tag `v0.1.0` sẽ **không** hoạt động — và nó không báo lỗi lúc tag, chỉ vỡ ở phía service đi import.

```bash
git tag gen/go/v0.1.0
git push origin gen/go/v0.1.0
```

Go không có bước "publish" — push tag là xong, `proxy.golang.org` tự fetch khi có người `go get` lần đầu.

**Tag đã publish là bất biến.** Khi proxy đã cache, xoá tag rồi tag đè cùng tên sẽ gây lỗi checksum mismatch cho consumer. Tag sai thì bump version mới, không bao giờ tag đè.

Khi lên `v2.0.0`, module path trong `gen/go/go.mod` phải đổi thành `.../gen/go/v2` và tag là `gen/go/v2.0.0`. Trong giai đoạn `v0.x` thì còn được breaking change thoải mái.

## License

[Apache-2.0](LICENSE)
