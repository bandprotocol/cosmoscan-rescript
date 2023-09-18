@react.component
let make = (~hashtag: Route.group_tab_t) => {
  <Tab.Route
    tabs=[
      {name: "Group", route: Route.GroupPage(Group)},
      {name: "Proposal", route: Route.GroupPage(Proposal)},
    ]
    currentRoute={Route.GroupPage(hashtag)}>
    {switch hashtag {
    | Group => <GroupContent />
    | Proposal => <GroupProposalContent />
    }}
  </Tab.Route>
}
