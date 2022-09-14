%%raw("require('./index.css')")

@react.component
let make = () => 
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext>
      <TimeContext>
        <ThemeContext>
          <EmotionThemeContext>
            <ModalContext>
              <AccountContext>
                <App />
                <Modal />
              </AccountContext> 
            </ModalContext>
          </EmotionThemeContext>
        </ThemeContext>
      </TimeContext>
    </GlobalContext>
  </ApolloClient.React.ApolloProvider>
