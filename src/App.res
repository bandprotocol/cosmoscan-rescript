@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <TimeContext> <ThemeContext> <Example /> <ExampleRoute /> </ThemeContext> </TimeContext>
  </ApolloClient.React.ApolloProvider>
