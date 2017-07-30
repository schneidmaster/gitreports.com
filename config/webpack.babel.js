import path from 'path';
import webpack from 'webpack';
import ExtractTextPlugin from 'extract-text-webpack-plugin';
import CompressionPlugin from 'compression-webpack-plugin';
import CleanWebpackPlugin from 'clean-webpack-plugin';
import StatsPlugin from 'stats-webpack-plugin';
import { BundleAnalyzerPlugin } from 'webpack-bundle-analyzer';
import envRules from './webpack/rules';
import { devServer, publicPath } from './webpack/dev';
import buildEnv from './webpack/env';

const { TARGET: target, BUNDLE_ANALYZE: bundleAnalyze } = process.env;
const { deployTarget, namePattern, cssNamePattern } = buildEnv(target);

const resolvedRules = envRules(deployTarget);

const outputPath = path.join(__dirname, '..', 'public', 'assets');

const config = {
  entry: {
    application: './app/assets/webpack/application',
  },

  output: {
    path: outputPath,
    publicPath: '/assets/',
    filename: `${namePattern}.js`,
  },

  resolve: {
    modules: [
      path.join('app', 'assets'),
      path.join('vendor', 'assets'),
      path.join('app', 'assets', 'stylesheets'),
      path.join('app'),
      'node_modules',
    ],
    extensions: ['.js', '.css'],
  },

  module: {
    rules: resolvedRules,
  },

  plugins: [
    new StatsPlugin('webpack_manifest.json', {
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true,
      warnings: target === 'development',
    }),
    new webpack.SourceMapDevToolPlugin({
      module: true,
      columns: false,
    }),
  ],
};

if (deployTarget) {
  config.plugins.push(
    new ExtractTextPlugin({ filename: `${cssNamePattern}.css` }),
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        screw_ie8: true,
      },
      mangle: {
        screw_ie8: true,
      },
      output: {
        comments: false,
        screw_ie8: true,
      },
    }),
    new CompressionPlugin({
      asset: '[path].gz',
      test: /\.(css|js)$/,
    }),
    new CleanWebpackPlugin(outputPath, { allowExternal: true }),
  );

  if(bundleAnalyze) {
    config.plugins.push(new BundleAnalyzerPlugin({ analyzerMode: 'static' }));
  }
} else {
  config.devServer = devServer;
  config.output.publicPath = publicPath;
  config.plugins.push(
    new webpack.HotModuleReplacementPlugin(),
  );
}

export default config;
