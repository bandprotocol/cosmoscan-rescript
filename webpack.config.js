const path = require("path")
const HtmlWebpackPlugin = require("html-webpack-plugin")
const NodePolyfillPlugin = require('node-polyfill-webpack-plugin');
const outputDir = path.join(__dirname, "dist/")
const webpack = require("webpack") //to access built-in plugins

const isProd = process.env.NODE_ENV === "production"

module.exports = {
  entry: "./src/WebpackEntry.bs.js",
  mode: isProd ? "production" : "development",
  output: {
    path: outputDir,
    filename: "clientBundle.js",
  },

  plugins: [
    new NodePolyfillPlugin(),
    new HtmlWebpackPlugin({
      template: "src/index.html",
      inject: false,
    }),
    new webpack.DefinePlugin({
      RPC_URL: JSON.stringify(process.env.RPC_URL),
      GRPC: JSON.stringify(process.env.GRPC),
      GRAPHQL_URL: JSON.stringify(process.env.GRAPHQL_URL),
      LAMBDA_URL: JSON.stringify(process.env.LAMBDA_URL),
      FAUCET_URL: JSON.stringify(process.env.FAUCET_URL),
    }),
  ],
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.(png|svg|jpg|gif)$/,
        loader: "file-loader",
        options: {
          name: "[name].[ext]",
          outputPath: "src/images",
        },
      },
    ],
  },
  devServer: {
    compress: true,
    static: outputDir,
    port: process.env.PORT || 8000,
    historyApiFallback: true,
  },
}
