const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const outputDir = path.join(__dirname, "dist/");
const webpack = require('webpack'); //to access built-in plugins

const isProd = process.env.NODE_ENV === "production";



module.exports = {
  entry: "./src/WebpackEntry.bs.js",
  mode: isProd ? "production" : "development",
  output: {
    path: outputDir,
    filename: "clientBundle.js",
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "src/index.html",
      inject: false,
    }),
    new webpack.DefinePlugin({
      RPC_URL: JSON.stringify(process.env.RPC_URL),
      GRAPHQL_URL: JSON.stringify(process.env.GRAPHQL_URL),
      LAMBDA_URL: JSON.stringify(process.env.LAMBDA_URL),
      FAUCET_URL: JSON.stringify(process.env.FAUCET_URL),
    })
  ],
  devServer: {
    compress: true,
    contentBase: outputDir,
    port: process.env.PORT || 8000,
    historyApiFallback: true,
  },
};

