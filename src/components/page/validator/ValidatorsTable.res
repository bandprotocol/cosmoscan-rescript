module Styles = {
  open CssJs

  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let sortableTHead = isRight =>
    style(. [
      display(#flex),
      flexDirection(#row),
      alignItems(#center),
      cursor(#pointer),
      justifyContent(isRight ? #flexEnd : #flexStart),
    ])
  let uptimeContainer = (~isLogin, ()) =>
    style(. [width(#percent(isLogin ? 100. : 60.)), marginLeft(#auto)])
  let oracleStatus = style(. [display(#flex), justifyContent(#center)])
  let logo = style(. [width(#px(20))])
}

type sort_t =
  | Rank
  | Name
  | VotingPower
  | Commission
  | APR
  | Uptime

let parseSortString = sortOption => {
  switch sortOption {
  | Rank => "Rank"
  | Name => "Name"
  | VotingPower => "Voting Power"
  | Commission => "Commission"
  | APR => "Est. APR"
  | Uptime => "Uptime"
  }
}

let compareString = (a, b) => {
  let removeEmojiRegex = %re(`/([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|[\u2011-\u26FF]|\uD83E[\uDD10-\uDDFF])/g`)
  // let removeEmojiRegex = %re("/([\u2700-\u27BF]|[\uE000-\uF8FF]|/g")
  let a_ = a->Js.String2.replaceByRe(removeEmojiRegex, "")
  let b_ = b->Js.String2.replaceByRe(removeEmojiRegex, "")
  Js.String2.localeCompare(a_, b_)->Belt.Float.toInt
}

let defaultCompare = (a: Validator.t, b: Validator.t) =>
  if a.tokens != b.tokens {
    compare(b.tokens, a.tokens)
  } else {
    compareString(a.moniker, b.moniker)
  }

let sorting = (validators: array<Validator.t>, sortedBy, sortDirection) => {
  validators
  ->Belt.List.fromArray
  ->Belt.List.sort((a, b) => {
    let result = {
      switch (sortedBy, sortDirection) {
      | (Rank, Sort.ASC) => compare(a.rank, b.rank)
      | (Rank, DESC) => compare(b.rank, a.rank)
      | (Name, ASC) => compareString(a.moniker, b.moniker)
      | (Name, DESC) => compareString(b.moniker, a.moniker)
      | (VotingPower, ASC) => compare(a.tokens, b.tokens)
      | (VotingPower, DESC) => compare(b.tokens, a.tokens)
      | (Commission, ASC) => compare(a.commission, b.commission)
      | (Commission, DESC) => compare(b.commission, a.commission)
      | (APR, ASC) => compare(a.commission, b.commission) // TODO: change to APR
      | (APR, DESC) => compare(b.commission, a.commission) // TODO: change to APR
      | (Uptime, ASC) =>
        compare(a.uptime->Belt.Option.getWithDefault(0.), b.uptime->Belt.Option.getWithDefault(0.))
      | (Uptime, DESC) =>
        compare(b.uptime->Belt.Option.getWithDefault(0.), a.uptime->Belt.Option.getWithDefault(0.))
      }
    }
    if result != 0 {
      result
    } else {
      switch (sortedBy, sortDirection) {
      | (VotingPower, Sort.ASC) => defaultCompare(b, a)
      | _ => defaultCompare(a, b)
      }
    }
  })
  ->Belt.List.toArray
}

let addUptimeOnValidators = (
  validators: array<Validator.t>,
  votesBlock: array<Validator.validator_vote_t>,
) => {
  validators->Belt.Array.map(validator => {
    let signedBlock =
      votesBlock
      ->Belt.Array.keep(({consensusAddress, voted}) =>
        Address.isEqual(validator.consensusAddress, consensusAddress) && voted == true
      )
      ->Belt.Array.get(0)
      ->Belt.Option.mapWithDefault(0, ({count}) => count)
      ->Belt.Int.toFloat

    let missedBlock =
      votesBlock
      ->Belt.Array.keep(({consensusAddress, voted}) =>
        Address.isEqual(validator.consensusAddress, consensusAddress) && voted == false
      )
      ->Belt.Array.get(0)
      ->Belt.Option.mapWithDefault(0, ({count}) => count)
      ->Belt.Int.toFloat

    {
      ...validator,
      uptime: signedBlock == 0. && missedBlock == 0.
        ? None
        : Some(signedBlock /. (signedBlock +. missedBlock) *. 100.),
    }
  })
}

module RenderBody = {
  @react.component
  let make = (
    ~rank,
    ~validatorSub: Sub.variant<Validator.t>,
    ~votingPower,
    ~dispatchModal: ModalContext.a => unit,
    ~isLogin,
    ~templateColumns,
  ) => {
    let ({ThemeContext.theme: theme}, _) = ThemeContext.use()

    <TBody paddingV=#px(16)>
      <TableGrid templateColumns>
        // rank
        {switch validatorSub {
        | Data(_) => <Text value={rank->Belt.Int.toString} block=true />
        | _ => <LoadingCensorBar width=20 height=15 />
        }}
        // moniker
        {switch validatorSub {
        | Data({operatorAddress, moniker, identity, isActive}) =>
          <ValidatorMonikerLink
            validatorAddress=operatorAddress
            moniker
            identity
            width={#px(180)}
            avatarWidth=24
            isActive
          />
        | _ => <LoadingCensorBar width=150 height=15 />
        }}
        // voting power
        {switch validatorSub {
        | Data({tokens}) =>
          <div
            className={CssHelper.flexBox(
              ~justify=#center,
              ~direction=#column,
              ~align=#flexEnd,
              (),
            )}>
            <Text
              value={votingPower->Format.fPercent(~digits=2)}
              block=true
              size=Text.Body1
              weight=Text.Bold
              color={theme.neutral_900}
              code=true
            />
            <VSpacing size=Spacing.sm />
            <Text
              value={tokens->Coin.getBandAmountFromCoin->Format.fPretty(~digits=0)}
              block=true
              code=true
            />
          </div>
        | _ =>
          <div
            className={CssHelper.flexBox(
              ~justify=#center,
              ~direction=#column,
              ~align=#flexEnd,
              (),
            )}>
            <LoadingCensorBar width=40 height=25 />
            <VSpacing size=Spacing.sm />
            <LoadingCensorBar width=80 height=15 />
          </div>
        }}
        // commission
        {switch validatorSub {
        | Data({commission}) =>
          <Text
            value={commission->Format.fPercent(~digits=2)}
            block=true
            align=Right
            code=true
            size=Body1
          />
        | _ => <LoadingCensorBar width=70 height=15 isRight=true />
        }}
        // apr
        // TODO: wire up
        <Text value="00.00%" code=true align=Right size=Body1 />
        // uptime
        {switch validatorSub {
        | Data({uptime}) =>
          switch uptime {
          | Some(uptime') =>
            <div className={Styles.uptimeContainer(~isLogin, ())}>
              <Text
                value={uptime'->Format.fPercent(~digits=uptime' == 100. ? 0 : 2)}
                code=true
                align=Right
                size=Body1
              />
              <VSpacing size=Spacing.xs />
              <ProgressBar.Uptime percent=uptime' />
            </div>
          | None => <Text value="N/A" block=true align=Right />
          }
        | _ =>
          <div>
            <LoadingCensorBar width=60 height=15 isRight=true />
            <VSpacing size=Spacing.xs />
            <LoadingCensorBar width=70 height=15 isRight=true />
          </div>
        }}
        // oracle status
        <div className=Styles.oracleStatus>
          {switch validatorSub {
          | Data({oracleStatus}) =>
            <img
              alt="Status Icon"
              src={oracleStatus ? Images.success : Images.fail}
              className=Styles.logo
            />
          | _ => <LoadingCensorBar width=20 height=20 radius=50 />
          }}
        </div>
        // delegation
        {isLogin
          ? <div className={CssHelper.flexBox(~justify=#flexEnd, ())}>
              {switch validatorSub {
              | Data({operatorAddress, commission}) =>
                let delegate = () =>
                  Some(operatorAddress)->SubmitMsg.Delegate->SubmitTx->OpenModal->dispatchModal
                <Button
                  variant=Button.Outline
                  onClick={_ => {
                    commission == 100.
                      ? {
                          open Webapi.Dom
                          window->Window.alert(
                            "Delegation to foundation validator nodes is not advised.",
                          )
                        }
                      : delegate()
                  }}>
                  {"Delegate"->React.string}
                </Button>
              | _ => <LoadingCensorBar width=90 height=33 radius=8 />
              }}
            </div>
          : React.null}
      </TableGrid>
    </TBody>
  }
}

module RenderBodyMobile = {
  @react.component
  let make = (~rank, ~validatorSub: Sub.variant<Validator.t>, ~votingPower) => {
    switch validatorSub {
    | Data({
        operatorAddress,
        moniker,
        identity,
        tokens,
        commission,
        uptime,
        oracleStatus,
        isActive,
      }) =>
      <MobileCard
        values={[
          ("", Count(rank)),
          ("", Validator({address: operatorAddress, moniker, identity, isActive})),
          ("Voting Power", InfoMobileCard.VotingPower(tokens, votingPower)),
          ("Commission", Percentage(commission, Some(2))),
          ("Est. APR", Percentage(19., Some(2))), // TODO: wire up
          ("Uptime", InfoMobileCard.Uptime(uptime)),
          ("Oracle Status", Status({status: oracleStatus})),
        ]}
        key={rank->Belt.Int.toString}
        idx={rank->Belt.Int.toString}
      />
    | _ =>
      <MobileCard
        values={
          open InfoMobileCard
          [
            ("", Loading(70)),
            ("", Loading(166)),
            ("Voting Power", Loading(166)),
            ("Commission", Loading(136)),
            ("Est. APR", Loading(136)),
            ("Uptime", Loading(200)),
            ("Oracle Status", Loading(20)),
          ]
        }
        key={rank->Belt.Int.toString}
        idx={rank->Belt.Int.toString}
      />
    }
  }
}

@react.component
let make = (~allSub, ~searchTerm, ~sortedBy, ~setSortedBy, ~direction, ~setDirection) => {
  let isMobile = Media.isMobile()
  let pageSize = 10

  let toggle = (direction, sortValue) => {
    setSortedBy(_ => sortValue)
    setDirection(_ => {
      switch direction {
      | Sort.ASC => Sort.DESC
      | DESC => ASC
      }
    })
  }

  let (accountOpt, _) = React.useContext(AccountContext.context)
  let (_, dispatchModal) = React.useContext(ModalContext.context)
  let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = ThemeContext.use()

  let isLogin = accountOpt->Belt.Option.isSome

  let templateColumns = [#fr(0.5), #fr(1.5), #repeat(#num(isLogin ? 6 : 5), #fr(1.))]

  <>
    {isMobile
      ? React.null
      : <THead height=36>
          <TableGrid templateColumns={templateColumns}>
            <SortableTHead title="Rank" direction toggle value=Rank sortedBy />
            <SortableTHead title="Validator Name" direction toggle value=Name sortedBy />
            <SortableTHead
              title="Voting Power"
              direction
              toggle
              value=VotingPower
              sortedBy
              justify=Right
              tooltipItem="Sum of self-bonded and delegated tokens"
            />
            <SortableTHead
              title="Commision"
              direction
              toggle
              value=Commission
              sortedBy
              justify=Right
              tooltipItem="Fee charged by the validator for their services, deducted from delegators' rewards."
            />
            <SortableTHead
              title="Est. APR"
              direction
              toggle
              value=APR
              sortedBy
              justify=Right
              tooltipItem="Estimated annual return on staked tokens with a validator, calculated based on rewards and commission rate"
            />
            <SortableTHead
              title="Uptime"
              direction
              toggle
              value=Uptime
              sortedBy
              justify=Right
              tooltipItem="Percentage of time the validator's node has been operational and connected to the network out of the last 100 blocks. High uptime is important for validators, as it affects the security of the blockchain network and their ability to earn rewards."
            />
            <Text
              block=true
              weight=Text.Semibold
              align=Center
              value="Oracle Status"
              tooltipItem={"The validator's Oracle status"->React.string}
            />
          </TableGrid>
        </THead>}
    {switch allSub {
    | Sub.Data(((_, _, bondedTokenCount: Coin.t, _, _), rawValidators, votesBlock)) =>
      let validators = addUptimeOnValidators(rawValidators, votesBlock)
      let filteredValidator =
        searchTerm->Js.String2.length == 0
          ? validators
          : validators->Belt.Array.keep(validator => {
              Js.String2.includes(validator.moniker->Js.String2.toLowerCase, searchTerm)
            })
      <>
        {filteredValidator->Belt.Array.length > 0
          ? filteredValidator
            ->sorting(sortedBy, direction)
            ->Belt.Array.mapWithIndex((idx, each) => {
              let votingPower = each.votingPower /. bondedTokenCount.amount *. 100.
              isMobile
                ? <RenderBodyMobile
                    key={idx->Belt.Int.toString}
                    rank={each.rank}
                    validatorSub={Sub.resolve(each)}
                    votingPower
                  />
                : <RenderBody
                    key={idx->Belt.Int.toString}
                    rank={each.rank}
                    validatorSub={Sub.resolve(each)}
                    votingPower
                    dispatchModal
                    isLogin
                    templateColumns={templateColumns}
                  />
            })
            ->React.array
          : <EmptyContainer>
              <img
                alt="No Validator"
                src={isDarkMode ? Images.noDelegatorDark : Images.noDelegatorLight}
                className=Styles.noDataImage
              />
              <Heading
                size=Heading.H4
                value="No Validator"
                align=Heading.Center
                weight=Heading.Regular
                color={theme.neutral_600}
              />
            </EmptyContainer>}
      </>
    | _ =>
      Belt.Array.make(pageSize, Sub.NoData)
      ->Belt.Array.mapWithIndex((i, noData) =>
        isMobile
          ? <RenderBodyMobile
              key={i->Belt.Int.toString} rank={i} validatorSub=noData votingPower=1.0
            />
          : <RenderBody
              key={i->Belt.Int.toString}
              rank={i}
              validatorSub=noData
              votingPower=1.0
              isLogin
              dispatchModal={_ => ()}
              templateColumns={templateColumns}
            />
      )
      ->React.array
    }}
  </>
}
