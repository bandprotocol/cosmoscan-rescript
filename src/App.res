@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext>
      <TimeContext>
        <ThemeContext>
          <ModalContext>
            <AccountContext> <Example /> <ExampleRoute /> <Modal /> </AccountContext>
          </ModalContext>
        </ThemeContext>
      </TimeContext>
    </GlobalContext>
  </ApolloClient.React.ApolloProvider>
