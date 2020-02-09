const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CompressionPlugin = require("compression-webpack-plugin");
const CleanWebpackPlugin = require("clean-webpack-plugin");
const StatsPlugin = require("stats-webpack-plugin");
const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer");
const envRules = require("./webpack/rules");
const { devServer, publicPath } = require("./webpack/dev");
const buildEnv = require("./webpack/env");

const { TARGET: target, BUNDLE_ANALYZE: bundleAnalyze } = process.env;
const { deployTarget, namePattern, cssNamePattern } = buildEnv(target);

const resolvedRules = envRules(deployTarget);

const outputPath = path.join(__dirname, "..", "public", "assets");

const config = {
  mode: target === "production" ? "production" : "development",

  entry: {
    application: "./app/assets/webpack/application"
  },

  output: {
    path: outputPath,
    publicPath: "/assets/",
    filename: `${namePattern}.js`
  },

  resolve: {
    modules: [
      path.join("app", "assets"),
      path.join("vendor", "assets"),
      path.join("app", "assets", "stylesheets"),
      path.join("app"),
      "node_modules"
    ],
    extensions: [".js", ".css"]
  },

  module: {
    rules: resolvedRules
  },

  optimization: {
    minimizer: [
      new TerserPlugin({ sourceMap: true }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },

  plugins: [
    new StatsPlugin("webpack_manifest.json", {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
      warnings: target === "development"
    }),
    new webpack.SourceMapDevToolPlugin({
      module: true,
      columns: false
    })
  ]
};

if (deployTarget) {
  config.plugins.push(
    new MiniCssExtractPlugin({
      filename: `${cssNamePattern}.css`
    }),
    new CompressionPlugin({
      asset: "[path].gz",
      test: /\.(css|js)$/
    }),
    new CleanWebpackPlugin(outputPath, { allowExternal: true })
  );

  if (bundleAnalyze) {
    config.plugins.push(new BundleAnalyzerPlugin({ analyzerMode: "static" }));
  }
} else {
  config.devServer = devServer;
  config.output.publicPath = publicPath;
  config.plugins.push(new webpack.HotModuleReplacementPlugin());
}

module.exports = config;
