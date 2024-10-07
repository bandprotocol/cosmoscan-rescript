module Styles = {
  open CssJs

  let tableWrapper = style(. [Media.mobile([padding2(~v=#px(16), ~h=#zero)])])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let actionContainer = (theme: Theme.t) =>
    style(. [
      display(#flex),
      justifyContent(#flexEnd),
      columnGap(#px(40)),
      paddingTop(#px(16)),
      borderTop(#px(1), #solid, theme.neutral_200),
    ])
}

module RenderBody = {
  @react.component
  let make = (
    ~delegationsSub: Sub.variant<DelegationSub.Stake.t>,
    ~templateColumns,
    ~isLoggedInAsOwner,
  ) => {
    let (_, dispatchModal) = React.useContext(ModalContext.context)
    let (accountOpt, _) = React.useContext(AccountContext.context)
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

    <TBody overflow=#visible paddingV=#px(16)>
      <TableGrid templateColumns>
        // moniker
        {switch delegationsSub {
        | Data({moniker, operatorAddress, identity}) =>
          <div className={CssHelper.flexBox()}>
            <ValidatorMonikerLink
              validatorAddress=operatorAddress
              moniker
              identity
              width={#px(300)}
              avatarWidth=30
              size=Text.Body1
            />
          </div>
        | _ => <LoadingCensorBar width=200 height=20 />
        }}
        // APR
        {switch delegationsSub {
        | Data({moniker, operatorAddress, identity}) => {
            let aprSub = AprSub.use()
            let validatorsSub = ValidatorSub.get(operatorAddress)
            let allSub = Sub.all2(aprSub, validatorsSub)

            switch allSub {
            | Data((apr, {commission})) =>
              <Text
                value={(apr *. (100. -. commission) /. 100.)->Format.fPercent} code=true size=Body1
              />
            | _ => <LoadingCensorBar width=50 height=20 />
            }
          }

        | _ => <LoadingCensorBar width=50 height=20 />
        }}
        // Delegated Amount
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch delegationsSub {
          | Data({amount}) =>
            <Text
              value={amount->Coin.getBandAmountFromCoin->Format.fPretty}
              size=Body1
              weight=Bold
              color=theme.neutral_900
              code=true
            />
          | _ => <LoadingCensorBar width=140 height=20 />
          }}
        </div>
        // Reward
        <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
          {switch delegationsSub {
          | Data({reward, operatorAddress, delegatorAddress}) =>
            <Text
              value={reward->Coin.getBandAmountFromCoin->Format.fPretty}
              code=true
              weight=Bold
              size=Body1
              color=theme.neutral_900
            />
          | _ => <LoadingCensorBar width=100 height=20 />
          }}
        </div>
        // Action Menu
        {switch delegationsSub {
        | Data({reward, operatorAddress, delegatorAddress}) if isLoggedInAsOwner =>
          <AccountActionMenu operatorAddress rewardAmount={reward.amount} />
        | _ => React.null
        }}
      </TableGrid>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~reserveIndex, ~delegationsSub: Sub.variant<DelegationSub.Stake.t>) => {
    switch delegationsSub {
    | Data({amount, moniker, operatorAddress, reward, identity}) =>
      let key_ =
        operatorAddress->Address.toHex ++
          (amount->Coin.getBandAmountFromCoin->Js.Float.toString ++
          (reward->Coin.getBandAmountFromCoin->Js.Float.toString ++
            reserveIndex->Belt.Int.toString))

      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator Name", Validator({address: operatorAddress, moniker, identity})),
            (
              "Est. APR",
              {
                switch delegationsSub {
                | Data({moniker, operatorAddress, identity}) => {
                    let aprSub = AprSub.use()
                    let validatorsSub = ValidatorSub.get(operatorAddress)
                    let allSub = Sub.all2(aprSub, validatorsSub)

                    switch allSub {
                    | Data((apr, {commission})) =>
                      Percentage(apr *. (100. -. commission) /. 100., Some(2))

                    | _ => Loading(100)
                    }
                  }

                | _ => Loading(100)
                }
              },
            ),
            ("Delegated Amount", Coin({value: list{amount}, hasDenom: false})),
            ("Reward", Coin({value: list{reward}, hasDenom: false})),
          ]
        }
        key=key_
        idx=key_
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("Validator Name", Loading(200)),
            ("Est. APR", Loading(100)),
            ("Delegated Amount", Loading(100)),
            ("Reward", Loading(100)),
          ]
        }
        key={reserveIndex->Belt.Int.toString}
        idx={reserveIndex->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~address) => {
  let isMobile = Media.isMobile()
  let (page, setPage) = React.useState(_ => 1)
  let pageSize = 5
  let delegationsCountSub = DelegationSub.getStakeCountByDelegator(address)
  let delegationsSub = DelegationSub.getStakeList(address, ~pageSize, ~page, ())

  let ({ThemeContext.theme: theme, isDarkMode}, _) = ThemeContext.use()
  let (accountOpt, _) = AccountContext.use()
  let isLoggedInAsOwner = switch accountOpt {
  | Some({address: loggedInAddress}) if Address.isEqual(address, loggedInAddress) => true
  | _ => false
  }

  let templateColumns = [#fr(1.75), #repeat(#num(3), #fr(1.)), #fr(0.25)]

  <div className=Styles.tableWrapper>
    {isMobile
      ? React.null
      : <THead>
          <TableGrid templateColumns>
            <Text block=true value="Validator Name" weight=Semibold />
            <Text block=true value="Est. APR" weight=Semibold />
            <Text block=true value="Delegated Amount (BAND)" weight=Semibold align=Right />
            <Text block=true value="Reward (BAND)" weight=Semibold align=Right />
          </TableGrid>
        </THead>}
    {switch delegationsSub {
    | Data(delegations) =>
      delegations->Belt.Array.length > 0
        ? delegations
          ->Belt.Array.mapWithIndex((i, e) =>
            isMobile
              ? <RenderBodyMobile
                  key={e.operatorAddress->Address.toBech32 ++
                  address->Address.toBech32 ++
                  i->Belt.Int.toString}
                  reserveIndex=i
                  delegationsSub={Sub.resolve(e)}
                />
              : <RenderBody
                  key={e.operatorAddress->Address.toBech32 ++
                  address->Address.toBech32 ++
                  i->Belt.Int.toString}
                  delegationsSub={Sub.resolve(e)}
                  templateColumns
                  isLoggedInAsOwner
                />
          )
          ->React.array
        : <EmptyContainer borderTop=true>
            <img
              alt="No Delegation"
              src={isDarkMode ? Images.noDataDark : Images.noDataLight}
              className=Styles.noDataImage
            />
            <Heading
              size=Heading.H4
              value="No Delegation"
              align=Heading.Center
              weight=Heading.Regular
              color={theme.neutral_600}
            />
            <Text value="Delegate BAND to start earning staking rewards." />
            <Link route=Route.ValidatorsPage className="">
              <Button px=24 py=8 fsize=14 variant=Button.Outline>
                {"See All Validators"->React.string}
              </Button>
            </Link>
          </EmptyContainer>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile key={i->Belt.Int.toString} reserveIndex=i delegationsSub=noData />
          : <RenderBody
              key={i->Belt.Int.toString} delegationsSub=noData templateColumns isLoggedInAsOwner
            />
      )
      ->React.array
    }}
    {switch (delegationsSub, accountOpt) {
    | (Data(_), Some({address: loginAddress})) if !isMobile && loginAddress == address =>
      <div className={Styles.actionContainer(theme)}>
        <Button
          px=24
          py=8
          fsize=14
          variant=Button.Text({underline: false})
          onClick={_ => {
            open Webapi.Dom
            window->Window.alert("Undelegate all")
          }}>
          {"Undelegate All"->React.string}
        </Button>
        <Button
          px=24
          py=8
          fsize=14
          variant=Button.Outline
          onClick={_ => {
            open Webapi.Dom
            window->Window.alert("Claim All Rewards")
          }}>
          {"Claim All Rewards"->React.string}
        </Button>
      </div>
    | _ => React.null
    }}
    {switch delegationsCountSub {
    | Data(delegationsCount) =>
      <Pagination
        currentPage=page
        totalElement=delegationsCount
        pageSize
        onPageChange={newPage => setPage(_ => newPage)}
        onChangeCurrentPage={newPage => setPage(_ => newPage)}
      />
    | _ => React.null
    }}
  </div>
}
