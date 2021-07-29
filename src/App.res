@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <Example />
  </ApolloClient.React.ApolloProvider>
