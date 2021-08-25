@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <TimeContext>
      <ThemeContext>
        <ModalContext>
          <AccountContext> <Example /> <ExampleRoute /> <Modal /> </AccountContext>
        </ModalContext>
      </ThemeContext>
    </TimeContext>
  </ApolloClient.React.ApolloProvider>
