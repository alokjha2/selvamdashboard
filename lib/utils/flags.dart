enum OnlineStatus {
  OFFLINE,
  ONLINE,
}

enum AccountStatus {
  INACTIVE,
  ACTIVE,
}

enum VehicleStatus {
  NOT_AVAILABLE,
  AVAILABLE,
}

enum TripStatus {
  PENDING,
  STARTED,
  COMPLETED,
}

enum SaleOrderStatus {
  PENDING,
  COMPLETED,
}

enum OrderStatus {
  PENDING,
  COMPLETED,
}

enum PaymentMode {
  CASH,
  CHEQUE,
  GPAY,
}

enum PaidTo {
  DRIVER,
  COLLECTOR,
  ADMIN,
}

enum Direction {
  UP,
  DOWN,
}

enum ShopType { PARENT, CHILD }

enum OrderBy { ADMIN, DRIVER, RETAILER }

enum OrderType { DELIVERY_SALES, DIRECT_SALES }

enum ChickenType {
  SMALL,
  REGULAR,
}

enum WeightType {
  EMPTY,
  LOAD,
}

enum DateFilter {
  TODAY,
  THIS_WEEK,
  LAST_SEVEN_DAYS,
  THIS_MONTH,
  LAST_30_DAYS,
  LAST_6_MONTHS,
  ALL,
  CUSTOM_RANGE,
}
