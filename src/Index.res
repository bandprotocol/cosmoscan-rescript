@val external document: {..} = "document"

let style = document["createElement"]("style")
document["head"]["appendChild"](style)
style["innerHTML"] = AppStyle.style

@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext>
      <TimeContext>
        <ThemeContext>
          <ModalContext> <AccountContext> <App /> <Modal /> </AccountContext> </ModalContext>
        </ThemeContext>
      </TimeContext>
    </GlobalContext>
  </ApolloClient.React.ApolloProvider>
