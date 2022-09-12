%%raw("require('./index.css')")

@react.component
let make = () => 
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext>
      <TimeContext>
        <ThemeContext>
          <ModalContext>
            <AccountContext>
              <App />
              <Modal />
            </AccountContext> 
          </ModalContext>
        </ThemeContext>
      </TimeContext>
    </GlobalContext>
  </ApolloClient.React.ApolloProvider>
