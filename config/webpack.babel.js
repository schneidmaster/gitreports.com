import path from 'path';
import webpack from 'webpack';
import ExtractTextPlugin from 'extract-text-webpack-plugin';
import CompressionPlugin from 'compression-webpack-plugin';
import AssetMapPlugin from 'asset-map-webpack-plugin';
import StatsPlugin from 'stats-webpack-plugin';
import { BundleAnalyzerPlugin } from 'webpack-bundle-analyzer';
import envRules from './webpack/rules';
import { devServer, publicPath } from './webpack/dev';
import buildEnv from './webpack/env';

let { TARGET: target, BUNDLE_ANALYZE: bundleAnalyze } = process.env;
let { deployTarget, namePattern, cssNamePattern } = buildEnv(target);

let resolvedRules = envRules(deployTarget);

let config = {
  entry: {
    application: './app/assets/webpack/application'
  },

  output: {
    path: path.join(__dirname, '..', 'public', 'assets'),
    publicPath: '/assets/',
    filename: `${namePattern}.js`
  },

  resolve: {
    modules: [
      path.join('app', 'assets'),
      path.join('vendor', 'assets'),
      path.join('app', 'assets', 'stylesheets'),
      path.join('app'),
      'node_modules'
    ],
    extensions: ['.js', '.css']
  },

  module: {
    rules: resolvedRules
  },

  plugins: [
    new StatsPlugin('webpack_manifest.json', {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
      warnings: (target === 'development')
    })
  ]
};

if (deployTarget) {
  config.plugins.push(
    new ExtractTextPlugin({filename: `${cssNamePattern}.css`}),
    new webpack.NoEmitOnErrorsPlugin(),
    new AssetMapPlugin(path.resolve('public', 'assets', 'asset_map.json')),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        screw_ie8: true
      },
      mangle: {
        screw_ie8: true
      },
      output: {
        comments: false,
        screw_ie8: true
      }
    }),
    new CompressionPlugin({
      asset: '[path].gz',
      test: /\.(css|js)$/
    })
  );

  if(bundleAnalyze) {
    config.plugins.push(new BundleAnalyzerPlugin({analyzerMode: 'static'}));
  }
} else {
  config.devServer = devServer;
  config.output.publicPath = publicPath;
  config.plugins.push(
    new webpack.HotModuleReplacementPlugin(),
    new webpack.SourceMapDevToolPlugin({
      module: true,
      columns: false
    }),
    new AssetMapPlugin('asset_map.json', path.resolve()),
  );
}

export default config;
