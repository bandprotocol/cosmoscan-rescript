module Styles = {
  open CssJs

  let container = style(. [
    width(#percent(100.)),
    height(#px(200)),
    margin2(~v=#zero, ~h=#auto),
    Media.mobile([height(#px(120))]),
  ])
}

let renderGraph: (array<float>, array<string>) => unit = %raw(`
function(data, colors) {

  const { Chart } = require('chart.js');
  var ctx = document.getElementById('accountBalance').getContext('2d');

  // change seconds to milliseconds
  var chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'doughnut',

      // The data for our dataset
      data: {
        datasets: [
          {
            data: data,
            backgroundColor: colors,
            borderColor: colors,
            borderWidth: 0
          },
        ],
        labels: [
          "Available",
          "Commission",
          "Delegated",
          "Reward",
          "Unbonding",
        ],
      },

      // Configuration options go here
      options: {
        maintainAspectRatio: false,
        legend: {
          display: false
        },
        tooltip: {
          enabled: true
        },
        cutoutPercentage: 65,
      },
  });
}`)

@react.component
let make = (~data, ~colors) => {
  let ({ThemeContext.theme: theme}, _) = React.useContext(ThemeContext.context)

  React.useEffect0(() => {
    if data->Belt.Array.every(each => each == 0.) {
      renderGraph([100.], [theme.neutral_300->Theme.toString])
    } else {
      renderGraph(data, colors->Belt.Array.map(Theme.toString))
    }
    None
  })

  <div className=Styles.container>
    <canvas id="accountBalance" />
  </div>
}
