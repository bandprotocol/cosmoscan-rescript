@val external document: {..} = "document"

let style = document["createElement"]("style")
document["head"]["appendChild"](style)
style["innerHTML"] = AppStyle.style

@react.component
let make = () => <App />
  // <ApolloClient.React.ApolloProvider client=Apollo.client>
  //   <GlobalContext>
  //     <TimeContext>
  //       <ThemeContext>
  //         <ModalContext>
  //           <AccountContext>
              
  //             <Modal />
  //           </AccountContext> 
  //         </ModalContext>
  //       </ThemeContext>
  //     </TimeContext>
  //   </GlobalContext>
  // </ApolloClient.React.ApolloProvider>
