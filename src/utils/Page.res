let getPageCount = (amount, limit) =>
  if mod(amount, limit) == 0 {
    amount / limit
  } else {
    amount / limit + 1
  }

let getCurrentPageRange = (currentPage, pageSize, totalElement) =>
  `${((currentPage - 1) * pageSize + 1)->Belt.Int.toString}-${(
      totalElement < pageSize
        ? totalElement
        : currentPage == pageSize
        ? totalElement
        : pageSize * currentPage
    )->Belt.Int.toString} of ${totalElement->Belt.Int.toString}`
