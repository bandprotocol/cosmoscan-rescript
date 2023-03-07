%%raw("require('./index.css')")

AxiosHooks.setRpcUrl(Env.rpc)

@react.component
let make = () =>
  <ApolloClient.React.ApolloProvider client=Apollo.client>
    <GlobalContext.Provider>
      <ClientContext.Provider>
        <TimeContext.Provider>
          <ThemeContext.Provider>
            <ModalContext.Provider>
              <AccountContext.Provider>
                <App />
                <Modal />
              </AccountContext.Provider>
            </ModalContext.Provider>
          </ThemeContext.Provider>
        </TimeContext.Provider>
      </ClientContext.Provider>
    </GlobalContext.Provider>
  </ApolloClient.React.ApolloProvider>
