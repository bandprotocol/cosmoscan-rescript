module Styles = {
  open CssJs

  let tabContentWrapper = style(. [marginTop(#px(20)), marginBottom(#px(40))])
  let tableHeadWrapper = (theme: Theme.t) =>
    style(. [
      marginTop(#px(16)),
      borderBottom(#px(1), #solid, theme.neutral_200),
      paddingBottom(#px(16)),
      Media.mobile([padding2(~v=#zero, ~h=#zero), borderBottom(#px(1), #solid, theme.neutral_000)]),
    ])
  let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
  let infoContainer = style(. [padding2(~v=#px(24), ~h=#px(32)), marginTop(#px(16))])

  let toggle = style(. [cursor(#pointer)])

  let tablehead = style(. [
    display(#flex),
    alignItems(#center),
    flexWrap(#wrap),
    justifyContent(#spaceBetween),
    width(#percent(100.)),
  ])

  let proposalGrid = style(. [
    selector("> div:first-child", [minWidth(#percent(8.)), textAlign(#center)]),
    selector("> div:nth-child(2)", [width(#percent(24.))]),
    selector("> div:nth-child(3)", [width(#percent(16.))]),
    selector("> div:nth-child(4)", [width(#percent(16.))]),
    selector("> div:nth-child(5)", [width(#percent(12.))]),
    selector("> div:nth-child(6)", [width(#percent(14.))]),
  ])

  let policyGrid = style(. [
    selector("> div:first-child", [minWidth(#percent(40.)), textAlign(#center)]),
    selector("> div:nth-child(2)", [width(#percent(20.))]),
    selector("> div:nth-child(3)", [width(#percent(10.))]),
    selector("> div:nth-child(4)", [width(#percent(15.))]),
    selector("> div:nth-child(5)", [width(#percent(15.))]),
  ])

  let memberGrid = style(. [
    selector("> div:first-child", [minWidth(#percent(45.)), textAlign(#center)]),
    selector("> div:nth-child(2)", [width(#percent(10.))]),
    selector("> div:nth-child(3)", [width(#percent(45.))]),
  ])

  let outer = style(. [padding2(~v=#zero, ~h=#px(32))])

  let memberHeaderMobile = (theme: Theme.t) =>
    style(. [
      marginTop(#px(24)),
      paddingBottom(#px(8)),
      borderBottom(#px(1), #solid, theme.neutral_200),
    ])

  let tableContentWrapper = style(. [
    Media.mobile([marginTop(#px(16))]),
    selector("> div:last-child", [borderBottom(#px(0), #solid, #transparent)]),
  ])

  // tableItem >>
  let tableItem = (theme: Theme.t) =>
    style(. [
      padding2(~v=px(16), ~h=#zero),
      selector("> div:first-child", [minWidth(#percent(8.)), textAlign(#center)]),
      selector("> div:nth-child(2)", [width(#percent(24.))]),
      selector("> div:nth-child(3)", [width(#percent(16.))]),
      selector("> div:nth-child(4)", [width(#percent(16.))]),
      selector("> div:nth-child(5)", [width(#percent(12.))]),
      selector("> div:nth-child(6)", [width(#percent(14.))]),
    ])

  let tableLink = (theme: Theme.t) =>
    style(. [
      cursor(pointer),
      selector("&:hover span", [color(theme.primary_800)]),
      selector("> span", [transition(~duration=200, "all")]),
    ])

  let informationContainer = style(. [padding2(~v=#px(24), ~h=#px(0))])
  let link = (theme: Theme.t) =>
    style(. [color(theme.primary_600), fontSize(#px(14)), textDecoration(#underline)])
}

module SortableTHead = {
  module Styles = {
    open CssJs

    let noDataImage = style(. [width(#auto), height(#px(70)), marginBottom(#px(16))])
    let sortableTHead = isCenter =>
      style(. [
        display(#flex),
        flexDirection(#row),
        alignItems(#center),
        cursor(#pointer),
        justifyContent(isCenter ? #center : #flexStart),
      ])
  }
  @react.component
  let make = (
    ~title,
    ~direction,
    ~toggle,
    ~value,
    ~sortedBy,
    ~isCenter=false,
    ~tooltipItem=?,
    ~tooltipPlacement=Text.AlignBottomStart,
  ) => {
    let ({ThemeContext.isDarkMode: isDarkMode, theme}, _) = React.useContext(ThemeContext.context)
    let isMobile = Media.isMobile()

    <div className={Styles.sortableTHead(isCenter)} onClick={_ => toggle(direction, value)}>
      <Text
        block=true
        value=title
        size=Text.Caption
        weight=Text.Semibold
        transform=Text.Uppercase
        tooltipItem={tooltipItem->Belt.Option.mapWithDefault(React.null, React.string)}
        tooltipPlacement
        color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
      />
      <HSpacing size=Spacing.xs />
      {isMobile
        ? React.null
        : {
            if direction == SortGroupTable.ASC {
              <Icon
                name="fas fa-caret-down"
                color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            } else if direction == SortGroupTable.DESC {
              <Icon
                name="fas fa-caret-up"
                color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            } else {
              <Icon
                name="fas fa-sort" color={sortedBy == value ? theme.neutral_900 : theme.neutral_600}
              />
            }
          }}
    </div>
  }
}

// TODO: params in mocked
module Proposal = {
  @react.component
  let make = (~proposals: array<MockGroup.group_proposal>) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    // TODO: wire up this when graphql is ready
    let (sortedBy, setSortedBy) = React.useState(_ => SortGroupProposalTable.ID)
    let (direction, setDirection) = React.useState(_ => SortGroupTable.DESC)

    let toggle = (direction, sortValue) => {
      setSortedBy(_ => sortValue)
      setDirection(_ => {
        switch direction {
        | SortGroupTable.ASC => SortGroupTable.DESC
        | SortGroupTable.DESC => SortGroupTable.ASC
        }
      })
    }

    {
      isMobile
        ? {
            proposals
            ->Belt.Array.mapWithIndex((index, proposal) =>
              <div>
                <Row marginTop={16}>
                  <Col col=Col.Twelve>
                    <TypeID.GroupProposalLink id={proposal.id}>
                      <div className={Css.merge(list{CssHelper.flexBox()})}>
                        <TypeID.GroupProposal
                          id={proposal.id} position=TypeID.Subtitle isNotLink=true weight={Semibold}
                        />
                        <HSpacing size=Spacing.sm />
                        <Heading
                          size=Heading.H4
                          value={proposal.name}
                          weight=Heading.Semibold
                          color={theme.primary_600}
                        />
                      </div>
                    </TypeID.GroupProposalLink>
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Message" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <MsgBadge name="Message" />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Policy Type" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <Text
                      value={proposal._policy_type->MockGroup.policy_type_to_string}
                      ellipsis=true
                      color={theme.neutral_900}
                      size={Body1}
                    />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Status" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <GroupProposalStatus
                      value={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED->GroupProposalStatus.parseGroupProposalStatus}
                      color={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED}
                    />
                  </Col>
                </Row>
                {index < proposals->Belt.Array.length - 1
                  ? <SeperatedLine color=theme.neutral_200 />
                  : React.null}
              </div>
            )
            ->React.array
          }
        : <div>
            {isMobile
              ? React.null
              : <div className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
                  <div className={Css.merge(list{Styles.tablehead, Styles.proposalGrid})}>
                    <div>
                      <SortableTHead
                        title="ID" direction toggle value=SortGroupProposalTable.ID sortedBy
                      />
                    </div>
                    <div>
                      <SortableTHead
                        title="Proposal Name"
                        direction
                        toggle
                        sortedBy
                        value=SortGroupProposalTable.Name
                      />
                    </div>
                    <div>
                      <SortableTHead
                        title="Message"
                        toggle
                        sortedBy
                        direction
                        value=SortGroupProposalTable.Message
                      />
                    </div>
                    <div>
                      <SortableTHead
                        title="Policy Type"
                        toggle
                        sortedBy
                        direction
                        value=SortGroupProposalTable.GroupID
                      />
                    </div>
                    <div>
                      <SortableTHead
                        title="Result"
                        toggle
                        sortedBy
                        direction
                        value=SortGroupProposalTable.GroupID
                      />
                    </div>
                    <div>
                      <SortableTHead
                        title="Status"
                        toggle
                        sortedBy
                        direction
                        value=SortGroupProposalTable.ProposalStatus
                      />
                    </div>
                  </div>
                </div>}
            {proposals
            ->Belt.Array.mapWithIndex((index, proposal) =>
              <div>
                <div
                  className={Css.merge(list{
                    "table_item",
                    CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ()),
                    Styles.tableItem(theme),
                    Styles.proposalGrid,
                  })}>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    <TypeID.GroupProposal id={proposal.id} size={Body1} weight={Bold} />
                  </div>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    <Link
                      className={Css.merge(list{Styles.tableLink(theme)})}
                      route={OracleScriptDetailsPage(1, OracleScriptRequests)}>
                      <Text
                        value={proposal.name}
                        ellipsis=true
                        color={theme.primary_600}
                        weight=Semibold
                        size={Body1}
                      />
                    </Link>
                  </div>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    {proposal.message->Belt.Array.map(msg => <MsgBadge name={msg} />)->React.array}
                  </div>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    <Text
                      value={proposal._policy_type->MockGroup.policy_type_to_string}
                      ellipsis=true
                      color={theme.neutral_600}
                      size={Body1}
                    />
                  </div>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    <Text
                      value={proposal.result} ellipsis=true color={theme.neutral_600} size={Body1}
                    />
                  </div>
                  <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                    <GroupProposalStatus
                      value={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED->GroupProposalStatus.parseGroupProposalStatus}
                      color={GroupProposalStatus.PROPOSAL_STATUS_ACCEPTED}
                    />
                  </div>
                </div>
                {index < proposals->Belt.Array.length - 1
                  ? <SeperatedLine color=theme.neutral_200 mt=0 mb=0 />
                  : React.null}
              </div>
            )
            ->React.array}
          </div>
    }
  }
}

module Policy = {
  @react.component
  let make = (~polices: array<MockGroup.group_policy>) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    // TODO: wire up this when graphql is ready
    let (sortedBy, setSortedBy) = React.useState(_ => SortGroupProposalTable.ID)
    let (direction, setDirection) = React.useState(_ => SortGroupTable.DESC)

    let toggle = (direction, sortValue) => {
      setSortedBy(_ => sortValue)
      setDirection(_ => {
        switch direction {
        | SortGroupTable.ASC => SortGroupTable.DESC
        | SortGroupTable.DESC => SortGroupTable.ASC
        }
      })
    }

    <div>
      {isMobile
        ? React.null
        : <div className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
            <div className={Css.merge(list{Styles.tablehead, Styles.policyGrid})}>
              <div>
                <SortableTHead
                  title="Policy Address" direction toggle value=SortGroupProposalTable.ID sortedBy
                />
              </div>
              <div>
                <SortableTHead
                  title="Type" direction toggle sortedBy value=SortGroupProposalTable.Name
                />
              </div>
              <div>
                <SortableTHead
                  title="Value" toggle sortedBy direction value=SortGroupProposalTable.Message
                />
              </div>
              <div>
                <SortableTHead
                  title="Voting Period"
                  toggle
                  sortedBy
                  direction
                  value=SortGroupProposalTable.GroupID
                />
              </div>
              <div>
                <SortableTHead
                  title="Min Execution Period"
                  toggle
                  sortedBy
                  direction
                  value=SortGroupProposalTable.GroupID
                />
              </div>
            </div>
          </div>}
      {polices
      ->Belt.Array.mapWithIndex((index, policy) =>
        <div>
          {isMobile
            ? <div>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Policy Address" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <AddressRender
                      address={policy.address}
                      position=AddressRender.Subtitle
                      copy=true
                      clickable=false
                      ellipsis=true
                    />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Type" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <Text
                      value={policy._type->MockGroup.policy_type_to_string}
                      ellipsis=true
                      color={theme.neutral_900}
                      size={Body1}
                    />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Value" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <Text
                      value={policy.value->Belt.Float.toString}
                      ellipsis=true
                      color={theme.neutral_900}
                      size={Body1}
                    />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Voting Period" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <Text
                      value={policy.voting_period->Belt.Int.toString}
                      ellipsis=true
                      color={theme.neutral_900}
                      size={Body1}
                    />
                  </Col>
                </Row>
                <Row marginTop={16}>
                  <Col colSm=Col.Four>
                    <Text value="Min Execution Period" size={Body1} weight={Semibold} />
                  </Col>
                  <Col colSm=Col.Eight>
                    <Text
                      value={policy.min_execution_period->Belt.Int.toString}
                      ellipsis=true
                      color={theme.neutral_900}
                      size={Body1}
                    />
                  </Col>
                </Row>
              </div>
            : <div
                className={Css.merge(list{
                  "table_item",
                  CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ()),
                  Styles.tableItem(theme),
                  Styles.policyGrid,
                })}>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <AddressRender
                    address={policy.address}
                    position=AddressRender.Subtitle
                    copy=true
                    clickable=false
                    ellipsis=true
                  />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={policy._type->MockGroup.policy_type_to_string}
                    ellipsis=true
                    color={theme.neutral_900}
                    size={Body1}
                  />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={policy.value->Belt.Float.toString}
                    ellipsis=true
                    color={theme.neutral_900}
                    size={Body1}
                  />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={policy.voting_period->Belt.Int.toString}
                    ellipsis=true
                    color={theme.neutral_900}
                    size={Body1}
                  />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={policy.min_execution_period->Belt.Int.toString}
                    ellipsis=true
                    color={theme.neutral_900}
                    size={Body1}
                  />
                </div>
              </div>}
          {index < polices->Belt.Array.length - 1
            ? <SeperatedLine color=theme.neutral_200 mt=0 mb=0 />
            : React.null}
        </div>
      )
      ->React.array}
    </div>
  }
}

module Members = {
  @react.component
  let make = (~members: array<MockGroup.group_member>) => {
    let isMobile = Media.isMobile()
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    // TODO: wire up this when graphql is ready
    let (sortedBy, setSortedBy) = React.useState(_ => SortGroupProposalTable.ID)
    let (direction, setDirection) = React.useState(_ => SortGroupTable.DESC)

    let toggle = (direction, sortValue) => {
      setSortedBy(_ => sortValue)
      setDirection(_ => {
        switch direction {
        | SortGroupTable.ASC => SortGroupTable.DESC
        | SortGroupTable.DESC => SortGroupTable.ASC
        }
      })
    }

    <div>
      {isMobile
        ? <div
            className={Css.merge(list{
              CssHelper.flexBox(~justify=#spaceBetween, ()),
              Styles.memberHeaderMobile(theme),
            })}>
            <Text value="Adress" color={theme.neutral_600} size={Body1} />
            <Text value="Weight" color={theme.neutral_600} size={Body1} />
          </div>
        : <div className={Css.merge(list{"table-wrapper", Styles.tableHeadWrapper(theme)})}>
            <div className={Css.merge(list{Styles.tablehead, Styles.memberGrid})}>
              <div>
                <SortableTHead
                  title="Address" direction toggle value=SortGroupProposalTable.ID sortedBy
                />
              </div>
              <div>
                <SortableTHead
                  title="Weight" direction toggle sortedBy value=SortGroupProposalTable.Name
                />
              </div>
              <div>
                <SortableTHead
                  title="Metadata" toggle sortedBy direction value=SortGroupProposalTable.Message
                />
              </div>
            </div>
          </div>}
      {members
      ->Belt.Array.mapWithIndex((index, member) => {
        isMobile
          ? <div>
              <Row marginTop={16}>
                <Col
                  col=Col.Twelve
                  style={Css.merge(list{CssHelper.flexBox(~justify=#spaceBetween, ())})}>
                  <AddressRender
                    address={member.address} position=AddressRender.Text ellipsis=true
                  />
                  <Text
                    value={member.weight->Belt.Int.toString} color={theme.neutral_900} size={Body1}
                  />
                </Col>
                <Col col=Col.Twelve>
                  <Text
                    value={member.metadata} ellipsis=true color={theme.neutral_900} size={Body1}
                  />
                </Col>
              </Row>
              {index < members->Belt.Array.length - 1
                ? <SeperatedLine color=theme.neutral_200 mt=0 mb=0 />
                : React.null}
            </div>
          : <div>
              <div
                className={Css.merge(list{
                  "table_item",
                  CssHelper.flexBox(~align=#center, ~justify=#spaceBetween, ()),
                  Styles.tableItem(theme),
                  Styles.memberGrid,
                })}>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <AddressRender address={member.address} position=AddressRender.Text />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={member.weight->Belt.Int.toString} color={theme.neutral_900} size={Body1}
                  />
                </div>
                <div className={Css.merge(list{"table_item--cell", CssHelper.flexBox()})}>
                  <Text
                    value={member.metadata} ellipsis=true color={theme.neutral_900} size={Body1}
                  />
                </div>
              </div>
              {index < members->Belt.Array.length - 1
                ? <SeperatedLine color=theme.neutral_200 mt=0 mb=0 />
                : React.null}
            </div>
      })
      ->React.array}
    </div>
  }
}

module Information = {
  @react.component
  let make = (~information: MockGroup.group_information) => {
    let ({ThemeContext.theme: theme, isDarkMode}, _) = React.useContext(ThemeContext.context)

    <div className={Styles.informationContainer}>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading value="Admin" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600} />
          </div>
        </Col>
        <Col col=Col.Eight>
          <AddressRender
            address={information.admin} position=AddressRender.Subtitle accountType=#validator
          />
        </Col>
      </Row>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Total Members" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <Text
            value={information.total_member->Belt.Int.toString}
            color={theme.neutral_900}
            size={Body1}
            weight={Thin}
          />
        </Col>
      </Row>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Total Members" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <Text
            value={information.total_weight->Belt.Int.toString}
            color={theme.neutral_900}
            size={Body1}
            weight={Thin}
          />
        </Col>
      </Row>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Description" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <Text value={information.description} color={theme.neutral_900} size={Body1} />
        </Col>
      </Row>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Website url" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <AbsoluteLink href=information.website className={Styles.link(theme)}>
            {information.website->React.string}
          </AbsoluteLink>
        </Col>
      </Row>
      <Row marginBottom=24 alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Forum url" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <AbsoluteLink href=information.website className={Styles.link(theme)}>
            {information.forum->React.string}
          </AbsoluteLink>
        </Col>
      </Row>
      <Row alignItems=Row.Center>
        <Col col=Col.Four mbSm=8>
          <div className={CssHelper.flexBox()}>
            <Heading
              value="Created Date" size=Heading.H4 weight=Heading.Thin color={theme.neutral_600}
            />
          </div>
        </Col>
        <Col col=Col.Eight>
          <Text
            value={information.created_date} color={theme.neutral_900} size={Body1} weight={Thin}
          />
        </Col>
      </Row>
    </div>
  }
}
