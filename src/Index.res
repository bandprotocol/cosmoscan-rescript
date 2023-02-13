%%raw("require('./index.css')")

@react.component
let make = () => 
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext>
      <ClientContext>
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
      </ClientContext>
    </GlobalContext>
  </ApolloClient.React.ApolloProvider>
